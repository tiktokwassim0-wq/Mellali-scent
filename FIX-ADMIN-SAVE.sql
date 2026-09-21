DROP FUNCTION IF EXISTS public.admin_save_product(text,text,text,text,text,text,text);

CREATE OR REPLACE FUNCTION public.admin_save_product(
  p_category text,
  p_description text,
  p_id text,
  p_image text,
  p_name text,
  p_password text,
  p_price text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF p_password IS DISTINCT FROM 'MELLALI-7419' THEN
    RAISE EXCEPTION 'كلمة السر غير صحيحة';
  END IF;

  INSERT INTO public.products (id,name,price,category,image,description)
  VALUES (
    p_id,
    p_name,
    COALESCE(NULLIF(p_price,''),'Prix à ajouter'),
    p_category,
    COALESCE(p_image,''),
    COALESCE(p_description,'')
  )
  ON CONFLICT (id) DO UPDATE SET
    name=EXCLUDED.name,
    price=EXCLUDED.price,
    category=EXCLUDED.category,
    image=EXCLUDED.image,
    description=EXCLUDED.description;

  RETURN jsonb_build_object('success',true,'id',p_id,'name',p_name);
END;
$$;

GRANT EXECUTE ON FUNCTION public.admin_save_product(text,text,text,text,text,text,text)
TO anon, authenticated;

NOTIFY pgrst, 'reload schema';
