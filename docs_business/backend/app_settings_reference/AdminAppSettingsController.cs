using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace XStore.AppSettings;

/// <summary>
/// Super-admin CRUD behind the dashboard's General Settings page.
/// Use the same role/policy as SystemSettingsController.
/// </summary>
[ApiController]
[Route("api/admin/app-settings")]
[Authorize(Roles = "Administrator")]
public class AdminAppSettingsController(AppDbContext db, AppSettingsCache publicCache) : ControllerBase
{
    // GET /api/admin/app-settings?keyword=&dataType=&page=1&pageSize=20
    [HttpGet]
    public async Task<IActionResult> List(string? keyword, string? dataType, int page = 1, int pageSize = 20, CancellationToken ct = default)
    {
        page = Math.Max(1, page);
        pageSize = Math.Clamp(pageSize, 1, 100);
        var q = db.AppSettings.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(keyword))
        {
            var k = keyword.Trim().ToLower();
            q = q.Where(s => s.Key.Contains(k) || (s.Description != null && s.Description.ToLower().Contains(k)));
        }
        if (!string.IsNullOrWhiteSpace(dataType))
        {
            if (!Enum.TryParse<AppSettingDataType>(dataType, true, out var t)) return Fail(400, "Unknown dataType.");
            q = q.Where(s => s.DataType == t);
        }

        var total = await q.CountAsync(ct);
        var rows = await q.OrderBy(s => s.Id).Skip((page - 1) * pageSize).Take(pageSize).ToListAsync(ct);
        var result = new PagedResult<AppSettingDto>(
            rows.Select(AppSettingDto.From).ToList(), total, page, pageSize,
            Math.Max(1, (int)Math.Ceiling(total / (double)pageSize)));
        return Ok(ApiResult.Success(result));
    }

    // GET /api/admin/app-settings/{id}
    [HttpGet("{id:int}")]
    public async Task<IActionResult> Get(int id, CancellationToken ct)
    {
        var s = await db.AppSettings.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id, ct);
        return s is null ? Fail(404, "Setting not found.") : Ok(ApiResult.Success(AppSettingDto.From(s)));
    }

    // POST /api/admin/app-settings
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] AppSettingRequest body, CancellationToken ct)
    {
        var key = body.Key?.Trim() ?? "";
        if (AppSettingValue.ValidateKey(key) is { } keyError) return Fail(400, keyError);
        if (!TryParseType(body.DataType, out var type)) return Fail(400, "Data type is required (String, Json, Boolean, Integer or Float).");
        var value = AppSettingValue.Normalize(type, body.Value, out var valueError);
        if (value is null) return Fail(400, valueError!);
        if (await db.AppSettings.AnyAsync(s => s.Key == key, ct)) return Fail(409, $"A setting with key \"{key}\" already exists.");

        var s = new AppSetting
        {
            Key = key,
            DataType = type,
            Value = value,
            Description = Clean(body.Description),
            CreatedAt = DateTime.UtcNow,
            CreatedBy = CurrentUser(),
        };
        db.AppSettings.Add(s);
        try
        {
            await db.SaveChangesAsync(ct);
        }
        catch (DbUpdateException)
        {
            return Fail(409, $"A setting with key \"{key}\" already exists."); // unique-index race
        }
        publicCache.Invalidate();
        return StatusCode(201, ApiResult.Success(AppSettingDto.From(s), 201));
    }

    // PUT /api/admin/app-settings/{id} — only Value and Description change.
    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] AppSettingRequest body, CancellationToken ct)
    {
        var s = await db.AppSettings.FirstOrDefaultAsync(x => x.Id == id, ct);
        if (s is null) return Fail(404, "Setting not found.");
        if (!string.IsNullOrWhiteSpace(body.DataType) && (!TryParseType(body.DataType, out var t) || t != s.DataType))
            return Fail(400, "Data type can't be changed. Delete the setting and create it again.");

        var value = AppSettingValue.Normalize(s.DataType, body.Value, out var valueError);
        if (value is null) return Fail(400, valueError!);

        s.Value = value;
        s.Description = Clean(body.Description);
        s.UpdatedAt = DateTime.UtcNow;
        s.UpdatedBy = CurrentUser();
        await db.SaveChangesAsync(ct);
        publicCache.Invalidate();
        return Ok(ApiResult.Success(AppSettingDto.From(s)));
    }

    // DELETE /api/admin/app-settings/{id}
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id, CancellationToken ct)
    {
        var s = await db.AppSettings.FirstOrDefaultAsync(x => x.Id == id, ct);
        if (s is null) return Fail(404, "Setting not found.");
        db.AppSettings.Remove(s);
        await db.SaveChangesAsync(ct);
        publicCache.Invalidate();
        return NoContent();
    }

    private static bool TryParseType(string? raw, out AppSettingDataType type) =>
        Enum.TryParse(raw?.Trim(), true, out type) && Enum.IsDefined(type);

    private static string? Clean(string? s) =>
        string.IsNullOrWhiteSpace(s) ? null : s.Trim()[..Math.Min(s.Trim().Length, 500)];

    /// <summary>Display name for the Created by / Updated by columns. Swap for the project's current-user service.</summary>
    private string CurrentUser() =>
        User.FindFirst("name")?.Value ?? User.Identity?.Name ?? User.FindFirst("sub")?.Value ?? "admin";

    private ObjectResult Fail(int status, string en) => StatusCode(status, ApiResult.Error(en, status));
}
