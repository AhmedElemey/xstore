/* ---------- xStore Admin Dashboard — backend API client ----------
 * Wraps the endpoints in ../BACKEND_HANDOFF.md / the "xStoreEcommerce Admin & Super
 * Admin" Postman collection. No build step — plain script, everything hangs off the
 * global `API` object so it can be called from inline onclick handlers like the rest
 * of app.js.
 *
 * Response shapes are not pinned down by the Postman collection (no example bodies),
 * so every mapper below reads several plausible key names (camelCase / PascalCase)
 * and falls back to '—' rather than throwing. Treat docs_business/admin-dashboard/
 * BACKEND_HANDOFF.md's "Wiring notes" section as the list of assumptions to confirm
 * with the backend team.
 */
(function(global){
'use strict';

const BASE_KEY='xstore_admin_api_base';
const TOKEN_KEY='xstore_admin_token';

function getBaseUrl(){ return localStorage.getItem(BASE_KEY)||'http://localhost:5000'; }
function setBaseUrl(v){ localStorage.setItem(BASE_KEY,(v||'').replace(/\/+$/,'')); }
function getToken(){ return localStorage.getItem(TOKEN_KEY)||''; }
function setToken(t){ if(t) localStorage.setItem(TOKEN_KEY,t); }
function clearToken(){ localStorage.removeItem(TOKEN_KEY); }

class ApiError extends Error{
 constructor(status,message,body){ super(message); this.status=status; this.body=body; }
}

function qs(params){
 if(!params) return '';
 const parts=Object.keys(params)
   .filter(k=>params[k]!==undefined&&params[k]!==null&&params[k]!=='')
   .map(k=>encodeURIComponent(k)+'='+encodeURIComponent(params[k]));
 return parts.length?'?'+parts.join('&'):'';
}

/* core request — sends the JWT via both headers per the collection description */
async function request(path,{method='GET',params,body,isForm=false}={}){
 const url=getBaseUrl()+path+qs(params);
 const headers={};
 const token=getToken();
 if(token){ headers['Authorization']='Bearer '+token; headers['X-Auth-Token']=token; }
 let payload=body;
 if(body&&!isForm){ headers['Content-Type']='application/json'; payload=JSON.stringify(body); }
 let res;
 try{
   res=await fetch(url,{method,headers,body:payload});
 }catch(networkErr){
   throw new ApiError(0,'Could not reach '+getBaseUrl()+' — check the API base URL and that the backend is running.',null);
 }
 if(res.status===401){
   clearToken();
   global.dispatchEvent(new CustomEvent('xstore:unauthorized'));
   throw new ApiError(401,'Session expired — please sign in again.',null);
 }
 const text=await res.text();
 let json=null;
 if(text){ try{ json=JSON.parse(text); }catch(e){ json=null; } }
 if(!res.ok){
   const msg=(json&&(json.message||json.title||json.error))||res.statusText||('HTTP '+res.status);
   throw new ApiError(res.status,msg,json);
 }
 return json;
}

/* ---------- response-shape helpers ---------- */
const pick=(o,...keys)=>{ if(!o) return undefined; for(const k of keys){ if(o[k]!==undefined&&o[k]!==null) return o[k]; } return undefined; };
const num=(v,fallback=0)=>{ const n=Number(v); return Number.isFinite(n)?n:fallback; };

/* GET-list endpoints aren't documented with example bodies — accept a raw array or a
 * common pagination envelope ({items|data|result|results|...}, total|totalCount|count). */
function unwrapList(json){
 if(Array.isArray(json)) return {items:json,total:json.length};
 if(!json) return {items:[],total:0};
 const items=pick(json,'items','data','result','results','vendors','users','listings','orders','categories','banners')||[];
 const total=num(pick(json,'total','totalCount','count'),items.length);
 return {items:Array.isArray(items)?items:[],total};
}

const id=o=>pick(o,'id','Id','_id');

/* ---------- Auth ---------- */
const Auth={
 async login(phoneNumber,password,rememberMe){
   const json=await request('/api/auth/login',{method:'POST',body:{phoneNumber,password,rememberMe:!!rememberMe}});
   const token=pick(json,'token','Token','accessToken','jwt');
   if(!token) throw new ApiError(200,'Login succeeded but no token was returned by the server.',json);
   setToken(token);
   return json;
 },
 isAuthenticated(){ return !!getToken(); },
 logout(){ clearToken(); }
};

/* ---------- Overview ---------- */
const Overview={
 async get(from,to){
   const json=await request('/api/admin/overview',{params:{from,to}});
   return {
     gmv30d:num(pick(json,'gmv30d','gmv','gmvEgp')),
     orders30d:num(pick(json,'orders30d','ordersCount','orders')),
     activeVendors:num(pick(json,'activeVendors','vendorsActive')),
     pendingApprovals:num(pick(json,'pendingApprovals','pendingListings','pendingProducts')),
     revenueTrend:pick(json,'revenueTrend','dailyRevenue','revenue')||[],
     salesByCategory:pick(json,'salesByCategory','categorySales')||[],
     raw:json
   };
 }
};

/* ---------- Users ---------- */
const Users={
 async list({keyword,role,isVerified,vendorStatus,page=1,pageSize=20}={}){
   const json=await request('/api/users',{params:{keyword,role,isVerified,vendorStatus,page,pageSize}});
   return unwrapList(json);
 },
 async get(userId){ return request('/api/users/'+userId); },
 async approve(userId){ return request('/api/users/'+userId+'/approve',{method:'PUT'}); },
 async reject(userId){ return request('/api/users/'+userId+'/reject',{method:'PUT'}); },
 async settleCommission(userId,amountEgp){
   return request('/api/users/'+userId+'/commission/settle',{method:'PUT',body:amountEgp!=null?{amountEgp}:{}});
 }
};

/* VendorStatus enum from the collection: 1=Pending, 2=Approved, 3=Rejected */
const VendorStatus={PENDING:1,APPROVED:2,REJECTED:3};
/* ListingStatus enum: 0=Draft,1=Pending,2=Active,3=Paused,4=Sold,5=Rejected,6=Cancelled */
const ListingStatus={DRAFT:0,PENDING:1,ACTIVE:2,PAUSED:3,SOLD:4,REJECTED:5,CANCELLED:6};
/* OrderStatus enum: 0=Pending,1=Confirmed,2=Processing,3=Shipped,4=Delivered,5=Cancelled */
const OrderStatus={PENDING:0,CONFIRMED:1,PROCESSING:2,SHIPPED:3,DELIVERED:4,CANCELLED:5};

/* ---------- Vendors ---------- */
const Vendors={
 async list({keyword,vendorStatus,page=1,pageSize=20}={}){
   const json=await request('/api/admin/vendors',{params:{keyword,vendorStatus,page,pageSize}});
   return unwrapList(json);
 },
 async get(vendorId){ return request('/api/admin/vendors/'+vendorId); },
 async commission(vendorId){
   const json=await request('/api/admin/vendors/'+vendorId+'/commission');
   return {
     outstanding:num(pick(json,'outstandingEgp','outstanding')),
     warn:num(pick(json,'warnThresholdEgp','warn')),
     pause:num(pick(json,'pauseThresholdEgp','pause')),
     raw:json
   };
 },
 async updateCommissionThresholds(vendorId,warnThresholdEgp,pauseThresholdEgp){
   return request('/api/admin/vendors/'+vendorId+'/commission',{method:'PATCH',body:{warnThresholdEgp,pauseThresholdEgp}});
 },
 async settleCommission(vendorId,amountEgp){
   return request('/api/admin/vendors/'+vendorId+'/commission/settle',{method:'POST',body:amountEgp!=null?{amountEgp}:{}});
 },
 async approve(vendorId){ return request('/api/admin/vendors/'+vendorId+'/approve',{method:'PUT'}); },
 async reject(vendorId){ return request('/api/admin/vendors/'+vendorId+'/reject',{method:'PUT'}); }
};

/* ---------- Listings (product moderation) ---------- */
const Listings={
 async list({page=1,pageSize=10,name,status}={}){
   const json=await request('/api/admin/listings',{params:{page,pageSize,name,status}});
   return unwrapList(json);
 },
 async approve(listingId){ return request('/api/admin/listings/'+listingId+'/approve',{method:'PUT'}); },
 async reject(listingId,rejectionReason){
   return request('/api/admin/listings/'+listingId+'/reject',{method:'PUT',body:{rejectionReason}});
 },
 async setHotDeal(listingId,isHotDeal){
   return request('/api/admin/listings/'+listingId+'/hot-deal',{method:'PUT',body:{isHotDeal:!!isHotDeal}});
 }
};

/* ---------- Orders (ADMINISTRATOR only — expect 403 for SUPERADMIN-only sessions) ---------- */
const Orders={
 async list({page=1,pageSize=10,status}={}){
   const json=await request('/api/admin/orders',{params:{page,pageSize,status}});
   return unwrapList(json);
 },
 async get(orderId){ return request('/api/admin/orders/'+orderId); },
 async cancel(orderId,reason){ return request('/api/admin/orders/'+orderId+'/cancel',{method:'POST',body:{reason}}); }
};

/* ---------- Categories ----------
 * The collection only documents the admin write actions (POST/PUT/status/DELETE) — it
 * doesn't include a GET. BACKEND_HANDOFF.md says `GET /categories` is the server-driven
 * taxonomy read; assumed here as `GET /api/categories`. Confirm with backend if this 404s. */
const Categories={
 async list(){
   const json=await request('/api/categories');
   return unwrapList(json).items;
 },
 async create({nameEn,nameAr,parentId,isActive,imageFile}){
   const fd=new FormData();
   fd.append('nameEn',nameEn); fd.append('nameAr',nameAr);
   if(parentId) fd.append('parentId',parentId);
   fd.append('isActive',String(!!isActive));
   if(imageFile) fd.append('image',imageFile);
   return request('/api/categories',{method:'POST',body:fd,isForm:true});
 },
 async update({categoryId,nameEn,nameAr,parentId,isActive,imageFile}){
   const fd=new FormData();
   fd.append('id',categoryId); fd.append('nameEn',nameEn); fd.append('nameAr',nameAr);
   if(parentId) fd.append('parentId',parentId);
   fd.append('isActive',String(!!isActive));
   if(imageFile) fd.append('image',imageFile);
   return request('/api/categories',{method:'PUT',body:fd,isForm:true});
 },
 async setStatus(categoryId,isActive){
   return request('/api/categories/'+categoryId+'/status',{method:'PUT',body:{isActive:!!isActive}});
 },
 async remove(categoryId){ return request('/api/categories/'+categoryId,{method:'DELETE'}); }
};

/* ---------- Banners ---------- (same GET caveat as Categories) */
const Banners={
 async list(){
   const json=await request('/api/banners');
   return unwrapList(json).items;
 },
 async create({nameEn,nameAr,sortOrder,isActive,categoryIds,storeIds,imageFile}){
   const fd=new FormData();
   fd.append('nameEn',nameEn); fd.append('nameAr',nameAr); fd.append('sortOrder',String(sortOrder||0));
   fd.append('isActive',String(!!isActive));
   if(categoryIds) fd.append('categoryIds',categoryIds);
   if(storeIds) fd.append('storeIds',storeIds);
   if(imageFile) fd.append('image',imageFile);
   return request('/api/banners',{method:'POST',body:fd,isForm:true});
 },
 async update({bannerId,nameEn,nameAr,sortOrder,isActive,categoryIds,storeIds,imageFile}){
   const fd=new FormData();
   fd.append('nameEn',nameEn); fd.append('nameAr',nameAr); fd.append('sortOrder',String(sortOrder||0));
   fd.append('isActive',String(!!isActive));
   if(categoryIds) fd.append('categoryIds',categoryIds);
   if(storeIds) fd.append('storeIds',storeIds);
   if(imageFile) fd.append('image',imageFile);
   return request('/api/banners/'+bannerId,{method:'PUT',body:fd,isForm:true});
 },
 async remove(bannerId){ return request('/api/banners/'+bannerId,{method:'DELETE'}); }
};

/* ---------- System Settings ---------- */
const Settings={
 async get(){
   const json=await request('/api/admin/system-settings');
   return {
     commissionValueOnOrder:num(pick(json,'commissionValueOnOrder')),
     warnThresholdEgp:num(pick(json,'warnThresholdEgp')),
     pauseThresholdEgp:num(pick(json,'pauseThresholdEgp')),
     raw:json
   };
 },
 async update({commissionValueOnOrder,warnThresholdEgp,pauseThresholdEgp}){
   return request('/api/admin/system-settings',{method:'PUT',body:{commissionValueOnOrder,warnThresholdEgp,pauseThresholdEgp}});
 }
};

global.API={
 ApiError,getBaseUrl,setBaseUrl,getToken,isAuthenticated:Auth.isAuthenticated,
 pick,num,id,
 Auth,Overview,Users,Vendors,Listings,Orders,Categories,Banners,Settings,
 VendorStatus,ListingStatus,OrderStatus
};

})(window);
