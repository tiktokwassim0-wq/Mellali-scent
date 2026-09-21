create extension if not exists pgcrypto;

create table if not exists public.products (id text primary key, name text not null, price text default 'Prix à ajouter', category text not null check (category in ('full','samples','mini')), image text default '', created_at timestamptz default now());
alter table public.products add column if not exists description text default '';
create table if not exists public.pages (id int primary key default 1, data jsonb not null default '{}'::jsonb, updated_at timestamptz default now());
create table if not exists public.contact (id int primary key default 1, data jsonb not null default '{}'::jsonb, updated_at timestamptz default now());

alter table public.products enable row level security;
alter table public.pages enable row level security;
alter table public.contact enable row level security;
drop policy if exists "public read products" on public.products;
create policy "public read products" on public.products for select to anon, authenticated using (true);
drop policy if exists "public read pages" on public.pages;
create policy "public read pages" on public.pages for select to anon, authenticated using (true);
drop policy if exists "public read contact" on public.contact;
create policy "public read contact" on public.contact for select to anon, authenticated using (true);
revoke insert, update, delete on public.products from anon, authenticated;
revoke insert, update, delete on public.pages from anon, authenticated;
revoke insert, update, delete on public.contact from anon, authenticated;

drop function if exists public.admin_save_product(text,text,text,text,text,text);
drop function if exists public.admin_save_product(text,text,text,text,text,text,text);
create or replace function public.admin_save_product(p_password text,p_id text,p_name text,p_price text,p_category text,p_image text,p_description text default '') returns public.products language plpgsql security definer set search_path=public as $$
begin
 if encode(digest(p_password,'sha256'),'hex') <> '8c37052d474bd02b693faac977beb5f7b283a67398fed713454a211793034c8c' then raise exception 'invalid admin password'; end if;
 insert into public.products(id,name,price,category,image,description) values(p_id,p_name,coalesce(nullif(p_price,''),'Prix à ajouter'),p_category,coalesce(p_image,''),coalesce(p_description,''))
 on conflict(id) do update set name=excluded.name,price=excluded.price,category=excluded.category,image=excluded.image,description=excluded.description;
 return (select p from public.products p where p.id=p_id);
end; $$;

drop function if exists public.admin_delete_product(text,text);
create or replace function public.admin_delete_product(p_password text,p_id text) returns boolean language plpgsql security definer set search_path=public as $$
begin
 if encode(digest(p_password,'sha256'),'hex') <> '8c37052d474bd02b693faac977beb5f7b283a67398fed713454a211793034c8c' then raise exception 'invalid admin password'; end if;
 delete from public.products where id=p_id; return true;
end; $$;

drop function if exists public.admin_save_pages(text,jsonb);
create or replace function public.admin_save_pages(p_password text,p_data jsonb) returns public.pages language plpgsql security definer set search_path=public as $$
begin
 if encode(digest(p_password,'sha256'),'hex') <> '8c37052d474bd02b693faac977beb5f7b283a67398fed713454a211793034c8c' then raise exception 'invalid admin password'; end if;
 insert into public.pages(id,data,updated_at) values(1,p_data,now()) on conflict(id) do update set data=excluded.data,updated_at=now(); return (select p from public.pages p where p.id=1);
end; $$;

drop function if exists public.admin_save_contact(text,jsonb);
create or replace function public.admin_save_contact(p_password text,p_data jsonb) returns public.contact language plpgsql security definer set search_path=public as $$
begin
 if encode(digest(p_password,'sha256'),'hex') <> '8c37052d474bd02b693faac977beb5f7b283a67398fed713454a211793034c8c' then raise exception 'invalid admin password'; end if;
 insert into public.contact(id,data,updated_at) values(1,p_data,now()) on conflict(id) do update set data=excluded.data,updated_at=now(); return (select c from public.contact c where c.id=1);
end; $$;

grant usage on schema public to anon, authenticated;
grant select on public.products,public.pages,public.contact to anon, authenticated;
grant execute on function public.admin_save_product(text,text,text,text,text,text,text), public.admin_delete_product(text,text), public.admin_save_pages(text,jsonb), public.admin_save_contact(text,jsonb) to anon, authenticated;

