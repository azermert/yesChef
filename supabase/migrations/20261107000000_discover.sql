-- yesChef - Keşfet ekranı (K1-K8)

-- Şefin kendi ilçesi (kartta görünür, K5)
alter table chef_profiles add column if not exists district text;

-- Düzeltme: Koruma trigger'ları sadece uygulama kullanıcılarını kısıtlasın.
-- SQL Editor / Edge Function (auth.uid() boş) üzerinden yapılan güncellemeler engellenmesin.
create or replace function public.protect_profile_flags()
returns trigger language plpgsql as $$
begin
  if auth.uid() is not null and not public.is_admin() then
    new.is_chef := old.is_chef;
    new.is_admin := old.is_admin;
  end if;
  return new;
end;
$$;

create or replace function public.protect_chef_fields()
returns trigger language plpgsql as $$
begin
  if auth.uid() is not null and not public.is_admin() then
    new.status          := old.status;
    new.rating_avg      := old.rating_avg;
    new.rating_count    := old.rating_count;
    new.completed_count := old.completed_count;
    new.cancelled_count := old.cancelled_count;
    new.suspended_until := old.suspended_until;
    new.approved_at     := old.approved_at;
    new.payout_submerchant_key := old.payout_submerchant_key;
  end if;
  return new;
end;
$$;

-- Keşfet: filtreleme ve sıralama sunucuda yapılır. Şefin konumu dışarı verilmez.
--  p_service:     'come' (evime gelsin) | 'deliver' (getirsin) | 'pickup' (gidip alayım)
--  p_ingredients: 'customer' (ben alırım) | 'chef' (şef alsın)
--  p_order_mode:  'menu' | 'custom'
--  p_sort:        'recommended' | 'rating' | 'nearest' | 'price' | 'newest'
create or replace function public.discover_chefs(
  p_city        text,
  p_district    text    default null,
  p_search      text    default null,
  p_cuisine     text    default null,
  p_service     text    default null,
  p_ingredients text    default null,
  p_order_mode  text    default null,
  p_min_price   numeric default null,
  p_max_price   numeric default null,
  p_sort        text    default 'recommended',
  p_limit       int     default 50
)
returns table (
  user_id            uuid,
  full_name          text,
  avatar_url         text,
  city               text,
  district           text,
  specialties        text[],
  rating_avg         numeric,
  rating_count       int,
  completed_count    int,
  cancelled_count    int,
  service_location   text,
  delivery           text,
  ingredients_policy text,
  order_mode         text,
  min_price          numeric,
  is_near            boolean,
  is_new             boolean
)
language sql stable security definer set search_path = public as $$
  with base as (
    select
      c.user_id, p.full_name, p.avatar_url, c.city, c.district, c.specialties,
      c.rating_avg, c.rating_count, c.completed_count, c.cancelled_count,
      c.service_location::text as service_location,
      c.delivery::text         as delivery,
      c.ingredients_policy::text as ingredients_policy,
      c.order_mode::text       as order_mode,
      c.approved_at,
      (select min(case
                    when p_ingredients = 'customer' then m.price_without_ingredients
                    when p_ingredients = 'chef'     then m.price_with_ingredients
                    else least(m.price_with_ingredients, m.price_without_ingredients)
                  end)
         from menus m
        where m.chef_id = c.user_id and m.is_active) as min_price,
      coalesce(p_district is not null
               and (c.district = p_district or p_district = any(c.service_districts)), false) as is_near
    from chef_profiles c
    join profiles p on p.id = c.user_id
    where c.status = 'active'
      and c.city = p_city
      and (p_cuisine is null or p_cuisine = any(c.specialties))
      and (p_service is null
           or (p_service = 'come'    and c.service_location in ('customer_place', 'both'))
           or (p_service = 'deliver' and c.service_location in ('own_kitchen', 'both')
                                     and c.delivery in ('chef_delivers', 'both'))
           or (p_service = 'pickup'  and c.service_location in ('own_kitchen', 'both')
                                     and c.delivery in ('customer_pickup', 'both')))
      and (p_ingredients is null or c.ingredients_policy in (p_ingredients::ingredients_t, 'both'))
      and (p_order_mode  is null or c.order_mode in (p_order_mode::order_mode_t, 'both'))
      and (coalesce(p_search, '') = ''
           or p.full_name ilike '%' || p_search || '%'
           or array_to_string(c.specialties, ' ') ilike '%' || p_search || '%'
           or exists (select 1 from menus m
                       where m.chef_id = c.user_id and m.is_active
                         and (m.title ilike '%' || p_search || '%'
                              or m.cuisine ilike '%' || p_search || '%'
                              or exists (select 1 from menu_items i
                                          where i.menu_id = m.id
                                            and i.name ilike '%' || p_search || '%'))))
  ),
  scored as (
    select b.*,
      (b.completed_count + b.cancelled_count) < 3 as is_new,
      -- Önerilen: puan %50 + tamamlanma oranı %30 + yakınlık %20
      (coalesce(nullif(b.rating_avg, 0), 3.5) / 5 * 0.5
       + case when b.completed_count + b.cancelled_count = 0 then 0.9
              else b.completed_count::numeric / (b.completed_count + b.cancelled_count) end * 0.3
       + case when b.is_near then 0.2 else 0 end) as score
    from base b
    where (p_min_price is null or b.min_price >= p_min_price)
      and (p_max_price is null or b.min_price <= p_max_price)
  )
  select s.user_id, s.full_name, s.avatar_url, s.city, s.district, s.specialties,
         s.rating_avg, s.rating_count, s.completed_count, s.cancelled_count,
         s.service_location, s.delivery, s.ingredients_policy, s.order_mode,
         s.min_price, s.is_near, s.is_new
  from scored s
  order by
    case when p_sort = 'nearest' then s.is_near::int end desc,
    case when p_sort = 'rating'  then s.rating_avg end desc nulls last,
    case when p_sort = 'price'   then s.min_price end asc nulls last,
    case when p_sort = 'newest'  then s.approved_at end desc nulls last,
    s.score desc
  limit p_limit;
$$;

grant execute on function public.discover_chefs to anon, authenticated;
