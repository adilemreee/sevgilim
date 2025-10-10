# Hızlı Başlangıç Rehberi

Bu rehber, uygulamayı hızlıca çalıştırmak için gereken adımları içerir.

## ⚡ 5 Dakikada Başlangıç

### 1. Firebase Projesi Oluşturun (2 dakika)

1. [Firebase Console](https://console.firebase.google.com)'a gidin
2. "Add project" → Proje adı girin → Oluştur
3. iOS uygulaması ekle
4. Bundle ID: `com.sevgilim.app`
5. `GoogleService-Info.plist` dosyasını indirin

### 2. Firebase Servislerini Aktifleştirin (2 dakika)

**Authentication:**
- Firebase Console → Authentication → Get Started
- Sign-in method → Email/Password → Enable

**Firestore:**
- Firebase Console → Firestore Database → Create Database
- Test mode → Start collection: "users"

**Storage:**
- Firebase Console → Storage → Get Started
- Test mode → Start

### 3. Xcode Projesini Ayarlayın (1 dakika)

1. Projeyi Xcode'da açın:
```bash
cd sevgilim
open sevgilim.xcodeproj
```

2. Firebase SDK ekleyin:
   - File → Add Packages...
   - URL: `https://github.com/firebase/firebase-ios-sdk`
   - Version: Latest
   - Paketler: FirebaseAuth, FirebaseFirestore, FirebaseStorage

3. `GoogleService-Info.plist`'i projeye ekleyin:
   - İndirdiğiniz dosyayı `sevgilim` klasörüne sürükleyin
   - "Copy items if needed" seçeneğini işaretleyin

4. Çalıştırın! (⌘+R)

## 🎯 İlk Adımlar

### Kullanıcı Oluşturma

1. Uygulamayı çalıştırın
2. "Kayıt Ol" butonuna tıklayın
3. Bilgilerinizi girin:
   - İsim: Adil
   - E-posta: adil@example.com
   - Şifre: test123456

4. Partner davet edin:
   - Partner e-posta: emre@example.com
   - İlişki başlangıç tarihi seçin

5. İkinci kullanıcı oluşturun:
   - Uygulamadan çıkış yapın
   - "Kayıt Ol" ile ikinci kullanıcıyı oluşturun
   - E-posta: emre@example.com
   - Gelen daveti kabul edin

### Temel Özellikler

**Fotoğraf Ekle:**
1. Fotoğraflar sekmesi → + butonu
2. Fotoğraf seç → Kaydet

**Anı Oluştur:**
1. Anılar sekmesi → + butonu
2. Başlık ve içerik gir → Kaydet

**Not Ekle:**
1. Notlar sekmesi → + butonu
2. Başlık ve içerik gir → Kaydet

**Film Ekle:**
1. Filmler sekmesi → + butonu
2. Film adı gir → Puan ver → Kaydet

**Plan Oluştur:**
1. Planlar sekmesi → + butonu
2. Plan detayları gir → Kaydet

## 🔧 Önemli Ayarlar

### Güvenlik Kuralları (ÖNEMLİ!)

Test modundan production'a geçmeden önce güvenlik kurallarını ekleyin:

**Firestore Rules:**
1. Firebase Console → Firestore → Rules
2. [FIREBASE_SETUP.md](FIREBASE_SETUP.md) dosyasındaki kuralları kopyalayın
3. Publish

**Storage Rules:**
1. Firebase Console → Storage → Rules
2. [FIREBASE_SETUP.md](FIREBASE_SETUP.md) dosyasındaki kuralları kopyalayın
3. Publish

### Simülatör vs Gerçek Cihaz

**Simülatörde:**
- Kamera özelliği çalışmaz (galeri çalışır)
- Push notifications test edilemez

**Gerçek Cihazda:**
- Tüm özellikler çalışır
- Developer hesabı gerekir

## 🐛 Sık Karşılaşılan Sorunlar

### "GoogleService-Info.plist not found"
**Çözüm:** Dosyanın Xcode projesinde olduğundan emin olun. Build Phases → Copy Bundle Resources'a eklenmiş olmalı.

### "Firebase app has not been configured"
**Çözüm:** `FirebaseApp.configure()` çağrısının `sevgilimApp.swift` dosyasında olduğundan emin olun.

### "Permission denied" hatası
**Çözüm:** Firebase güvenlik kurallarının doğru yapılandırıldığından emin olun.

### Fotoğraf yüklenmiyor
**Çözüm:** 
- Storage'ın aktif olduğunu kontrol edin
- Storage güvenlik kurallarının doğru olduğunu kontrol edin
- İnternet bağlantınızı kontrol edin

### Davet gönderilemiyor
**Çözüm:**
- Firestore'un aktif olduğunu kontrol edin
- E-posta adresinin doğru olduğunu kontrol edin

## 📱 Test Senaryosu

Uygulamayı test etmek için:

1. ✅ İki farklı kullanıcı oluşturun
2. ✅ Birinci kullanıcı ikinci kullanıcıyı davet etsin
3. ✅ İkinci kullanıcı daveti kabul etsin
4. ✅ Her iki kullanıcı da birbirinin eklediği içeriği görebilmeli
5. ✅ Fotoğraf ekleyin ve her iki kullanıcıda da görünmeli
6. ✅ Anı ekleyin ve beğenin/yorum yapın
7. ✅ Not oluşturup düzenleyin
8. ✅ Film ekleyin ve puan verin
9. ✅ Plan oluşturup tamamlayın
10. ✅ Tema değiştirin
11. ✅ Profil fotoğrafı yükleyin

## 🎨 Tema Değiştirme

1. Profil sekmesi → Tema
2. Beğendiğiniz temayı seçin:
   - Romantik (Pembe)
   - Gün Batımı (Turuncu)
   - Okyanus (Mavi)
   - Orman (Yeşil)
   - Lavanta (Mor)

## 📊 Verileri Görüntüleme

Firebase Console'da verilerinizi görebilirsiniz:

**Kullanıcılar:**
- Firestore → users collection

**İlişkiler:**
- Firestore → relationships collection

**Anılar:**
- Firestore → memories collection

**Fotoğraflar:**
- Storage → relationships/{relationshipId}/photos

## 🚀 Üretim İçin Hazırlık

1. [ ] GoogleService-Info.plist'i .gitignore'a ekleyin (✅ Zaten eklendi)
2. [ ] Güvenlik kurallarını production için ayarlayın
3. [ ] Test kullanıcılarını silin
4. [ ] App Store için build ayarlarını yapın
5. [ ] Privacy Policy ve Terms of Service ekleyin
6. [ ] App Store açıklaması ve ekran görüntüleri hazırlayın

## 💡 İpuçları

- **Offline Mod:** Uygulama internet bağlantısı olmadan da çalışır, veriler sync olur
- **Gerçek Zamanlı:** Bir kullanıcı veri eklediğinde diğer kullanıcı anında görür
- **Güvenlik:** Sadece ilişkideki iki kullanıcı verilere erişebilir
- **Yedekleme:** Tüm veriler Firebase'de güvenle saklanır

## 📚 Ek Kaynaklar

- [Detaylı Firebase Kurulum](FIREBASE_SETUP.md)
- [README](README.md)
- [Firebase Documentation](https://firebase.google.com/docs)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

## 🎉 Hepsi Bu Kadar!

Artık uygulamanız hazır! Sevdiklerinizle anılarınızı paylaşmaya başlayabilirsiniz.

Sorularınız için Firebase Console'daki logları ve Xcode Console'u kontrol edin.

