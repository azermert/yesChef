-- yesChef - Şef profili (P1-P5)

-- ============ FAVORİLER (P4) ============
create table if not exists favorites (
  customer_id uuid not null references profiles(id) on delete cascade,
  chef_id     uuid not null references chef_profiles(user_id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (customer_id, chef_id)
);

alter table favorites enable row level security;

create policy "favori: sahibi okur" on favorites for select using (customer_id = auth.uid());
create policy "favori: sahibi ekler" on favorites for insert with check (customer_id = auth.uid());
create policy "favori: sahibi siler" on favorites for delete using (customer_id = auth.uid());

-- ============ PROFİL VERİSİ ============
-- Profil ekranının ihtiyacı olan her şeyi tek seferde döner. Şefin konumu dışarı verilmez.
-- Yorumlarda müşterinin sadece adı ve soyadının baş harfi görünür.
create or replace function public.get_chef_profile(p_chef_id uuid)
returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object(
    'user_id',            c.user_id,
    'full_name',          p.full_name,
    'avatar_url',         p.avatar_url,
    'city',               c.city,
    'district',           c.district,
    'service_districts',  c.service_districts,
    'bio',                c.bio,
    'specialties',        c.specialties,
    'service_location',   c.service_location,
    'order_mode',         c.order_mode,
    'delivery',           c.delivery,
    'ingredients_policy', c.ingredients_policy,
    'delivery_fee',       c.delivery_fee,
    'max_delivery_km',    c.max_delivery_km,
    'min_notice_hours',   c.min_notice_hours,
    'rating_avg',         c.rating_avg,
    'rating_count',       c.rating_count,
    'completed_count',    c.completed_count,
    'cancelled_count',    c.cancelled_count,
    'is_favorite',        exists (select 1 from favorites f
                                   where f.customer_id = auth.uid() and f.chef_id = c.user_id),
    'menus', coalesce((
      select jsonb_agg(jsonb_build_object(
               'id', m.id,
               'title', m.title,
               'description', m.description,
               'cuisine', m.cuisine,
               'price_with_ingredients', m.price_with_ingredients,
               'price_without_ingredients', m.price_without_ingredients,
               'min_guests', m.min_guests,
               'max_guests', m.max_guests,
               'cover_url', m.cover_url,
               'items', coalesce((
                 select jsonb_agg(jsonb_build_object(
                          'course', i.course, 'name', i.name, 'description', i.description)
                        order by i.sort_order)
                 from menu_items i where i.menu_id = m.id), '[]'::jsonb)
             ) order by m.created_at)
      from menus m where m.chef_id = c.user_id and m.is_active), '[]'::jsonb),
    'photos', coalesce((
      select jsonb_agg(jsonb_build_object('url', ph.url, 'caption', ph.caption) order by ph.sort_order)
      from chef_photos ph where ph.chef_id = c.user_id), '[]'::jsonb),
    'reviews', coalesce((
      select jsonb_agg(r order by r.created_at desc) from (
        select rv.rating, rv.comment, rv.chef_reply, rv.created_at,
               split_part(cp.full_name, ' ', 1)
                 || coalesce(' ' || left(nullif(split_part(cp.full_name, ' ', 2), ''), 1) || '.', '')
                 as customer_name
        from reviews rv join profiles cp on cp.id = rv.customer_id
        where rv.chef_id = c.user_id
        order by rv.created_at desc
        limit 5) r), '[]'::jsonb),
    'cancellations', coalesce((
      select jsonb_agg(x order by x.created_at desc) from (
        select cc.excuse, cc.is_late, cc.is_no_show, cc.created_at
        from chef_cancellations cc
        where cc.chef_id = c.user_id
        order by cc.created_at desc
        limit 20) x), '[]'::jsonb)
  )
  from chef_profiles c
  join profiles p on p.id = c.user_id
  where c.user_id = p_chef_id
    and (c.status = 'active' or c.user_id = auth.uid() or public.is_admin());
$$;

grant execute on function public.get_chef_profile to anon, authenticated;

-- Tüm yorumlar ("Tümünü gör")
create or replace function public.get_chef_reviews(p_chef_id uuid, p_limit int default 50, p_offset int default 0)
returns table (rating smallint, comment text, chef_reply text, created_at timestamptz, customer_name text)
language sql stable security definer set search_path = public as $$
  select rv.rating, rv.comment, rv.chef_reply, rv.created_at,
         split_part(cp.full_name, ' ', 1)
           || coalesce(' ' || left(nullif(split_part(cp.full_name, ' ', 2), ''), 1) || '.', '')
  from reviews rv join profiles cp on cp.id = rv.customer_id
  where rv.chef_id = p_chef_id
  order by rv.created_at desc
  limit p_limit offset p_offset;
$$;

grant execute on function public.get_chef_reviews to anon, authenticated;
