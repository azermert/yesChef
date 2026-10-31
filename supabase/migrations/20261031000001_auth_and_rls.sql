-- yesChef - Kayıt tetikleyicisi ve Row Level Security (v1)

-- ============ YARDIMCI FONKSİYONLAR ============
create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select coalesce((select is_admin from profiles where id = auth.uid()), false);
$$;

create or replace function public.is_active_chef(uid uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from chef_profiles where user_id = uid and status = 'active');
$$;

-- ============ KAYIT OLAN HERKESE PROFİL ============
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into profiles (id, full_name, phone)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', ''), new.phone);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Kullanıcı kendi rol bayraklarını değiştiremesin
create or replace function public.protect_profile_flags()
returns trigger language plpgsql as $$
begin
  if not public.is_admin() then
    new.is_chef := old.is_chef;
    new.is_admin := old.is_admin;
  end if;
  return new;
end;
$$;

create trigger profiles_protect_flags
  before update on profiles
  for each row execute function public.protect_profile_flags();

-- Şef yalnızca admin tarafından aktive edilir; şef kendi durumunu/istatistiklerini değiştiremez
create or replace function public.protect_chef_fields()
returns trigger language plpgsql as $$
begin
  if not public.is_admin() then
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

create trigger chef_profiles_protect_fields
  before update on chef_profiles
  for each row execute function public.protect_chef_fields();

-- Admin onaylayınca profile şef bayrağı eklenir
create or replace function public.sync_chef_flag()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  update profiles set is_chef = (new.status in ('active', 'suspended')) where id = new.user_id;
  return new;
end;
$$;

create trigger chef_profiles_sync_flag
  after insert or update of status on chef_profiles
  for each row execute function public.sync_chef_flag();

-- ============ RLS AÇ ============
alter table profiles            enable row level security;
alter table addresses           enable row level security;
alter table chef_profiles       enable row level security;
alter table chef_photos         enable row level security;
alter table chef_availability   enable row level security;
alter table chef_blocked_dates  enable row level security;
alter table menus               enable row level security;
alter table menu_items          enable row level security;
alter table custom_requests     enable row level security;
alter table quotes              enable row level security;
alter table orders              enable row level security;
alter table payments            enable row level security;
alter table chef_cancellations  enable row level security;
alter table chef_sanctions      enable row level security;
alter table reviews             enable row level security;
alter table conversations       enable row level security;
alter table messages            enable row level security;

-- ============ PROFİLLER ============
create policy "profil: herkes okur" on profiles for select using (true);
create policy "profil: kendini günceller" on profiles for update using (id = auth.uid());

create policy "adres: sahibi" on addresses for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ============ ŞEF ============
-- Aktif şefler herkese açık; şef kendi kaydını, admin hepsini görür.
-- Not: konum (location) uygulamada view üzerinden gizlenecek.
create policy "şef: aktifleri herkes okur" on chef_profiles for select
  using (status = 'active' or user_id = auth.uid() or public.is_admin());
create policy "şef: başvuru oluşturur" on chef_profiles for insert
  with check (user_id = auth.uid() and status = 'pending');
create policy "şef: kendini günceller" on chef_profiles for update
  using (user_id = auth.uid() or public.is_admin());

create policy "galeri: herkes okur" on chef_photos for select using (true);
create policy "galeri: şef yönetir" on chef_photos for all
  using (chef_id = auth.uid()) with check (chef_id = auth.uid());

create policy "müsaitlik: herkes okur" on chef_availability for select using (true);
create policy "müsaitlik: şef yönetir" on chef_availability for all
  using (chef_id = auth.uid()) with check (chef_id = auth.uid());

create policy "kapalı gün: herkes okur" on chef_blocked_dates for select using (true);
create policy "kapalı gün: şef yönetir" on chef_blocked_dates for all
  using (chef_id = auth.uid()) with check (chef_id = auth.uid());

