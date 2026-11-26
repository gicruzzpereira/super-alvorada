window.AlvoradaCustomerState=(()=>{
 const token=()=>document.querySelector('meta[name="customer-state-csrf"]')?.content||'';
 const read=key=>{try{return JSON.parse(localStorage.getItem(key)||'null')}catch{return null}};
 const payload=()=>({cart:read('alvorada-cart')||[],favorites:read('alvorada-favorites')||[],location:read('alvorada-delivery-location')});
 const sync=()=>{const csrf=token();if(!csrf)return Promise.resolve(false);return fetch('/api/cliente_estado.php',{method:'POST',credentials:'same-origin',headers:{'Content-Type':'application/json','X-CSRF-Token':csrf},body:JSON.stringify(payload())}).then(r=>r.ok).catch(()=>false);};
 const hydrate=async()=>{const csrf=token();if(!csrf)return;try{const response=await fetch('/api/cliente_estado.php',{credentials:'same-origin'});if(!response.ok)return;const data=await response.json();if(!data.state){sync();return;}const state=data.state;if(Array.isArray(state.cart))localStorage.setItem('alvorada-cart',JSON.stringify(state.cart));if(Array.isArray(state.favorites))localStorage.setItem('alvorada-favorites',JSON.stringify(state.favorites));if(state.location)localStorage.setItem('alvorada-delivery-location',JSON.stringify(state.location));const itemCount=(state.cart||[]).reduce((sum,item)=>sum+(Number(item.qty)||0),0);document.querySelectorAll('[data-cart-count]').forEach(badge=>badge.textContent=itemCount.toLocaleString('pt-BR'));window.dispatchEvent(new Event('alvorada-customer-state-loaded'));}catch{}};
 return {sync,hydrate};
})();
document.addEventListener('DOMContentLoaded',()=>window.AlvoradaCustomerState?.hydrate());

document.addEventListener('DOMContentLoaded',()=>{
 const cartKey='alvorada-cart'; const read=()=>JSON.parse(localStorage.getItem(cartKey)||'[]');
 const count=()=>{const n=read().reduce((s,x)=>s+Number(x.qty),0);document.querySelectorAll('[data-cart-count]').forEach(e=>e.textContent=n.toLocaleString('pt-BR'));};
 document.querySelectorAll('[data-add]').forEach(b=>b.addEventListener('click',async()=>{const label=b.textContent;const p={id:+b.dataset.id,name:b.dataset.name,price:+b.dataset.price,unit:b.dataset.unit,qty:b.dataset.unit==='KG'?0.5:1,encarte:b.dataset.encarte==='true'};const c=read(),old=c.find(x=>x.id===p.id);old?old.qty+=p.qty:c.push(p);localStorage.setItem(cartKey,JSON.stringify(c));await window.AlvoradaCustomerState?.sync();count();if(b.dataset.goCart==='true'){window.location.href='cliente/carrinho.php';return}b.textContent='Adicionado ✓';setTimeout(()=>b.textContent=label,900)}));count();
 const categoryMenu=document.querySelector('#category-mega-menu');
 const closeCategoryMenu=()=>{if(categoryMenu){document.querySelector('[data-category-menu-toggle]')?.setAttribute('aria-expanded','false');categoryMenu.hidden=true;}};
 document.addEventListener('click',e=>{if(!e.target.closest('.category-bar'))closeCategoryMenu();});
 document.addEventListener('keydown',e=>{if(e.key==='Escape')closeCategoryMenu();});
 document.querySelectorAll('[data-category]').forEach(a=>a.addEventListener('click',e=>{if(a.getAttribute('href')?.includes('categoria.php?')){closeCategoryMenu();return;}e.preventDefault();const cat=a.dataset.category;closeCategoryMenu();if(cat==='jornal'){document.querySelector('#jornal')?.scrollIntoView({behavior:'smooth'});return}if(cat==='ofertas'){document.querySelectorAll('.product-section').forEach(s=>s.hidden=false);document.querySelector('#ofertas')?.scrollIntoView({behavior:'smooth',block:'start'});return}const group=(a.dataset.categoryGroup||cat).split(',');document.querySelectorAll('.product-section').forEach(s=>s.hidden=cat!=='todos'&&!group.includes(s.dataset.slug));document.querySelectorAll('[data-category]').forEach(x=>x.classList.toggle('active',x===a));document.querySelector('#produtos')?.scrollIntoView({behavior:'smooth',block:'start'});}));
 const search=document.querySelector('#busca'),results=document.querySelector('#autocomplete');search?.addEventListener('input',()=>{const q=search.value.toLocaleLowerCase('pt-BR');let n=0;if(results){results.innerHTML='';document.querySelectorAll('.product').forEach(p=>{if(q&&p.dataset.search.includes(q)&&n<6){const a=document.createElement('a');a.href='#produto-'+p.dataset.id;a.textContent=p.dataset.name;results.append(a);n++}});results.hidden=!q||!n}});
 document.querySelectorAll('[data-modal-open]').forEach(b=>b.onclick=()=>document.querySelector(b.dataset.modalOpen)?.showModal());document.querySelectorAll('[data-modal-close]').forEach(b=>b.onclick=()=>b.closest('dialog').close());
 document.querySelectorAll('[data-qty]').forEach(i=>i.addEventListener('change',()=>{if(i.dataset.unit==='UN')i.value=Math.max(1,Math.floor(i.value));else i.value=Math.max(.001,Number(i.value)).toFixed(3)}));
});

