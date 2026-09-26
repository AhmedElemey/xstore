namespace XStore.AppSettings;

/// <summary>
/// Stand-in for the API's existing Result envelope { isSuccess, data, errorEn, errorAr, statusCode }.
/// Replace with the project's own Result type when copying these files in.
/// </summary>
public record ApiResult(bool IsSuccess, object? Data, string? ErrorEn, string? ErrorAr, int StatusCode)
{
    public static ApiResult Success(object? data, int status = 200) => new(true, data, null, null, status);
    public static ApiResult Error(string en, int status, string? ar = null) => new(false, null, en, ar ?? en, status);
}
