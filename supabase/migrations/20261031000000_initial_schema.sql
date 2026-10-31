-- yesChef - Supabase veritabanı şeması (taslak v1)
-- RLS politikaları ayrı bir adımda eklenecek.

create extension if not exists postgis;

-- ============ ENUM'LAR ============
create type service_location_t as enum ('own_kitchen', 'customer_place', 'both');
create type order_mode_t       as enum ('menu', 'custom', 'both');
create type delivery_t         as enum ('chef_delivers', 'customer_pickup', 'both');
create type ingredients_t      as enum ('customer', 'chef', 'both');
create type chef_status_t      as enum ('pending', 'active', 'suspended', 'banned', 'rejected');
create type request_status_t   as enum ('open', 'quoted', 'accepted', 'rejected', 'expired');
create type quote_status_t     as enum ('pending', 'accepted', 'rejected', 'expired');
create type order_status_t     as enum ('pending_payment', 'confirmed', 'completed',
                                        'cancelled_by_chef', 'chef_no_show', 'refunded');
create type payment_status_t   as enum ('pending', 'paid', 'failed', 'refunded');
create type sanction_t         as enum ('warning', 'suspension', 'ban');

-- ============ KULLANICILAR ============
create table profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text not null,
  phone       text,
  avatar_url  text,
  city        text check (city in ('Ankara', 'İstanbul')),
  is_chef     boolean not null default false,
  is_admin    boolean not null default false,
  created_at  timestamptz not null default now()
);

create table addresses (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references profiles(id) on delete cascade,
  title       text,                       -- "Ev", "İş"
  city        text not null,
  district    text not null,
  address_text text not null,
  location    geography(point, 4326),
  created_at  timestamptz not null default now()
);

-- ============ ŞEF ============
create table chef_profiles (
  user_id            uuid primary key references profiles(id) on delete cascade,
  status             chef_status_t not null default 'pending',
  bio                text,                -- özgeçmiş / hakkımda
  specialties        text[] default '{}', -- ['Türk', 'İtalyan', 'Vegan']
  service_location   service_location_t not null default 'both',
  order_mode         order_mode_t not null default 'both',
  delivery           delivery_t not null default 'both',
  ingredients_policy ingredients_t not null default 'both',
  delivery_fee       numeric(10,2) default 0,
  max_delivery_km    int,
  min_notice_hours   int not null default 24,
  max_guests         int,
  city               text not null,
  service_districts  text[] default '{}',
  location           geography(point, 4326), -- mutfak konumu (müşteriye gösterilmez)
  -- istatistikler (trigger ile güncellenir)
  rating_avg         numeric(3,2) default 0,
  rating_count       int default 0,
  completed_count    int default 0,
  cancelled_count    int default 0,
  suspended_until    timestamptz,
  payout_submerchant_key text,            -- iyzico/PayTR alt üye işyeri anahtarı
  application_note   text,                -- başvuru açıklaması
  approved_at        timestamptz,
  created_at         timestamptz not null default now()
);

create table chef_photos (
  id         uuid primary key default gen_random_uuid(),
  chef_id    uuid not null references chef_profiles(user_id) on delete cascade,
  url        text not null,
  caption    text,
  sort_order int default 0,
  created_at timestamptz not null default now()
);

-- Haftalık çalışma saatleri
create table chef_availability (
  id         uuid primary key default gen_random_uuid(),
  chef_id    uuid not null references chef_profiles(user_id) on delete cascade,
  weekday    smallint not null check (weekday between 0 and 6),
  start_time time not null,
  end_time   time not null
);

-- Kapalı günler
create table chef_blocked_dates (
  chef_id uuid not null references chef_profiles(user_id) on delete cascade,
  date    date not null,
  primary key (chef_id, date)
);

-- ============ MENÜ ============
create table menus (
  id                        uuid primary key default gen_random_uuid(),
  chef_id                   uuid not null references chef_profiles(user_id) on delete cascade,
  title                     text not null,
  description               text,
  cuisine                   text,
  price_with_ingredients    numeric(10,2),  -- kişi başı, malzeme şeften
  price_without_ingredients numeric(10,2),  -- kişi başı, malzeme müşteriden
  min_guests                int default 1,
  max_guests                int,
  cover_url                 text,
  is_active                 boolean not null default true,
  created_at                timestamptz not null default now(),
  check (price_with_ingredients is not null or price_without_ingredients is not null)
);

create table menu_items (
  id          uuid primary key default gen_random_uuid(),
  menu_id     uuid not null references menus(id) on delete cascade,
  course      text,                       -- başlangıç, ana yemek, tatlı
  name        text not null,
  description text,
  sort_order  int default 0
);

