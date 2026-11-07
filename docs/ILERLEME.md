# yesChef — İlerleme

> Yapılanlar, yapılacaklar ve ertelenenler. Her iş bittiğinde güncellenir.

## Yapıldı

| Tarih | İş | Not |
|---|---|---|
| 2026-10-31 | GitHub reposu kuruldu | `azermert/yesChef` |
| 2026-10-31 | İlk veritabanı şeması | `supabase/migrations/20261031000000_initial_schema.sql` — kullanıcılar, şef profilleri, menüler, talepler, teklifler, siparişler, ödemeler, iptaller, yorumlar, mesajlar. Henüz Supabase'e uygulanmadı. |
| 2026-10-31 | Yetki kuralları (RLS) | `supabase/migrations/20261031000001_auth_and_rls.sql` — henüz Supabase'e uygulanmadı. |
| 2026-10-31 | Flutter iskeleti | Alt menü, şef / müşteri modu geçişi. Ekranlar boş (yer tutucu). |
| 2026-10-31 | E-posta + şifre giriş ekranı | Kodda duruyor, şu an kullanılmıyor. |
| 2026-11-06 | Uygulama emülatörde ilk kez çalıştı | Android Studio snap güncellemesinden sonra Flutter JDK'yı bulamadı. Çözüm: `flutter config --jdk-dir=/snap/android-studio/current/jbr` |
| 2026-11-06 | Giriş zorunluluğu kaldırıldı | Uygulama direkt ana ekrana açılıyor. |
| 2026-11-07 | Keşfet ekranı (K1–K8) | Branch: `feature/kesfet`. Konum seçimi, arama, kategori çipleri, filtreler, sıralama, 3 bölüm (yakınındaki / en yüksek puan / yeni). Filtre ve sıralama Supabase'de `discover_chefs` fonksiyonunda. Kart tıklanınca şef profili yer tutucusu açılır. |
| 2026-11-07 | Migration 3 ve test verisi | `20261107000000_discover.sql`: şefe `district` alanı, Keşfet fonksiyonu, koruma trigger'larında düzeltme (SQL Editor'dan yapılan güncellemeleri engelliyordu). `supabase/seed.sql`: 8 test şefi ve menüleri. |
| 2026-11-06 | Karar ve ilerleme dokümanları | `docs/KARARLAR.md`, `docs/ILERLEME.md`. Eski `docs/PROJE.md` bu ikisine bölündü. |

## Sırada

- [x] Keşfet ekranı kararları (K1–K9)
- [ ] Keşfet ekranını emülatörde test etmek
- [ ] Şef profili ekranını konuşmak

## Ertelendi

| İş | Neden / Ne zaman |
|---|---|
| Google ile giriş | Giriş şimdilik gerekli değil, sonra eklenecek. |
| Arayüz tasarımı | Şu anki görünüm kötü; işlevler oturunca toparlanacak. |
| Ödeme entegrasyonu | Yönteme sonra karar verilecek. |
| Supabase'e şemanın uygulanması | Ekranlar netleşince; şema da değişebilir. |
| Şef başvuru ve admin onay süreci | Sonra konuşulacak. |
| Keşfet'te tarih ve kişi sayısı filtreleri | Şef takvimi gerektiriyor; ilk sürümden sonra (K9). |
| Puan / iptal oranı hesaplamaları | Sipariş akışı netleşince. Test şeflerinde puanlar elle girildi. |
| Telefon konumu (GPS) ile "yakınındaki" | Şimdilik "yakın" = seçilen ilçe şefin ilçesi veya hizmet bölgesi içinde. Konum izni sonra. |
| Ne için aranıyor kategorileri (günlük / davet / özel gün) | Şef verisinde bu bilgi yok; şimdilik kategoriler mutfak türü. |
