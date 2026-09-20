const WHATSAPP="212697413699";

const products=[
{id:1,name:"Royal Oud",brand:"Mellali Scent",category:"homme",type:"parfums",price:249,image:"images/royal-oud.jpg"},
{id:2,name:"Velvet Rose",brand:"Mellali Scent",category:"femme",type:"parfums",price:229,image:"images/velvet-rose.jpg"},
{id:3,name:"Élixir Noir",brand:"Mellali Scent",category:"unisex",type:"parfums",price:279,image:"images/elixir-noir.jpg"},
{id:4,name:"Pure Musk",brand:"Mellali Scent",category:"unisex",type:"parfums",price:199,image:"images/pure-musk.jpg"},
{id:5,name:"Golden Bloom",brand:"Mellali Scent",category:"femme",type:"parfums",price:259,image:"images/golden-bloom.jpg"},
{id:6,name:"Black Intense",brand:"Mellali Scent",category:"homme",type:"parfums",price:269,image:"images/black-intense.jpg"},
{id:7,name:"Échantillon Royal",brand:"Mellali Scent",category:"unisex",type:"echantillons",price:39,image:"images/echantillon-royal.jpg"},
{id:8,name:"Échantillon Rose",brand:"Mellali Scent",category:"femme",type:"echantillons",price:39,image:"images/echantillon-rose.jpg"},
{id:9,name:"Échantillon Oud",brand:"Mellali Scent",category:"homme",type:"echantillons",price:45,image:"images/echantillon-oud.jpg"},
{id:10,name:"Miniature Élégance",brand:"Mellali Scent",category:"femme",type:"miniatures",price:89,image:"images/miniature-elegance.jpg"},
{id:11,name:"Miniature Oud",brand:"Mellali Scent",category:"homme",type:"miniatures",price:99,image:"images/miniature-oud.jpg"},
{id:12,name:"Miniature Collection",brand:"Mellali Scent",category:"unisex",type:"miniatures",price:159,image:"images/miniature-collection.jpg"}
];

let cart=JSON.parse(localStorage.getItem("mellaliCartV3")||"[]");
const $=id=>document.getElementById(id);
function money(n){return n.toLocaleString("fr-MA")+" DH"}

function renderProducts(list, target="products"){
 const el=$(target);
 if(!el)return;
 el.innerHTML=list.map(p=>`<article class="product">
   <div class="product-img" style="background-image:url('${p.image}')"><span class="tag">${p.category}</span></div>
   <div class="product-body"><h3>${p.name}</h3><div class="brand-name">${p.brand}</div>
   <div class="price">${money(p.price)}</div><div class="stars">★★★★★ <small>(4.8)</small></div>
   <button class="add" onclick="addToCart(${p.id})">🛒 &nbsp; Ajouter au panier</button></div>
 </article>`).join("");
}

function addToCart(id){let x=cart.find(i=>i.id===id);x?x.qty++:cart.push({id,qty:1});save();openCart()}
function save(){localStorage.setItem("mellaliCartV3",JSON.stringify(cart));renderCart()}
function removeFromCart(id){cart=cart.filter(x=>x.id!==id);save()}
function renderCart(){
 if(!$("cartItems"))return;
 if(!cart.length)$("cartItems").innerHTML='<div class="empty">Votre panier est vide.</div>';
 else $("cartItems").innerHTML=cart.map(x=>{let p=products.find(y=>y.id===x.id);return `<div class="cart-item"><div class="cart-thumb" style="background-image:url('${p.image}')"></div><div><h4>${p.name}</h4><p>${x.qty} × ${money(p.price)}</p><button class="remove" onclick="removeFromCart(${p.id})">Supprimer</button></div><strong>${money(p.price*x.qty)}</strong></div>`}).join("");
 const count=cart.reduce((a,x)=>a+x.qty,0),total=cart.reduce((a,x)=>a+x.qty*products.find(p=>p.id===x.id).price,0);
 if($("cartCount"))$("cartCount").textContent=count;
 if($("cartTotal"))$("cartTotal").textContent=money(total);
}
function openCart(){$("cart")?.classList.add("open");$("overlay")?.classList.add("open")}
function closeCart(){$("cart")?.classList.remove("open");$("overlay")?.classList.remove("open")}
$("cartBtn")?.addEventListener("click",openCart);
$("closeCart")?.addEventListener("click",closeCart);
$("overlay")?.addEventListener("click",closeCart);
$("clearCart")?.addEventListener("click",()=>{cart=[];save()});
$("checkout")?.addEventListener("click",()=>{
 if(!cart.length)return alert("Votre panier est vide.");
 let msg="Bonjour Mellali Scent 👋%0A%0AJe souhaite commander :%0A";
 cart.forEach(x=>{let p=products.find(y=>y.id===x.id);msg+=`- ${p.name} x${x.qty} : ${p.price*x.qty} DH%0A`});
 let total=cart.reduce((a,x)=>a+x.qty*products.find(p=>p.id===x.id).price,0);
 msg+=`%0ATotal : ${total} DH%0A%0ANom :%0ATéléphone :%0AVille :%0AAdresse :`;
 window.open(`https://wa.me/${WHATSAPP}?text=${msg}`,"_blank");
});
if($("year"))$("year").textContent=new Date().getFullYear();
renderCart();
