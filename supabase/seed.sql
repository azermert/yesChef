-- yesChef - TEST VERİSİ (yayına çıkmadan önce silinecek)
-- 8 örnek şef (4 Ankara, 4 İstanbul) ve menüleri. Bu hesaplarla giriş yapılamaz.
--
-- Silmek için:
--   delete from auth.users where email like '%@yeschef.test';

-- 1) Kullanıcılar (profil kaydı trigger ile otomatik oluşur)
insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
                        raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
                        confirmation_token, recovery_token, email_change_token_new, email_change)
select '00000000-0000-0000-0000-000000000000', v.id::uuid, 'authenticated', 'authenticated',
       v.email, '', now(), '{"provider":"email","providers":["email"]}'::jsonb,
       jsonb_build_object('full_name', v.name), now(), now(), '', '', '', ''
from (values
  ('11111111-0000-0000-0000-000000000001', 'sef1@yeschef.test', 'Ayşe Yılmaz'),
  ('11111111-0000-0000-0000-000000000002', 'sef2@yeschef.test', 'Mehmet Kaya'),
  ('11111111-0000-0000-0000-000000000003', 'sef3@yeschef.test', 'Elif Demir'),
  ('11111111-0000-0000-0000-000000000004', 'sef4@yeschef.test', 'Hasan Çelik'),
  ('11111111-0000-0000-0000-000000000005', 'sef5@yeschef.test', 'Zeynep Arslan'),
  ('11111111-0000-0000-0000-000000000006', 'sef6@yeschef.test', 'Can Öztürk'),
  ('11111111-0000-0000-0000-000000000007', 'sef7@yeschef.test', 'Selin Aydın'),
  ('11111111-0000-0000-0000-000000000008', 'sef8@yeschef.test', 'Burak Şahin')
) as v(id, email, name)
on conflict (id) do nothing;

-- 2) Şef profilleri
insert into chef_profiles (user_id, status, approved_at, city, district, service_districts, bio, specialties,
                           service_location, order_mode, delivery, ingredients_policy, delivery_fee,
                           rating_avg, rating_count, completed_count, cancelled_count)
values
  ('11111111-0000-0000-0000-000000000001', 'active', now() - interval '200 days', 'Ankara', 'Çankaya',
   '{Çankaya,Yenimahalle}', 'Annemden öğrendiğim ev yemeklerini 15 yıldır yapıyorum.',
   '{Ev yemeği,Türk}', 'both', 'both', 'both', 'both', 50, 4.8, 42, 41, 1),
  ('11111111-0000-0000-0000-000000000002', 'active', now() - interval '120 days', 'Ankara', 'Yenimahalle',
   '{Yenimahalle,Etimesgut}', 'Otel mutfaklarında 10 yıl çalıştım. Davet ve özel günler için menü hazırlarım.',
   '{Türk,Izgara}', 'customer_place', 'both', 'both', 'both', 0, 4.6, 18, 17, 1),
  ('11111111-0000-0000-0000-000000000003', 'active', now() - interval '60 days', 'Ankara', 'Çankaya',
   '{Çankaya}', 'İtalyan mutfağına aşığım; makarnayı her zaman elde açarım.',
   '{İtalyan}', 'own_kitchen', 'menu', 'chef_delivers', 'chef', 40, 4.9, 25, 25, 0),
  ('11111111-0000-0000-0000-000000000004', 'active', now() - interval '5 days', 'Ankara', 'Keçiören',
   '{Keçiören}', 'Yeni katıldım. Tatlı ve hamur işlerinde iddialıyım.',
   '{Tatlı,Hamur işi}', 'own_kitchen', 'both', 'customer_pickup', 'chef', 0, 0, 0, 0, 0),
  ('11111111-0000-0000-0000-000000000005', 'active', now() - interval '300 days', 'İstanbul', 'Kadıköy',
   '{Kadıköy,Üsküdar}', 'Vegan ve sağlıklı mutfak üzerine çalışıyorum.',
   '{Vegan,Sağlıklı}', 'both', 'both', 'both', 'both', 60, 4.7, 56, 53, 3),
  ('11111111-0000-0000-0000-000000000006', 'active', now() - interval '90 days', 'İstanbul', 'Beşiktaş',
   '{Beşiktaş,Şişli}', 'Uzak Doğu mutfağı, özellikle Japon ve Tay yemekleri.',
   '{Uzak Doğu}', 'customer_place', 'custom', 'both', 'chef', 0, 4.5, 12, 10, 2),
  ('11111111-0000-0000-0000-000000000007', 'active', now() - interval '150 days', 'İstanbul', 'Üsküdar',
   '{Üsküdar,Kadıköy}', 'Ege otları ve zeytinyağlılar. Deniz ürünlerinde uzmanım.',
   '{Deniz ürünleri,Ege}', 'own_kitchen', 'menu', 'both', 'chef', 70, 4.8, 30, 30, 0),
  ('11111111-0000-0000-0000-000000000008', 'active', now() - interval '3 days', 'İstanbul', 'Şişli',
   '{Şişli,Beşiktaş}', 'Yeni katıldım. Ev yemeği ve günlük menüler.',
   '{Ev yemeği}', 'both', 'both', 'both', 'customer', 0, 0, 0, 0, 0)
