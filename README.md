# Sevgilim - Çiftler İçin Anı Paylaşım Uygulaması

Modern, güzel tasarımlı bir iOS uygulaması. İki kişinin birlikte kullanıp anılarını, fotoğraflarını, notlarını ve planlarını paylaşabildiği bir platform.

## ✨ Özellikler

### 🔐 Hesap & Paylaşım
- Firebase Authentication ile güvenli giriş (E-posta/Şifre)
- Partner davet sistemi
- İki kullanıcının paylaşımlı "ilişki alanı"

### 🏠 Ana Sayfa
- Her iki kullanıcının ismi görünür (örn: "Adil ❤️ Emre")
- İlişki başlangıç tarihinden itibaren gün sayacı
- Detaylı zaman gösterimi (yıl, ay, gün formatında)
- Son aktiviteler listesi

### 📸 Fotoğraflar
- Firebase Storage ile güvenli fotoğraf depolama
- Grid layout fotoğraf galerisi
- Fotoğraf detayları: başlık, tarih, konum, etiketler
- Fotoğraf yükleme ve silme

### 💭 Anılar / Hatıralar
- Zaman sıralı anı kartları
- Her anıya fotoğraf eklenebilir
- Beğeni sistemi
- Yorum ekleme
- Konum ve etiket desteği

### 📝 Notlar
- Paylaşımlı not defteri
- Not oluşturma, düzenleme ve silme
- Otomatik güncelleme tarihi

### 🎬 İzlenen Filmler
- Film listesi
- 1-5 yıldız puanlama sistemi
- İzlenme tarihi kaydı
- Film notları

### 📅 Planlar / Yapılacaklar
- Ortak yapılacaklar listesi
- Tamamlanma takibi
- Tarih ve hatırlatıcı desteği
- Aktif ve tamamlanan planlar görünümü

### 👤 Profil & Ayarlar
- Profil fotoğrafı yükleme
- İsim düzenleme
- İlişki başlangıç tarihi düzenleme
- 5 farklı renk teması:
  - Romantik (Pembe tonları)
  - Gün Batımı (Turuncu-Sarı)
  - Okyanus (Mavi tonları)
  - Orman (Yeşil tonları)
  - Lavanta (Mor tonları)

### 🔄 Offline & Senkronizasyon
- Firestore offline desteği
- Otomatik senkronizasyon

### 🔒 Güvenlik
- Firestore güvenlik kuralları
- Sadece ilişkiye dahil kullanıcılar veriyi okuyabilir/yazabilir
- Storage güvenlik kuralları

## 🛠 Teknolojiler

- **Framework:** SwiftUI
- **Mimari:** MVVM (Model-View-ViewModel)
- **Backend:** Firebase
  - Authentication
  - Cloud Firestore
  - Storage
  - (Opsiyonel) Cloud Messaging
- **Minimum iOS Version:** iOS 16.0+
- **Language:** Swift 5.9+

## 📋 Gereksinimler

- Xcode 15.0 veya üzeri
- iOS 16.0+ cihaz veya simülatör
- CocoaPods veya Swift Package Manager
- Firebase hesabı

## 🚀 Kurulum

### 1. Projeyi İndirin

```bash
git clone https://github.com/YOUR_USERNAME/sevgilim.git
cd sevgilim
```

### 2. Firebase Kurulumu

Detaylı Firebase kurulum talimatları için [FIREBASE_SETUP.md](FIREBASE_SETUP.md) dosyasına bakın.

Özet:
1. Firebase Console'da yeni proje oluşturun
2. iOS uygulaması ekleyin
3. `GoogleService-Info.plist` dosyasını indirin ve projeye ekleyin
4. Firebase paketlerini Xcode'a ekleyin
5. Authentication, Firestore ve Storage'ı aktifleştirin
6. Güvenlik kurallarını ekleyin

### 3. Xcode'da Açın

```bash
open sevgilim.xcodeproj
```

### 4. Firebase Paketlerini Ekleyin

1. File → Add Packages...
2. URL: `https://github.com/firebase/firebase-ios-sdk`
3. Şu paketleri seçin:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseStorage

### 5. GoogleService-Info.plist'i Ekleyin

Firebase Console'dan indirdiğiniz `GoogleService-Info.plist` dosyasını projenin ana klasörüne ekleyin.

### 6. Derleyin ve Çalıştırın

Xcode'da `Cmd+R` ile uygulamayı çalıştırın.

## 📱 Kullanım

### İlk Kullanım

