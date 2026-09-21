-- Mellali Scent: stable admin save function (v2)
-- Run this once in Supabase SQL Editor.

drop function if exists public.admin_save_product_v2(text,text,text,text,text,text,text);

create or replace function public.admin_save_product_v2(
  p_password text,
  p_id text,
  p_name text,
  p_price text,
  p_category text,
  p_image text,
  p_description text default ''
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if encode(digest(p_password,'sha256'),'hex') <> '8c37052d474bd02b693faac977beb5f7b283a67398fed713454a211793034c8c' then
    raise exception 'invalid admin password';
  end if;

  insert into public.products(id,name,price,category,image,description)
  values(p_id,p_name,coalesce(nullif(p_price,''),'Prix à ajouter'),p_category,coalesce(p_image,''),coalesce(p_description,''))
  on conflict(id) do update set
    name=excluded.name,
    price=excluded.price,
    category=excluded.category,
    image=excluded.image,
    description=excluded.description;

  return jsonb_build_object('success',true,'id',p_id);
end;
$$;

grant execute on function public.admin_save_product_v2(text,text,text,text,text,text,text) to anon, authenticated;

notify pgrst, 'reload schema';