on conflict (user_id) do nothing;

-- 3) Menüler (kişi başı fiyat: malzemeli / malzemesiz)
insert into menus (id, chef_id, title, description, cuisine, price_with_ingredients, price_without_ingredients)
values
  ('22222222-0000-0000-0000-000000000001', '11111111-0000-0000-0000-000000000001', 'Klasik Ev Menüsü', 'Mercimek çorbası, kuru fasulye, pilav, cacık', 'Türk', 350, 200),
  ('22222222-0000-0000-0000-000000000002', '11111111-0000-0000-0000-000000000001', 'Pazar Kahvaltısı', 'Menemen, börek, peynir tabağı, reçeller', 'Türk', 300, 180),
  ('22222222-0000-0000-0000-000000000003', '11111111-0000-0000-0000-000000000002', 'Davet Menüsü', 'Ara sıcaklar, kuzu tandır, baklava', 'Türk', 900, 500),
  ('22222222-0000-0000-0000-000000000004', '11111111-0000-0000-0000-000000000003', 'İtalyan Akşamı', 'Bruschetta, el açması tagliatelle, tiramisu', 'İtalyan', 650, null),
  ('22222222-0000-0000-0000-000000000005', '11111111-0000-0000-0000-000000000004', 'Tatlı Kutusu', 'Ev yapımı baklava, sütlaç, kurabiye', 'Tatlı', 250, null),
  ('22222222-0000-0000-0000-000000000006', '11111111-0000-0000-0000-000000000005', 'Vegan Tadım', 'Humus, mercimek köftesi, kinoa salatası, chia puding', 'Vegan', 450, 280),
  ('22222222-0000-0000-0000-000000000007', '11111111-0000-0000-0000-000000000007', 'Ege Sofrası', 'Zeytinyağlılar, levrek buğulama, ot kavurma', 'Deniz ürünleri', 850, null),
  ('22222222-0000-0000-0000-000000000008', '11111111-0000-0000-0000-000000000008', 'Günlük Menü', 'Çorba, ana yemek, salata', 'Türk', null, 180)
on conflict (id) do nothing;

insert into menu_items (menu_id, course, name, sort_order)
values
  ('22222222-0000-0000-0000-000000000001', 'Çorba', 'Mercimek çorbası', 1),
  ('22222222-0000-0000-0000-000000000001', 'Ana yemek', 'Kuru fasulye', 2),
  ('22222222-0000-0000-0000-000000000001', 'Yan', 'Pirinç pilavı', 3),
  ('22222222-0000-0000-0000-000000000003', 'Ana yemek', 'Kuzu tandır', 1),
  ('22222222-0000-0000-0000-000000000003', 'Tatlı', 'Baklava', 2),
  ('22222222-0000-0000-0000-000000000004', 'Ana yemek', 'Tagliatelle', 1),
  ('22222222-0000-0000-0000-000000000004', 'Tatlı', 'Tiramisu', 2),
  ('22222222-0000-0000-0000-000000000005', 'Tatlı', 'Baklava', 1),
  ('22222222-0000-0000-0000-000000000006', 'Ana yemek', 'Mercimek köftesi', 1),
  ('22222222-0000-0000-0000-000000000007', 'Ana yemek', 'Levrek buğulama', 1);
