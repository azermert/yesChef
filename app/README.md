# yesChef — Flutter uygulaması

## İlk kurulum (bir kez)

Platform klasörleri (android/, ios/) repoda yok, yerelde üretilir:

```bash
cd app
flutter create . --org com.yeschef --platforms=android,ios --project-name yeschef
flutter pub get
```

`flutter create` mevcut `lib/` ve `pubspec.yaml` dosyalarına dokunmaz, sadece eksikleri ekler. Oluşan `test/widget_test.dart` dosyasını silebilirsin.

## Çalıştırma

```bash
cp env.example.json env.json   # içine Supabase URL ve anon key yaz
flutter run --dart-define-from-file=env.json
```

`env.json` git'e gitmez.

## Klasör yapısı

```
lib/
├── main.dart          # başlangıç, Supabase init
├── app.dart           # MaterialApp, router, tema
├── core/              # ortak: env, tema, uygulama modu
└── features/          # ekranlar, özellik bazında
    └── shell/         # alt menü (müşteri/şef modu)
```
