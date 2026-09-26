using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace XStore.AppSettings;

/// <summary>
/// Read-only remote config for the mobile app. Anonymous on purpose: the app needs values like
/// force_update_required before anyone logs in. Never store secrets in app settings.
/// </summary>
[ApiController]
[Route("api/app-settings")]
[AllowAnonymous]
public class AppSettingsController(AppSettingsCache settings) : ControllerBase
{
    // GET /api/app-settings → data: { "force_update_required": false, "minimum_app_version": "2.0.4", ... }
    // Supports If-None-Match → 304 so the app can poll cheaply.
    [HttpGet]
    public async Task<IActionResult> GetAll(CancellationToken ct)
    {
        var snap = await settings.GetAsync(ct);
        Response.Headers.ETag = snap.ETag;
        Response.Headers.CacheControl = "public, max-age=60";
        if (Request.Headers.IfNoneMatch.ToString() == snap.ETag) return StatusCode(304);
        return Ok(ApiResult.Success(snap.Values));
    }

    // GET /api/app-settings/{key} → data: typed value (bool / number / string / object / array)
    [HttpGet("{key}")]
    public async Task<IActionResult> GetOne(string key, CancellationToken ct)
    {
        var snap = await settings.GetAsync(ct);
        if (!snap.Values.TryGetPropertyValue(key.Trim(), out var value))
            return StatusCode(404, ApiResult.Error($"Setting \"{key}\" not found.", 404));
        return Ok(ApiResult.Success(value));
    }
}
