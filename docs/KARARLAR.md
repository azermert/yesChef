# yesChef — Kararlar

> Alınan her karar buraya eklenir. Bir karar değişirse eskisi silinmez, üstü çizilir ve yenisi tarihiyle yazılır.

## 1. Çalışma Şekli

| # | Karar | Tarih |
|---|---|---|
| Ç1 | Önce neyin, nasıl yapılacağı konuşulur ve karar verilir; kod sonra yazılır. | 2026-11-06 |
| Ç2 | Mert "yaz" demeden kod yazılmaz, commit atılmaz. | 2026-11-06 |
| Ç3 | Her iş ayrı bir branch'te yapılır. Mert inceler, onaylarsa `main`'e merge edilir. `main`'e doğrudan commit atılmaz. | 2026-11-06 |
| Ç4 | Alınan kararlar bu dokümanda, yapılan / ertelenen işler `docs/ILERLEME.md`'de tutulur. | 2026-11-06 |

## 2. Ürün

| # | Karar | Tarih |
|---|---|---|
| Ü1 | Uygulama müşterileri özel şef / aşçı / iyi yemek yapan hizmet sağlayıcılarla buluşturur. "Yemeksepeti'nin özel şef versiyonu." | 2026-10-31 |
| Ü2 | Taraflar: müşteri, şef, admin. | 2026-10-31 |
| Ü3 | **Esneklik ilkesi:** Uygulama sabit kural koymaz; çalışma şekli şefin profilindeki tercihtir ve müşteriye filtre olarak sunulur. | 2026-10-31 |
| Ü4 | Hizmet yeri: şefin kendi mutfağı / müşterinin yeri / ikisi (şef seçer). | 2026-10-31 |
| Ü5 | Sipariş tipi: sabit menüden sipariş / özel talep + teklif / ikisi (şef seçer). | 2026-10-31 |
| Ü6 | Teslimat: şef getirir / müşteri gelip alır / ikisi (şef seçer). | 2026-10-31 |
| Ü7 | Malzeme: müşteri temin eder (şef sadece pişirir) veya şef temin eder. Şef fiyatı buna göre verir. | 2026-10-31 |
| Ü8 | Şef olmak için profesyonel olma şartı yok. Başta seçici, manuel onay; uzun vadede puan ve yorumlar eleme yapar. | 2026-10-31 |
| Ü9 | Şef profilinde özgeçmiş / hakkımda alanı bulunur. | 2026-10-31 |
| Ü10 | Pazar: başlangıçta Ankara ve İstanbul. | 2026-10-31 |

## 3. Ödeme ve İptal

| # | Karar | Tarih |
|---|---|---|
| Ö1 | Gelir modeli: komisyon. | 2026-10-31 |
| Ö2 | Ödeme sadece uygulama üzerinden yapılır. | 2026-10-31 |
| Ö3 | Müşteri onay verdiği anda ücret çekilir. Onaydan sonra müşteri iptal edemez. Bu kural onay ekranında açıkça yazılır. Amaç: operasyon yükü çıkarmamak. | 2026-10-31 |
| Ö4 | Ödeme altyapısı: en az uğraştıran yöntem seçilecek. Şimdilik başlanmayacak. | 2026-10-31 |
| Ö5 | Şef iptal ederse müşteriye tam iade. | 2026-10-31 |
| Ö6 | Şefin profilinde iptal bilgisi görünür (ör. "10 siparişten 1'i iptal"). Şef isterse mazeret yazar, ama mazeret puan düşüşünü engellemez. | 2026-10-31 |
| Ö7 | Sürekli iptal eden şef askıya alınır veya sistemden atılır. | 2026-10-31 |

## 4. Teknoloji

| # | Karar | Tarih |
|---|---|---|
| T1 | Mobil: Flutter. | 2026-10-31 |
| T2 | Backend: Supabase (şimdilik). | 2026-10-31 |
| T3 | Tek uygulama; müşteri ve şef ayrı uygulama değil. Kullanıcı şef / müşteri modu arasında geçer. | 2026-10-31 |
| T4 | Kod GitHub'da: `azermert/yesChef`. | 2026-10-31 |
| T5 | Giriş şimdilik zorunlu değil. İleride Google ile giriş gibi bir yöntem eklenecek. | 2026-11-06 |

## 5. Önerildi, Henüz Onaylanmadı

Konuşuldu ama net karar verilmedi; ileride tartışılacak.

- Şef iptalinde kademeli yaptırım: uyarı → askı → kapatma, eşikler sonra belirlenecek.
- Son dakika iptali (24 saatten az) ve gelmemenin daha ağır sayılması.
- Az siparişi olan şeflerde oran yerine "Yeni şef" etiketi.
- Ödeme için iyzico veya PayTR pazaryeri modeli.
- Supabase bölgesi Frankfurt (KVKK).
- Bildirimler için Firebase Cloud Messaging.
- Herkes müşteri olarak kayıt olur, "Şef ol" ile başvurur (Airbnb modeli).
- Alt menü sekmeleri (müşteri: Keşfet · Siparişlerim · Mesajlar · Hesabım; şef: Talepler · Takvim · Menülerim · Mesajlar · Hesabım).
- Flutter paketleri: Riverpod, go_router.
- Admin için basit bir web paneli.
- Cayma hakkı kuralının avukata teyit ettirilmesi.
