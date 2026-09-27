namespace XStore.AppSettings;

/// <summary>Stored as int. Order matches the admin dashboard (String=1 … Float=5) — do not renumber.</summary>
public enum AppSettingDataType
{
    String = 1,
    Json = 2,
    Boolean = 3,
    Integer = 4,
    Float = 5,
}

/// <summary>
/// One remote-config key the super admin manages from the dashboard's General Settings page
/// and the mobile app reads from GET /api/app-settings.
/// </summary>
public class AppSetting
{
    public int Id { get; set; }

    /// <summary>Unique, immutable after create (mobile builds read by key). ^[a-z][a-z0-9_.-]{0,99}$</summary>
    public string Key { get; set; } = "";

    /// <summary>Canonical string form: "true"/"false", "170", "0.15", minified JSON, or free text.</summary>
    public string Value { get; set; } = "";

    /// <summary>Immutable after create (mobile builds parse by type).</summary>
    public AppSettingDataType DataType { get; set; }

    public string? Description { get; set; }

    public DateTime CreatedAt { get; set; }
    public string CreatedBy { get; set; } = "";
    public DateTime? UpdatedAt { get; set; }
    public string? UpdatedBy { get; set; }
}
