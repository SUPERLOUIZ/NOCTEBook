// Service worker mínimo: hace la web instalable. Red primero (siempre la versión nueva); nunca guarda datos de Supabase.
const V='noc-v3';
self.addEventListener('install',()=>self.skipWaiting());
self.addEventListener('activate',e=>e.waitUntil(caches.keys().then(k=>Promise.all(k.filter(x=>x!==V).map(x=>caches.delete(x)))).then(()=>self.clients.claim())));
self.addEventListener('fetch',e=>{
  const r=e.request,u=new URL(r.url);
  if(r.method!=='GET'||u.origin!==location.origin)return;
  e.respondWith((async()=>{
    try{
      const res=await fetch(r);
      const c=res.clone();caches.open(V).then(ch=>ch.put(r,c)).catch(()=>{});
      return res;
    }catch(err){
      const cached=(await caches.match(r))||(await caches.match('./'));
      return cached||new Response('Sin conexión',{status:503,headers:{'Content-Type':'text/plain'}});
    }
  })());
});
