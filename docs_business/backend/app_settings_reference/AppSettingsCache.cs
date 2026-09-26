using System.Security.Cryptography;
using System.Text;
using System.Text.Json.Nodes;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;

namespace XStore.AppSettings;

/// <summary>
/// Cached, typed { key: value } map served to the mobile app. Every app launch hits this, so it
/// is built once and dropped on any admin write. Register: services.AddMemoryCache();
/// services.AddScoped&lt;AppSettingsCache&gt;();
/// </summary>
public class AppSettingsCache(AppDbContext db, IMemoryCache cache)
{
    private const string CacheKey = "app-settings:public";

    public record Snapshot(JsonObject Values, string ETag);

    public async Task<Snapshot> GetAsync(CancellationToken ct = default)
    {
        if (cache.TryGetValue(CacheKey, out Snapshot? hit) && hit is not null) return hit;

        var rows = await db.AppSettings.AsNoTracking().OrderBy(s => s.Key).ToListAsync(ct);
        var values = new JsonObject();
        foreach (var s in rows) values[s.Key] = AppSettingValue.ToTyped(s.DataType, s.Value);

        var hash = SHA256.HashData(Encoding.UTF8.GetBytes(values.ToJsonString()));
        var snapshot = new Snapshot(values, "\"" + Convert.ToHexString(hash)[..16] + "\"");
        cache.Set(CacheKey, snapshot, TimeSpan.FromMinutes(10));
        return snapshot;
    }

    public void Invalidate() => cache.Remove(CacheKey);
}
