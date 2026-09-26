# xStore — General Settings (Remote App Config) Backend Handoff

**Status (2026-09-26):** admin dashboard UI built (`XStoreAdminDashboard`, System → General
Settings). Backend **not built yet**; the hosted API answers 401 to every unauthenticated path,
so its existence can't be probed. A drop-in reference implementation is in
[`app_settings_reference/`](app_settings_reference/). It compiles on .NET 8, and every endpoint
and error case below was exercised against it over HTTP (in-memory DB). The mobile app does not
call it yet.

## What this is

A super admin adds typed key/value pairs from the dashboard. The mobile app reads them from the
backend at startup, so product values change **without an app release**. Examples:

| Key | Type | Value | Used for |
|---|---|---|---|
| `force_update_required` | Boolean | `false` | Block the app until the user updates |
| `soft_update_required` | Boolean | `false` | Dismissible "update available" prompt |
| `minimum_app_version` | String | `2.0.4` | Compared with the installed build |
| `listing-title-max-character` | Integer | `170` | Listing form validation |
| `commission_rate` | Float | `0.15` | Display-only config |
| `home_sections` | Json | `["banners","hot_deals"]` | Home feed ordering |

Modelled on the 4swapp "General Settings" screen. **Platform / sub-platform scoping is out of
scope for now.** If it's needed later, add a nullable `Platform` column and a `?platform=` query
on the public endpoint. Nothing below has to change for that.

## Data types (frozen: the mobile app parses by these)

| Wire value | Stored int | Canonical stored string | Public endpoint returns |
|---|---|---|---|
| `String` | 1 | verbatim, max 4000 chars | JSON string |
| `Json` | 2 | minified JSON **object or array** | the object / array itself |
| `Boolean` | 3 | `true` / `false` | JSON bool |
| `Integer` | 4 | `-?\d+`, within ±2^53−1 | JSON number |
| `Float` | 5 | `-?\d+(\.\d+)?` | JSON number |

`dataType` is accepted case-insensitively on input and always returned as its name.

## Rules

- **Key:** `^[a-z][a-z0-9_.-]{0,99}$`, unique (unique DB index). **Immutable after create.**
- **Data type:** immutable after create. PUT with a different `dataType` → 400. Shipped mobile
  builds read by key and parse by type, so renaming or retyping silently breaks them. The
  dashboard locks both fields in edit mode and tells the admin to delete and re-create instead.
- **Value:** validated and normalized per type (table above). The dashboard runs the same rules
  (`src/app/core/app-settings.ts`) before sending, so the backend rules must stay in sync.
- **No secrets.** The public endpoint is anonymous; anything stored here is world-readable.
- `createdBy` / `updatedBy` are the admin's display name, taken from the auth token.

## Admin endpoints (dashboard)

Same role/policy as `SystemSettingsController`. All responses use the existing Result envelope
`{ isSuccess, data, errorEn, errorAr, statusCode }`. The dashboard shows `errorEn` in the modal.

```
GET    /api/admin/app-settings?keyword=&dataType=&page=1&pageSize=20
       → data: { items: AppSettingDto[], totalCount, page, pageSize, totalPages }
         keyword matches key or description; dataType filters by type name; pageSize ≤ 100
GET    /api/admin/app-settings/{id}          → data: AppSettingDto            | 404
POST   /api/admin/app-settings               → 201 data: AppSettingDto        | 400 | 409 duplicate key
PUT    /api/admin/app-settings/{id}          → 200 data: AppSettingDto        | 400 | 404
DELETE /api/admin/app-settings/{id}          → 204                            | 404
```

Request body (POST and PUT; on PUT `key` is ignored and `dataType` must match the stored type):

```json
{ "key": "force_update_required", "dataType": "Boolean", "value": "true", "description": "Blocks the app until users update" }
```

`AppSettingDto`:

```json
{
  "id": 18, "key": "force_update_required", "value": "false", "dataType": "Boolean",
  "description": null,
  "createdAt": "2025-02-05T15:45:00Z", "createdBy": "A.yasser",
  "updatedAt": "2026-05-03T16:21:00Z", "updatedBy": "admin2"
}
```

Error examples (all verified against the reference implementation):