-- ============ ÖZEL TALEP & TEKLİF ============
create table custom_requests (
  id               uuid primary key default gen_random_uuid(),
  customer_id      uuid not null references profiles(id),
  chef_id          uuid not null references chef_profiles(user_id),
  description      text not null,
  event_at         timestamptz not null,
  guest_count      int not null,
  service_location service_location_t not null, -- own_kitchen / customer_place
  ingredients_by   ingredients_t not null,      -- customer / chef
  delivery         delivery_t,
  address_id       uuid references addresses(id),
  status           request_status_t not null default 'open',
  created_at       timestamptz not null default now()
);

create table quotes (
  id          uuid primary key default gen_random_uuid(),
  request_id  uuid not null references custom_requests(id) on delete cascade,
  chef_id     uuid not null references chef_profiles(user_id),
  price       numeric(10,2) not null,
  note        text,
  valid_until timestamptz not null,
  status      quote_status_t not null default 'pending',
  created_at  timestamptz not null default now()
);

-- ============ SİPARİŞ ============
create table orders (
  id                uuid primary key default gen_random_uuid(),
  customer_id       uuid not null references profiles(id),
  chef_id           uuid not null references chef_profiles(user_id),
  menu_id           uuid references menus(id),
  quote_id          uuid references quotes(id),
  scheduled_at      timestamptz not null,
  guest_count       int not null,
  service_location  service_location_t not null,
  ingredients_by    ingredients_t not null,
  delivery          delivery_t,
  address_id        uuid references addresses(id),
  -- tutarlar (sipariş anında dondurulur)
  subtotal          numeric(10,2) not null,
  delivery_fee      numeric(10,2) not null default 0,
  total             numeric(10,2) not null,
  commission_rate   numeric(5,4) not null,   -- 0.1500 = %15
  commission_amount numeric(10,2) not null,
  chef_payout       numeric(10,2) not null,
  status            order_status_t not null default 'pending_payment',
  terms_accepted_at timestamptz,              -- "onaydan sonra iptal yok" kabulü
  confirmed_at      timestamptz,
  completed_at      timestamptz,
  created_at        timestamptz not null default now(),
  check ((menu_id is not null) <> (quote_id is not null))  -- ya menü ya teklif
);

create table payments (
  id                  uuid primary key default gen_random_uuid(),
  order_id            uuid not null references orders(id),
  provider            text not null,         -- 'iyzico' / 'paytr'
  provider_payment_id text,
  amount              numeric(10,2) not null,
  status              payment_status_t not null default 'pending',
  paid_at             timestamptz,
  refunded_at         timestamptz,
  created_at          timestamptz not null default now()
);

-- ============ İPTAL & YAPTIRIM ============
create table chef_cancellations (
  id            uuid primary key default gen_random_uuid(),
  order_id      uuid not null unique references orders(id),
  chef_id       uuid not null references chef_profiles(user_id),
  excuse        text,                        -- profilde görünen mazeret (opsiyonel)
  is_late       boolean not null default false, -- 24 saatten az kala
  is_no_show    boolean not null default false,
  created_at    timestamptz not null default now()
);

create table chef_sanctions (
  id         uuid primary key default gen_random_uuid(),
  chef_id    uuid not null references chef_profiles(user_id),
  type       sanction_t not null,
  reason     text,
  until      timestamptz,                    -- askı bitişi
  created_by uuid references profiles(id),  -- null = otomatik
  created_at timestamptz not null default now()
);

-- ============ YORUM ============
create table reviews (
  id          uuid primary key default gen_random_uuid(),
  order_id    uuid not null unique references orders(id),
  customer_id uuid not null references profiles(id),
  chef_id     uuid not null references chef_profiles(user_id),
  rating      smallint not null check (rating between 1 and 5),
  comment     text,
  chef_reply  text,
  created_at  timestamptz not null default now()
);

-- ============ MESAJLAŞMA ============
create table conversations (
  id          uuid primary key default gen_random_uuid(),
  customer_id uuid not null references profiles(id),
  chef_id     uuid not null references chef_profiles(user_id),
  request_id  uuid references custom_requests(id),
  order_id    uuid references orders(id),
  created_at  timestamptz not null default now()
);

create table messages (
  id              uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references conversations(id) on delete cascade,
  sender_id       uuid not null references profiles(id),
  body            text not null,
  read_at         timestamptz,
  created_at      timestamptz not null default now()
);

-- ============ İNDEKSLER ============
create index on chef_profiles (status, city);
create index on chef_profiles using gist (location);
create index on addresses using gist (location);
create index on menus (chef_id) where is_active;
create index on orders (chef_id, scheduled_at);
create index on orders (customer_id, created_at desc);
create index on custom_requests (chef_id, status);
create index on messages (conversation_id, created_at);
create index on reviews (chef_id, created_at desc);