insert into public.pages(id,data) values(1,'{"homeTitle":"MELLALI SCENT","homeEyebrow":"BIENVENUE CHEZ","homeText":"Des parfums d’exception pour chaque instant.","fullTitle":"Parfums Complets","fullDesc":"Découvrez les parfums en format complet.","sampleTitle":"Échantillons","sampleDesc":"Testez vos fragrances avant de choisir votre format.","miniTitle":"Miniatures","miniDesc":"Des formats mini pour collectionner et découvrir.","aboutText":"Une sélection pensée pour les passionnés de parfums."}'::jsonb) on conflict(id) do nothing;
insert into public.contact(id,data) values(1,'{"wa":"0697413699","instagram":"mellali_scent_","tiktok":"mellali_scent_","about":"Une sélection pensée pour les passionnés de parfums."}'::jsonb) on conflict(id) do nothing;

-- Produits de démonstration modifiables depuis Admin
insert into public.products(id,name,price,category,image,description) values
('full-1','Élégance Noire','249 DH','full','','Une fragrance élégante et profonde, idéale pour les soirées et les grandes occasions.'),
('full-2','Velours Doré','279 DH','full','','Un parfum chaleureux aux notes douces et raffinées pour une signature chic.'),
('full-3','Bois Intense','229 DH','full','','Une composition boisée et moderne, avec une présence durable et élégante.'),
('full-4','Ambre Royal','299 DH','full','','Un accord ambré généreux, pensé pour celles et ceux qui aiment les parfums marquants.'),
('full-5','Fleur de Nuit','239 DH','full','','Une fragrance florale douce et lumineuse avec une touche mystérieuse.'),
('full-6','Cèdre Blanc','259 DH','full','','Un parfum frais et boisé, facile à porter au quotidien.'),
('full-7','Musc Signature','219 DH','full','','Une signature musquée propre et élégante, discrète mais remarquable.'),
('full-8','Santal Prestige','289 DH','full','','Un santal crémeux et sophistiqué pour une allure raffinée.'),
('samples-1','Découverte Élégance Noire','25 DH','samples','','Échantillon de découverte du parfum Élégance Noire.'),
('samples-2','Découverte Velours Doré','25 DH','samples','','Échantillon pratique pour tester Velours Doré avant de choisir le format complet.'),
('samples-3','Découverte Bois Intense','25 DH','samples','','Échantillon boisé à tester tranquillement.'),
('samples-4','Découverte Ambre Royal','30 DH','samples','','Petit format découverte d’un accord ambré chaleureux.'),
('samples-5','Découverte Fleur de Nuit','25 DH','samples','','Échantillon floral et élégant.'),
('samples-6','Découverte Cèdre Blanc','25 DH','samples','','Échantillon frais et boisé.'),
('samples-7','Découverte Musc Signature','25 DH','samples','','Échantillon musqué et propre.'),
('samples-8','Découverte Santal Prestige','30 DH','samples','','Échantillon d’un santal doux et sophistiqué.'),
('mini-1','Mini Élégance Noire','49 DH','mini','','Miniature élégante pour découvrir la fragrance partout.'),
('mini-2','Mini Velours Doré','49 DH','mini','','Petit format pratique aux notes chaleureuses.'),
('mini-3','Mini Bois Intense','45 DH','mini','','Miniature boisée et moderne.'),
('mini-4','Mini Ambre Royal','55 DH','mini','','Petit format d’un parfum ambré généreux.'),
('mini-5','Mini Fleur de Nuit','49 DH','mini','','Miniature florale douce et lumineuse.'),
('mini-6','Mini Cèdre Blanc','45 DH','mini','','Petit format frais et boisé.'),
('mini-7','Mini Musc Signature','45 DH','mini','','Miniature musquée et élégante.'),
('mini-8','Mini Santal Prestige','55 DH','mini','','Petit format sophistiqué au santal crémeux.')
on conflict(id) do update set name=excluded.name,price=excluded.price,description=excluded.description;
