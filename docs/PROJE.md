# yesChef — Proje Dokümanı

> Bu doküman projede yapılan her işi ve alınan her kararı tutar. Her adımda güncellenir.

## 1. Amaç

Müşterileri özel şef / aşçı / iyi yemek yapan hizmet sağlayıcılarla buluşturan mobil uygulama. "Yemeksepeti'nin özel şef versiyonu."

## 2. Taraflar

- **Müşteri:** Şef bulur, menüden sipariş verir veya özel talep oluşturur, öder, puanlar.
- **Şef:** Profil, menü, fiyat, müsaitlik ve tercihlerini yönetir; talepleri karşılar.
- **Admin:** Şef onayı, askı/kapatma, şikayetler (başta basit web paneli).

## 3. Ürün Kararları

### Esneklik ilkesi
Uygulama sabit kural koymaz; her çalışma şekli **şef profilinde bir tercihtir** ve müşteriye filtre olarak sunulur.

| Konu | Seçenekler |
|---|---|
| Hizmet yeri | Şefin kendi mutfağı / müşterinin yeri / ikisi |
| Sipariş tipi | Sabit menü / özel talep (teklif) / ikisi |
| Teslimat | Şef getirir / müşteri alır / ikisi |
| Malzeme | Müşteri temin eder / şef temin eder / ikisi (fiyat buna göre değişir) |

### Şef kabulü
- Profesyonel olma şartı yok.
- Başlangıçta seçici, manuel onay (başvuru + örnek yemek fotoğrafları).
- Uzun vadede puan ve yorumlar kaliteyi belirler.

### Şef profili
Fotoğraf, ad, şehir/ilçe · Hakkımda/özgeçmiş · Uzmanlık mutfakları · Çalışma tercihleri · Menüler ve fiyatlar (malzemeli/malzemesiz) · Galeri · Puan, yorumlar, tamamlanma oranı.

### Ödeme ve iptal
- Ödeme **sadece uygulama içinden**.
- Müşteri onay verdiği anda ücret çekilir. **Onaydan sonra müşteri iptali yok.** Kural onay ekranında açıkça yazılır.
- Gelir modeli: **komisyon**.
- Sağlayıcı: iyzico veya PayTR pazaryeri modeli (en az operasyon yükü çıkaran seçilecek; henüz karar verilmedi).
- ⚠️ Cayma hakkı kuralı yayın öncesi avukata teyit ettirilecek.

### Şef iptali
- Müşteriye otomatik tam iade.
- Profilde **tamamlanma oranı** görünür (ör. "10 siparişten 9'u tamamlandı").
- Şef isterse **mazeret** yazar; mazeret puan düşüşünü kaldırmaz.
- Son dakika iptali (24 saatten az) ve gelmeme daha ağır sayılır.
- Yeni şeflerde oran yerine "Yeni şef" etiketi.
- Kademeli yaptırım (eşikler sonra ayarlanacak): uyarı → askı → kapatma (admin onayıyla).

### Pazar
Başlangıç: **Ankara ve İstanbul**.

## 4. Teknoloji

- **Mobil:** Flutter (tek uygulama, iOS + Android)
- **Backend:** Supabase (Auth, Postgres + PostGIS, Storage, Realtime, Edge Functions)
- **Bildirim:** Firebase Cloud Messaging
- **Ödeme:** iyzico / PayTR (Edge Function üzerinden)
- **KVKK:** Supabase AB bölgesi (Frankfurt)

### Rol yapısı
Tek uygulama. Herkes müşteri olarak kayıt olur; "Şef ol" ile başvurur, onaylanınca şef rolü eklenir. Profil menüsünden **şef modu / müşteri modu** geçişi.

- Müşteri sekmeleri: Keşfet · Siparişlerim · Mesajlar · Hesabım
- Şef sekmeleri: Talepler · Takvim · Menülerim · Kazançlar · Mesajlar

## 5. Repo Yapısı

```
yesChef/
├── app/                  # Flutter uygulaması
├── supabase/migrations/  # veritabanı şeması, RLS, trigger'lar
└── docs/PROJE.md         # bu doküman
```

## 6. Veritabanı

İlk şema: `supabase/migrations/20261031000000_initial_schema.sql`

Tablolar: `profiles`, `addresses`, `chef_profiles`, `chef_photos`, `chef_availability`, `chef_blocked_dates`, `menus`, `menu_items`, `custom_requests`, `quotes`, `orders`, `payments`, `chef_cancellations`, `chef_sanctions`, `reviews`, `conversations`, `messages`.

## 7. İş Günlüğü

| Tarih | Yapılan |
|---|---|
| 2026-10-31 | Ürün kararları netleşti, teknoloji seçildi (Flutter + Supabase), ilk DB şeması yazıldı, repo kuruldu. |

## 8. Yapılacaklar

- [ ] Flutter projesini oluştur (`app/`)
- [ ] RLS politikaları
- [ ] Puan / tamamlanma oranı trigger'ları
- [ ] Kayıt / giriş ekranları
- [ ] Ödeme sağlayıcı seçimi (iyzico vs PayTR)
