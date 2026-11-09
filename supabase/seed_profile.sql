-- yesChef - TEST VERİSİ 2: yorumlar ve bir iptal (seed.sql'den sonra, bir kez çalıştır)
-- Silmek için (önce bu, sonra seed.sql'deki silme komutu):
--   delete from reviews            where customer_id = '33333333-0000-0000-0000-000000000001';
--   delete from chef_cancellations where order_id in (select id from orders where customer_id = '33333333-0000-0000-0000-000000000001');
--   delete from orders             where customer_id = '33333333-0000-0000-0000-000000000001';
--   delete from auth.users         where email like '%@yeschef.test';

-- Test müşterisi
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
                        raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
                        confirmation_token, recovery_token, email_change_token_new, email_change)
values ('00000000-0000-0000-0000-000000000000', '33333333-0000-0000-0000-000000000001',
        'authenticated', 'authenticated', 'musteri@yeschef.test', '', now(),
        '{"provider":"email","providers":["email"]}', '{"full_name":"Deniz Koç"}',
        now(), now(), '', '', '', '')
on conflict (id) do nothing;

-- Tamamlanmış siparişler ve bir şef iptali
insert into orders (id, customer_id, chef_id, menu_id, scheduled_at, guest_count, service_location,
                    ingredients_by, subtotal, total, commission_rate, commission_amount, chef_payout,
                    status, completed_at)
values
  ('44444444-0000-0000-0000-000000000001', '33333333-0000-0000-0000-000000000001',
   '11111111-0000-0000-0000-000000000001', '22222222-0000-0000-0000-000000000001',
   now() - interval '20 days', 4, 'customer_place', 'customer', 800, 800, 0.15, 120, 680,
   'completed', now() - interval '20 days'),
  ('44444444-0000-0000-0000-000000000002', '33333333-0000-0000-0000-000000000001',
   '11111111-0000-0000-0000-000000000001', '22222222-0000-0000-0000-000000000002',
   now() - interval '5 days', 2, 'own_kitchen', 'chef', 600, 650, 0.15, 97.5, 552.5,
   'completed', now() - interval '5 days'),
  ('44444444-0000-0000-0000-000000000003', '33333333-0000-0000-0000-000000000001',
   '11111111-0000-0000-0000-000000000003', '22222222-0000-0000-0000-000000000004',
   now() - interval '10 days', 2, 'own_kitchen', 'chef', 1300, 1340, 0.15, 201, 1139,
   'completed', now() - interval '10 days'),
  ('44444444-0000-0000-0000-000000000004', '33333333-0000-0000-0000-000000000001',
   '11111111-0000-0000-0000-000000000001', '22222222-0000-0000-0000-000000000001',
   now() - interval '40 days', 6, 'customer_place', 'chef', 2100, 2100, 0.15, 315, 1785,
   'cancelled_by_chef', null)
on conflict (id) do nothing;

insert into reviews (order_id, customer_id, chef_id, rating, comment, chef_reply, created_at)
values
  ('44444444-0000-0000-0000-000000000001', '33333333-0000-0000-0000-000000000001',
   '11111111-0000-0000-0000-000000000001', 5,
   'Kuru fasulye annemin yaptığı gibiydi. Mutfağı da tertemiz bıraktı.',
   'Çok teşekkür ederim, yine beklerim!', now() - interval '19 days'),
  ('44444444-0000-0000-0000-000000000002', '33333333-0000-0000-0000-000000000001',
   '11111111-0000-0000-0000-000000000001', 4,
   'Kahvaltı çok güzeldi, börek biraz geç geldi.', null, now() - interval '4 days'),
  ('44444444-0000-0000-0000-000000000003', '33333333-0000-0000-0000-000000000001',
   '11111111-0000-0000-0000-000000000003', 5,
   'Tagliatelle gerçekten el açması, tiramisu efsane.', null, now() - interval '9 days')
on conflict (order_id) do nothing;

insert into chef_cancellations (order_id, chef_id, excuse, is_late, created_at)
values ('44444444-0000-0000-0000-000000000004', '11111111-0000-0000-0000-000000000001',
        'Ailevi bir acil durum nedeniyle gelemedim, müşterimden özür dilerim.', true,
        now() - interval '41 days')
on conflict (order_id) do nothing;