-- ============ MENÜ ============
create policy "menü: aktifleri herkes okur" on menus for select
  using ((is_active and public.is_active_chef(chef_id)) or chef_id = auth.uid());
create policy "menü: şef yönetir" on menus for all
  using (chef_id = auth.uid()) with check (chef_id = auth.uid());

create policy "menü kalemi: herkes okur" on menu_items for select using (true);
create policy "menü kalemi: şef yönetir" on menu_items for all
  using (exists (select 1 from menus m where m.id = menu_id and m.chef_id = auth.uid()))
  with check (exists (select 1 from menus m where m.id = menu_id and m.chef_id = auth.uid()));

-- ============ TALEP & TEKLİF ============
create policy "talep: taraflar okur" on custom_requests for select
  using (customer_id = auth.uid() or chef_id = auth.uid() or public.is_admin());
create policy "talep: müşteri oluşturur" on custom_requests for insert
  with check (customer_id = auth.uid() and public.is_active_chef(chef_id));
create policy "talep: taraflar günceller" on custom_requests for update
  using (customer_id = auth.uid() or chef_id = auth.uid());

create policy "teklif: taraflar okur" on quotes for select
  using (chef_id = auth.uid()
         or exists (select 1 from custom_requests r where r.id = request_id and r.customer_id = auth.uid())
         or public.is_admin());
create policy "teklif: şef verir" on quotes for insert
  with check (chef_id = auth.uid()
              and exists (select 1 from custom_requests r where r.id = request_id and r.chef_id = auth.uid()));

-- ============ SİPARİŞ & ÖDEME ============
-- Sipariş oluşturma, ödeme, iptal ve durum değişiklikleri Edge Function (service role) üzerinden yapılır.
create policy "sipariş: taraflar okur" on orders for select
  using (customer_id = auth.uid() or chef_id = auth.uid() or public.is_admin());

create policy "ödeme: müşteri ve admin okur" on payments for select
  using (public.is_admin()
         or exists (select 1 from orders o where o.id = order_id and o.customer_id = auth.uid()));

-- ============ İPTAL & YAPTIRIM ============
create policy "iptal: herkes okur" on chef_cancellations for select using (true);  -- mazeret profilde görünür
create policy "iptal: şef mazeret günceller" on chef_cancellations for update
  using (chef_id = auth.uid());

create policy "yaptırım: şef ve admin okur" on chef_sanctions for select
  using (chef_id = auth.uid() or public.is_admin());
create policy "yaptırım: admin yazar" on chef_sanctions for insert
  with check (public.is_admin());

-- ============ YORUM ============
create policy "yorum: herkes okur" on reviews for select using (true);
create policy "yorum: müşteri tamamlanan siparişe yazar" on reviews for insert
  with check (customer_id = auth.uid()
              and exists (select 1 from orders o
                          where o.id = order_id and o.customer_id = auth.uid()
                            and o.chef_id = reviews.chef_id and o.status = 'completed'));
create policy "yorum: şef cevap verir" on reviews for update
  using (chef_id = auth.uid());

-- ============ MESAJLAŞMA ============
create policy "sohbet: taraflar okur" on conversations for select
  using (customer_id = auth.uid() or chef_id = auth.uid());
create policy "sohbet: müşteri başlatır" on conversations for insert
  with check (customer_id = auth.uid());

create policy "mesaj: taraflar okur" on messages for select
  using (exists (select 1 from conversations c where c.id = conversation_id
                 and (c.customer_id = auth.uid() or c.chef_id = auth.uid())));
create policy "mesaj: taraflar yazar" on messages for insert
  with check (sender_id = auth.uid()
              and exists (select 1 from conversations c where c.id = conversation_id
                          and (c.customer_id = auth.uid() or c.chef_id = auth.uid())));

-- Gerçek zamanlı mesajlaşma
alter publication supabase_realtime add table messages;