| Request | Status | `errorEn` |
|---|---|---|
| duplicate key | 409 | `A setting with key "force_update_required" already exists.` |
| Json value `{json:'string'}` | 400 | `Invalid JSON: 'j' is an invalid start of a property name…` |
| Float value `yrtr` | 400 | `Value must be a number, e.g. 0.15.` |
| key `Bad Key` | 400 | `Key must use lowercase letters, digits, …` |
| PUT with another `dataType` | 400 | `Data type can't be changed. Delete the setting and create it again.` |
| no admin token | 401 | — |

## Mobile endpoints (public, anonymous)

```
GET /api/app-settings
→ 200 { "isSuccess": true, "data": {
        "force_update_required": false,
        "minimum_app_version": "2.0.4",
        "listing-title-max-character": 170,
        "commission_rate": 0.15,
        "home_sections": ["banners", "hot_deals"] }, ... }
  Headers: ETag: "<hash>", Cache-Control: public, max-age=60
  Send If-None-Match: <etag> → 304 with an empty body when nothing changed.

GET /api/app-settings/{key}
→ 200 data: <typed value>   e.g. { "data": true, ... }
→ 404 errorEn: Setting "<key>" not found.
```

It is one flat map with native JSON types, so the app makes one call at startup and gets Dart
`bool` / `int` / `double` / `String` / `List` / `Map` directly with no string parsing. The
server caches the map in memory and drops the cache on every admin write, so a change is
visible on the next request (plus up to 60 s of client/proxy caching).

### Mobile integration notes (for the Flutter team)

- Anonymous, so call it **before login**, e.g. in the splash/bootstrap flow. Force-update must
  work for logged-out users too.
- **Always ship a built-in default for every key** and use it when the key is missing, has an
  unexpected type, or the request fails. Settings can be deleted from the dashboard at any time.
- Keep the last good response (and its ETag) in local storage. Send `If-None-Match` on the next
  launch; on 304, reuse the stored map.
- Suggested endpoint constant: `static const String appSettings = '$_api/app-settings';`
  in `lib/core/network/api_endpoints.dart`. Unwrap `data` as with other Result-envelope calls.

## Reference implementation — `app_settings_reference/`

| File | Purpose |
|---|---|
| `AppSetting.cs` | Entity + `AppSettingDataType` enum (stored as int) |
| `AppSettingConfiguration.cs` | EF Core mapping: table `AppSettings`, unique index on `Key` |
| `AppSettingValue.cs` | Key/value validation, normalization, typed conversion |
| `AppSettingDtos.cs` | `AppSettingDto`, `AppSettingRequest`, `PagedResult<T>` |
| `AdminAppSettingsController.cs` | Admin CRUD (`api/admin/app-settings`) |
| `AppSettingsController.cs` | Public read (`api/app-settings`), ETag / 304 |
| `AppSettingsCache.cs` | `IMemoryCache` snapshot of the public map, invalidated on write |
| `ApiResult.cs` | **Stand-in** for the API's Result envelope. Replace with the real one |

To adopt:

1. Copy the files in and fix namespaces. Replace `ApiResult` with the project's Result type and
   `AppDbContext` with the real DbContext name.
2. Add `public DbSet<AppSetting> AppSettings => Set<AppSetting>();` and apply
   `AppSettingConfiguration` (or `ApplyConfigurationsFromAssembly`).
3. `builder.Services.AddMemoryCache(); builder.Services.AddScoped<AppSettingsCache>();`
4. Set `[Authorize(Roles = ...)]` on `AdminAppSettingsController` to whatever
   `SystemSettingsController` uses. Swap `CurrentUser()` for the project's current-user service.
5. `dotnet ef migrations add AddAppSettings && dotnet ef database update`.
6. Optional: seed the keys the mobile app will read first (`force_update_required`,
   `soft_update_required`, `minimum_app_version`).
7. Add the six routes to the Postman collection.

If the API runs on more than one instance, swap the `IMemoryCache` for the shared cache (or
drop the cache entirely; it is one small indexed table).

## Open questions

1. **Roles:** should plain Administrators also manage these, or Super Admin only? The dashboard
   doesn't hide the page by role today.
2. **Audit history:** only the last update (who/when) is kept. Add an `AppSettingHistory` table
   if you need a full change log.
3. **Platform scoping** (Web / MobileApp / sub-platforms, as in 4swapp): deferred, see above.
