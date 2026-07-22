/* ============================================================
   xStore Admin — API client  (Phase 1)
   ------------------------------------------------------------
   Wires the dashboard to the *existing* backend endpoints only.
   What is covered today:
     - POST /api/auth/login            (admin sign-in)
     - GET/POST/PUT/DELETE /api/categories   (full CRUD)
     - GET /api/users                  (read-only list; see TODO*)
     - GET /api/listings               (read-only list)
   Everything else the dashboard shows still runs on sample data
   until the backend adds the endpoints — see
   docs_business/admin-dashboard/BACKEND_ENDPOINTS_TODO.md
   (*UserDto currently has no Id/role/status, so vendor
    approve/reject cannot be wired yet.)

   Connection is opt-in: with no base URL set, the dashboard runs
   in prototype mode. The Connect dialog stores the base URL + JWT
   in localStorage.
   ============================================================ */
const Api = (() => {
  const LS_BASE = 'xstore_api_base';
  const LS_TOKEN = 'xstore_admin_token';

  // Leave empty so the shipped page defaults to prototype mode.
  // Set it here, or via the Connect dialog, to go live.
  const DEFAULT_BASE = '';

  const getBase = () => (localStorage.getItem(LS_BASE) || DEFAULT_BASE).replace(/\/+$/, '');
  const setBase = b => { const v = (b || '').trim().replace(/\/+$/, ''); v ? localStorage.setItem(LS_BASE, v) : localStorage.removeItem(LS_BASE); };
  const getToken = () => localStorage.getItem(LS_TOKEN) || '';
  const setToken = t => { t ? localStorage.setItem(LS_TOKEN, t) : localStorage.removeItem(LS_TOKEN); };
  const isConnected = () => !!getBase();
  const isAuthed = () => !!getBase() && !!getToken();

  class ApiError extends Error { constructor(message, status) { super(message); this.name = 'ApiError'; this.status = status; } }

  // Prefix relative asset URLs (e.g. "/uploads/..") with the API base.
  const resolveUrl = u => (!u ? u : /^https?:\/\//i.test(u) ? u : getBase() + '/' + String(u).replace(/^\/+/, ''));

  async function request(path, { method = 'GET', body, form, auth = true } = {}) {
    const base = getBase();
    if (!base) throw new ApiError('Not connected. Open Connect to set the API base URL.', 0);

    const headers = {};
    let payload;
    if (form) {
      payload = form;                       // FormData — let the browser set the boundary
    } else if (body !== undefined) {
      headers['Content-Type'] = 'application/json';
      payload = JSON.stringify(body);
    }
    if (auth && getToken()) headers['Authorization'] = 'Bearer ' + getToken();

    let res;
    try {
      res = await fetch(base + path, { method, headers, body: payload });
    } catch (e) {
      throw new ApiError('Network error — is the API reachable, HTTPS, and is CORS enabled for this origin?', 0);
    }

    const text = await res.text();
    let data = null;
    if (text) { try { data = JSON.parse(text); } catch { data = text; } }

    if (!res.ok) {
      if (res.status === 401) setToken('');   // expired/invalid — force re-auth
      const msg = (data && (data.error || data.message)) || ('Request failed (' + res.status + ')');
      throw new ApiError(msg, res.status);
    }

    // Success bodies: most endpoints return the raw payload (Ok(result.Data)),
    // but some return the Result envelope — unwrap it if present.
    if (data && typeof data === 'object' && 'isSuccess' in data && 'data' in data) return data.data;
    return data;
  }

  return {
    ApiError, getBase, setBase, getToken, setToken, isConnected, isAuthed, resolveUrl,

    async login(phoneNumber, password) {
      const data = await request('/api/auth/login', {
        method: 'POST', auth: false,
        body: { phoneNumber, password, rememberMe: true }
      });
      const token = data && data.token;
      if (!token) throw new ApiError('Signed in but no token was returned.', 0);
      setToken(token);
      return token;
    },
    logout() { setToken(''); },

    /* -------- Categories (fully supported) -------- */
    getCategories() { return request('/api/categories', { auth: false }); },
    createCategory({ nameEn, nameAr, isActive = true, parentId = null, image = null }) {
      const fd = new FormData();
      fd.append('NameEn', nameEn);
      fd.append('NameAr', nameAr);
      fd.append('IsActive', isActive);
      if (parentId != null) fd.append('ParentId', parentId);
      if (image) fd.append('Image', image);
      return request('/api/categories', { method: 'POST', form: fd });
    },
    setCategoryStatus(id, isActive) {
      return request('/api/categories/' + id + '/status', { method: 'PUT', body: { isActive } });
    },
    deleteCategory(id) { return request('/api/categories/' + id, { method: 'DELETE' }); },

    /* -------- Read-only lists -------- */
    getUsers({ role, vendorStatus, page = 1, pageSize = 50 } = {}) {
      const q = new URLSearchParams();
      if (role) q.set('Role', role);
      if (vendorStatus) q.set('VendorStatus', vendorStatus);
      q.set('Page', page); q.set('PageSize', pageSize);
      return request('/api/users?' + q.toString());
    },
    getListings({ page = 1, pageSize = 50 } = {}) {
      const q = new URLSearchParams();
      q.set('Page', page); q.set('PageSize', pageSize);
      return request('/api/listings?' + q.toString());
    },
  };
})();