1. Uygulamayı açın
2. "Kayıt Ol" butonuna tıklayın
3. E-posta, şifre ve isminizi girin
4. Partner e-posta adresini girerek davet gönderin
5. Partneriniz daveti kabul ettikten sonra birlikte kullanmaya başlayın!

### Özellik Kullanımı

#### Fotoğraf Ekleme
1. Fotoğraflar sekmesine gidin
2. + butonuna tıklayın
3. Fotoğraf seçin
4. Başlık, konum ve etiket ekleyin
5. Kaydet

#### Anı Ekleme
1. Anılar sekmesine gidin
2. + butonuna tıklayın
3. Başlık ve içerik girin
4. İsteğe bağlı fotoğraf ekleyin
5. Kaydet

#### Tema Değiştirme
1. Profil sekmesine gidin
2. Tema'ya tıklayın
3. Beğendiğiniz temayı seçin

## 🏗 Proje Yapısı

```
sevgilim/
├── Models/
│   ├── User.swift
│   ├── Relationship.swift
│   ├── Memory.swift
│   ├── Photo.swift
│   ├── Note.swift
│   ├── Movie.swift
│   ├── Plan.swift
│   └── PartnerInvitation.swift
├── Services/
│   ├── AuthenticationService.swift
│   ├── RelationshipService.swift
│   ├── MemoryService.swift
│   ├── PhotoService.swift
│   ├── NoteService.swift
│   ├── MovieService.swift
│   ├── PlanService.swift
│   └── StorageService.swift
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   ├── RegisterView.swift
│   │   └── PartnerSetupView.swift
│   ├── Home/
│   │   └── HomeView.swift
│   ├── Photos/
│   │   └── PhotosView.swift
│   ├── Memories/
│   │   └── MemoriesView.swift
│   ├── Notes/
│   │   └── NotesView.swift
│   ├── Movies/
│   │   └── MoviesView.swift
│   ├── Plans/
│   │   └── PlansView.swift
│   ├── Profile/
│   │   └── ProfileView.swift
│   └── MainTabView.swift
├── Utilities/
│   ├── ThemeManager.swift
│   ├── DateExtensions.swift
│   └── ImagePicker.swift
├── ContentView.swift
└── sevgilimApp.swift
```

## 🎨 Temalar

Uygulama 5 farklı renk teması ile birlikte gelir:

1. **Romantik** - Pembe tonları
2. **Gün Batımı** - Turuncu ve sarı tonlar
3. **Okyanus** - Mavi tonları
4. **Orman** - Yeşil tonları
5. **Lavanta** - Mor tonları

Her tema otomatik olarak açık/karanlık moda uyum sağlar.

## 🔐 Güvenlik

- Tüm veriler Firebase güvenlik kuralları ile korunur
- Sadece ilişkiye dahil iki kullanıcı birbirlerinin verilerine erişebilir
- Profil fotoğrafları sadece ilgili kullanıcı tarafından yüklenebilir
- İlişki verileri (fotoğraflar, anılar, notlar vb.) sadece ilişkideki kullanıcılar tarafından erişilebilir

## 📄 Lisans

Bu proje özel kullanım içindir.

## 🤝 Katkıda Bulunma

Bu özel bir proje olduğu için katkılar kabul edilmemektedir.

## ⚠️ Önemli Notlar

1. **GoogleService-Info.plist:** Bu dosya hassas bilgiler içerir ve Git'e eklenmemelidir
2. **API Keys:** Tüm API anahtarları Firebase Console'da yönetilmelidir
3. **Test:** Üretim ortamına geçmeden önce tüm özellikleri test edin
4. **Güvenlik Kuralları:** Firebase güvenlik kurallarının aktif olduğundan emin olun

## 🐛 Bilinen Sorunlar

- Çok büyük fotoğraflar yüklenirken performans sorunu yaşanabilir (otomatik sıkıştırma eklenmeli)
- Offline modda bazı işlemler senkronizasyon gecikmesi yaşayabilir

## 🔮 Gelecek Özellikler

- [ ] Push notifications
- [ ] Ortak takvim
- [ ] Milestone/Özel gün hatırlatıcıları
- [ ] Dışa aktarma özelliği (PDF/Album)
- [ ] Gelişmiş arama
- [ ] Fotoğraf filtreleri
- [ ] Video desteği
- [ ] Sesli not desteği
- [ ] Widget desteği

## 📞 Destek

Sorun yaşarsanız:
1. [FIREBASE_SETUP.md](FIREBASE_SETUP.md) dosyasındaki sorun giderme bölümüne bakın
2. Firebase Console'da logları kontrol edin
3. Xcode console'da hata mesajlarını kontrol edin

---

💝 Sevgiyle yapıldı

