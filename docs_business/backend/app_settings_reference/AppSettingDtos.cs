namespace XStore.AppSettings;

/// <summary>Row shape for the admin dashboard. DataType serializes as its name ("Boolean"...).</summary>
public record AppSettingDto(
    int Id,
    string Key,
    string Value,
    string DataType,
    string? Description,
    DateTime CreatedAt,
    string CreatedBy,
    DateTime? UpdatedAt,
    string? UpdatedBy)
{
    public static AppSettingDto From(AppSetting s) => new(
        s.Id, s.Key, s.Value, s.DataType.ToString(), s.Description,
        s.CreatedAt, s.CreatedBy, s.UpdatedAt, s.UpdatedBy);
}

/// <summary>POST and PUT body. On PUT, Key is ignored and DataType must equal the stored one.</summary>
public record AppSettingRequest(string? Key, string? DataType, string? Value, string? Description);

public record PagedResult<T>(IReadOnlyList<T> Items, int TotalCount, int Page, int PageSize, int TotalPages);
