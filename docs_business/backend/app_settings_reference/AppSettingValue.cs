using System.Globalization;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Text.RegularExpressions;

namespace XStore.AppSettings;

/// <summary>
/// Validation + conversion rules for setting values. Mirrors the admin dashboard's
/// src/app/core/app-settings.ts so both sides reject the same input.
/// </summary>
public static partial class AppSettingValue
{
    public const int MaxStringLength = 4000;

    [GeneratedRegex("^[a-z][a-z0-9_.-]{0,99}$")]
    private static partial Regex KeyRegex();

    public static string? ValidateKey(string? key)
    {
        var k = key?.Trim() ?? "";
        if (k.Length == 0) return "Key is required.";
        return KeyRegex().IsMatch(k)
            ? null
            : "Key must use lowercase letters, digits, '_', '-' or '.', start with a letter, and be at most 100 characters.";
    }

    /// <summary>Returns the canonical string to store, or sets <paramref name="error"/>.</summary>
    public static string? Normalize(AppSettingDataType type, string? raw, out string? error)
    {
        error = null;
        raw ??= "";
        var v = raw.Trim();
        switch (type)
        {
            case AppSettingDataType.Boolean:
                if (v is "true" or "false") return v;
                error = "Value must be true or false.";
                return null;

            case AppSettingDataType.Integer:
                if (Regex.IsMatch(v, @"^-?\d+$") && long.TryParse(v, NumberStyles.AllowLeadingSign, CultureInfo.InvariantCulture, out var l)
                    && Math.Abs(l) <= 9007199254740991) // JS Number.MAX_SAFE_INTEGER — the dashboard's limit
                    return l.ToString(CultureInfo.InvariantCulture);
                error = "Value must be a whole number.";
                return null;

            case AppSettingDataType.Float:
                if (Regex.IsMatch(v, @"^-?\d+(\.\d+)?$") && double.TryParse(v, NumberStyles.Float, CultureInfo.InvariantCulture, out _))
                    return v;
                error = "Value must be a number, e.g. 0.15.";
                return null;

            case AppSettingDataType.Json:
                try
                {
                    var node = JsonNode.Parse(v);
                    if (node is JsonObject or JsonArray) return node.ToJsonString(); // minified
                    error = "Value must be a JSON object {…} or list […].";
                }
                catch (JsonException ex)
                {
                    error = "Invalid JSON: " + ex.Message;
                }
                return null;

            default: // String — stored verbatim (not trimmed)
                if (raw.Length <= MaxStringLength) return raw;
                error = $"Value must be {MaxStringLength} characters or fewer.";
                return null;
        }
    }

    /// <summary>The stored string as a real JSON value for the mobile endpoint (bool, number, object/array, string).</summary>
    public static JsonNode? ToTyped(AppSettingDataType type, string value) => type switch
    {
        AppSettingDataType.Boolean => JsonValue.Create(value == "true"),
        AppSettingDataType.Integer => JsonValue.Create(long.Parse(value, CultureInfo.InvariantCulture)),
        AppSettingDataType.Float => JsonValue.Create(double.Parse(value, CultureInfo.InvariantCulture)),
        AppSettingDataType.Json => JsonNode.Parse(value),
        _ => JsonValue.Create(value),
    };
}