document.addEventListener('DOMContentLoaded',()=>{
 document.querySelectorAll('[data-banner-carousel]').forEach(carousel=>{
  const slides=[...carousel.querySelectorAll('[data-banner-slide]')];
  const dotContainer=carousel.querySelector('[data-banner-dots]');
  if(!dotContainer)return;
  dotContainer.replaceChildren(...slides.map((_,i)=>{
   const dot=document.createElement('button');
   dot.type='button';
   dot.dataset.bannerDot=String(i);
   dot.setAttribute('aria-label',`Banner ${i+1} de ${slides.length}`);
   dot.setAttribute('aria-current','false');
   return dot;
  }));
  const dots=[...dotContainer.querySelectorAll('[data-banner-dot]')];
  const prev=carousel.querySelector('[data-banner-prev]');
  const next=carousel.querySelector('[data-banner-next]');
  const viewport=carousel.querySelector('.hero-carousel-viewport');
  if(!viewport)return;
  if(slides.length<2)return;
  let active=slides.findIndex(slide=>slide.classList.contains('is-active'));
  if(active<0)active=0;
  let timer=null;
  let pointerStart=null;
  let swiped=false;
  const setViewportHeight=(index,immediate=false)=>{
   const image=slides[index]?.querySelector('img');
   if(!image)return;
   const apply=()=>{
    if(index!==active||!image.naturalWidth)return;
    const height=viewport.clientWidth*image.naturalHeight/image.naturalWidth;
    if(immediate)viewport.style.transition='none';
    viewport.style.height=`${height}px`;
    viewport.classList.add('is-ready');
    if(immediate)requestAnimationFrame(()=>{viewport.style.transition='';});
   };
   if(image.complete&&image.naturalWidth)apply();
   else image.addEventListener('load',apply,{once:true});
  };
  const show=(index,direction=1,initial=false)=>{
   const previous=active;
   const nextIndex=(index+slides.length)%slides.length;
   if(!initial&&previous!==nextIndex){
    const outgoing=slides[previous];
    outgoing.classList.remove('is-leaving-next','is-leaving-prev');
    outgoing.classList.add(direction<0?'is-leaving-prev':'is-leaving-next');
    window.setTimeout(()=>outgoing.classList.remove('is-leaving-next','is-leaving-prev'),650);
   }
   active=nextIndex;
   carousel.dataset.bannerDirection=direction<0?'prev':'next';
   slides.forEach((slide,i)=>{
    const current=i===active;
    slide.classList.toggle('is-active',current);
    slide.setAttribute('aria-hidden',String(!current));
    slide.inert=!current;
   });
   dots.forEach((dot,i)=>{
    const current=i===active;
    dot.classList.toggle('is-active',current);
    dot.setAttribute('aria-current',String(current));
   });
   setViewportHeight(active,initial);
  };
  const stop=()=>{if(timer){window.clearInterval(timer);timer=null;}};
  const start=()=>{
   stop();
   timer=window.setInterval(()=>show(active+1,1),5000);
  };
  const navigate=delta=>{show(active+delta,delta);start();};
  prev?.addEventListener('click',()=>navigate(-1));
  next?.addEventListener('click',()=>navigate(1));
  dots.forEach((dot,i)=>dot.addEventListener('click',()=>{show(i,i>=active?1:-1);start();}));
  carousel.addEventListener('focusin',stop);
  carousel.addEventListener('focusout',event=>{if(!carousel.contains(event.relatedTarget))start();});
  carousel.addEventListener('keydown',event=>{
   if(event.key==='ArrowLeft'){event.preventDefault();navigate(-1);}
   if(event.key==='ArrowRight'){event.preventDefault();navigate(1);}
  });
  carousel.addEventListener('pointerdown',event=>{pointerStart=event.clientX;});
  carousel.addEventListener('pointerup',event=>{
   if(pointerStart===null)return;
   const distance=event.clientX-pointerStart;
   pointerStart=null;
   if(Math.abs(distance)>45){swiped=true;navigate(distance<0?1:-1);window.setTimeout(()=>{swiped=false;},400);}
  });
  carousel.addEventListener('click',event=>{if(swiped){event.preventDefault();event.stopPropagation();}},true);
  document.addEventListener('visibilitychange',()=>{if(document.hidden)stop();else if(!carousel.contains(document.activeElement))start();});
  show(active,1,true);
  start();
  let resizeTimer=null;
  window.addEventListener('resize',()=>{
   window.clearTimeout(resizeTimer);
   resizeTimer=window.setTimeout(()=>setViewportHeight(active,true),100);
  });
 });
});
document.addEventListener('DOMContentLoaded',()=>{
 document.querySelectorAll('[data-password-toggle]').forEach(button=>{
  button.addEventListener('click',()=>{
   const input=document.getElementById(button.dataset.passwordToggle);
   if(!input)return;
   const show=input.type==='password';
   input.type=show?'text':'password';
   button.setAttribute('aria-label',show?'Ocultar senha':'Mostrar senha');
   button.setAttribute('aria-pressed',String(show));
  });
 });
});
document.addEventListener('DOMContentLoaded',()=>{
 const trigger=document.querySelector('[data-location-open]');
 const dialog=document.querySelector('#location-dialog');
 const form=document.querySelector('[data-location-form]');
 const cityInput=document.querySelector('#location-city-input');
 const cepInput=document.querySelector('#location-cep-input');
 const cityDisplay=document.querySelector('[data-location-city]');
 if(!trigger||!dialog||!form||!cityInput||!cepInput||!cityDisplay)return;
 const locationKey='alvorada-delivery-location';
 const applyLocation=location=>{
  const city=(location?.cidade||'São Paulo').trim();
  cityDisplay.textContent=city;
  cityInput.value=city;
  cepInput.value=location?.cep||'';
  trigger.setAttribute('aria-label',`Entregar para ${city}${location?.cep?`, CEP ${location.cep}`:''}. Clique para alterar.`);
 };
 try{applyLocation(JSON.parse(localStorage.getItem(locationKey)||'null'));}catch{applyLocation(null);}
 window.addEventListener('alvorada-customer-state-loaded',()=>{try{applyLocation(JSON.parse(localStorage.getItem(locationKey)||'null'));}catch{applyLocation(null);}});
 trigger.addEventListener('click',event=>{
  event.preventDefault();
  dialog.showModal();
  cityInput.focus();
 });
 dialog.querySelectorAll('[data-location-close]').forEach(button=>button.addEventListener('click',()=>dialog.close()));
 form.addEventListener('submit',async event=>{
  event.preventDefault();
  if(!form.reportValidity())return;
  const status=form.querySelector('[data-location-status]');
  const cep=cepInput.value.trim();
  let location={cidade:cityInput.value.trim(),cep};
  if(cep){
   if(!window.AlvoradaCep){if(status)status.textContent='Não foi possível iniciar a consulta do CEP.';return;}
   try{if(status)status.textContent='Localizando CEP…';const found=await window.AlvoradaCep.lookup(cep);location={...location,cidade:found.city,cep:found.cep,latitude:found.latitude,longitude:found.longitude,logradouro:found.street,bairro:found.district,uf:found.state};cityInput.value=found.city;}
   catch(error){if(status)status.textContent=error.message||'Não foi possível localizar este CEP.';return;}
  }
  if(!location.cidade)return;
  try{localStorage.setItem(locationKey,JSON.stringify(location));}catch{}
  window.AlvoradaCustomerState?.sync();
  applyLocation(location);
  if(status)status.textContent='';
  dialog.close();
 });
 dialog.addEventListener('click',event=>{if(event.target===dialog)dialog.close();});
});

document.addEventListener('DOMContentLoaded',()=>{
 const storageKey='alvorada-favorites';
 const dialog=document.querySelector('#favorites-dialog');
 const openButton=document.querySelector('[data-favorites-open]');
 const list=document.querySelector('[data-favorites-list]');
 const empty=document.querySelector('[data-favorites-empty]');
 const count=document.querySelector('[data-favorites-count]');
 if(!dialog||!openButton||!list||!empty||!count)return;
 const read=()=>{
  try{
   const value=JSON.parse(localStorage.getItem(storageKey)||'[]');
   return Array.isArray(value)?[...new Set(value.map(Number).filter(Number.isInteger))]:[];
  }catch{return [];}
 };
 const save=items=>{try{localStorage.setItem(storageKey,JSON.stringify(items));window.AlvoradaCustomerState?.sync();}catch{}};
 const productCards=()=>[...document.querySelectorAll('.product[data-id]')];
 productCards().forEach(card=>{
  if(card.querySelector('[data-favorite-toggle]'))return;
  const button=document.createElement('button');
  button.type='button';
  button.className='favorite-toggle';
  button.dataset.favoriteToggle=card.dataset.id;
  button.setAttribute('aria-pressed','false');
  button.innerHTML='<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8l1.1 1.1L12 21l7.8-7.5 1.1-1.1a5.5 5.5 0 0 0-.1-7.8Z"/></svg>';
  card.append(button);
 });
 const render=()=>{
  const ids=read().filter(id=>productCards().some(card=>Number(card.dataset.id)===id));
  count.textContent=String(ids.length);
  count.hidden=ids.length===0;
  productCards().forEach(card=>{
   const button=card.querySelector('[data-favorite-toggle]');
   if(!button)return;
   const liked=ids.includes(Number(card.dataset.id));
   button.classList.toggle('is-liked',liked);
   button.setAttribute('aria-pressed',String(liked));
   button.setAttribute('aria-label',`${liked?'Remover dos curtidos':'Curtir'}: ${card.dataset.name||'produto'}`);
  });
  list.replaceChildren();
  empty.hidden=ids.length>0;
  ids.forEach(id=>{
   const card=productCards().find(item=>Number(item.dataset.id)===id);
   if(!card)return;
   const row=document.createElement('div');
   row.className='favorite-item';
   const name=document.createElement('span');
   name.className='favorite-item-name';
   name.textContent=card.dataset.name||'Produto';
   const view=document.createElement('button');
   view.type='button';
   view.className='favorite-view';
   view.dataset.favoriteView=String(id);
   view.textContent='Ver produto';
   const remove=document.createElement('button');
   remove.type='button';
   remove.className='favorite-remove';
   remove.dataset.favoriteRemove=String(id);
   remove.setAttribute('aria-label',`Remover ${card.dataset.name||'produto'} dos curtidos`);
   remove.textContent='Remover';
   row.append(name,view,remove);
   list.append(row);
  });
 };
 document.addEventListener('click',event=>{
  const button=event.target.closest('[data-favorite-toggle]');
  if(!button)return;
  const id=Number(button.dataset.favoriteToggle);
  const ids=read();
  save(ids.includes(id)?ids.filter(item=>item!==id):[...ids,id]);
  render();
 });
 list.addEventListener('click',event=>{
  const remove=event.target.closest('[data-favorite-remove]');
  if(remove){
   const id=Number(remove.dataset.favoriteRemove);
   save(read().filter(item=>item!==id));
   render();
   return;
  }
  const view=event.target.closest('[data-favorite-view]');
  if(view){
   const id=Number(view.dataset.favoriteView);
   dialog.close();
   window.setTimeout(()=>{
    const cards=productCards().filter(card=>Number(card.dataset.id)===id);
    const target=cards.find(card=>!card.closest('.product-section')?.hidden)||cards[0];
    if(!target)return;
    const section=target.closest('.product-section');
    if(section)section.hidden=false;
    target.scrollIntoView({behavior:'smooth',block:'center'});
   },80);
  }
 });
 openButton.addEventListener('click',()=>{render();dialog.showModal();});
 dialog.querySelectorAll('[data-favorites-close]').forEach(button=>button.addEventListener('click',()=>dialog.close()));
 dialog.addEventListener('click',event=>{if(event.target===dialog)dialog.close();});
 render();
 window.addEventListener('alvorada-customer-state-loaded',render);
});

document.addEventListener('DOMContentLoaded',()=>{
 const requestedCategory=new URLSearchParams(window.location.search).get('categoria');
 if(!requestedCategory)return;
 if(requestedCategory==='ofertas'){
  document.querySelectorAll('.product-section').forEach(section=>section.hidden=false);
  document.querySelector('#ofertas')?.scrollIntoView({behavior:'smooth',block:'start'});
  return;
 }
 const categories=requestedCategory.split(',');
 document.querySelectorAll('.product-section').forEach(section=>{section.hidden=!categories.includes(section.dataset.slug);});
 document.querySelector('#produtos')?.scrollIntoView({behavior:'smooth',block:'start'});
});
