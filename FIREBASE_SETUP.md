# Firebase Kurulum Rehberi

## 1. Firebase Projesi Oluşturma

1. [Firebase Console](https://console.firebase.google.com) adresine gidin
2. "Add project" / "Proje ekle" butonuna tıklayın
3. Proje adı girin (örn: "Sevgilim")
4. Google Analytics'i isteğe bağlı olarak etkinleştirin
5. Projeyi oluşturun

## 2. iOS Uygulaması Ekleme

1. Firebase Console'da projenize gidin
2. iOS simgesine tıklayın
3. Bundle ID girin: `com.sevgilim.app` (veya projenizin bundle ID'si)
4. App nickname: "Sevgilim iOS"
5. GoogleService-Info.plist dosyasını indirin
6. İndirilen dosyayı Xcode projenize ekleyin (sevgilim klasörüne sürükleyin)

## 3. Firebase Paketlerini Ekleme

Xcode'da:
1. File → Add Packages...
2. URL girin: `https://github.com/firebase/firebase-ios-sdk`
3. Version: "10.0.0" veya üzeri
4. Şu paketleri seçin:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseStorage
   - FirebaseMessaging (opsiyonel, push notifications için)

## 4. Firebase Authentication Ayarları

1. Firebase Console → Authentication
2. "Get started" butonuna tıklayın
3. Sign-in methods sekmesine gidin
4. Email/Password'ü aktifleştirin
5. (Opsiyonel) Google Sign-In'i aktifleştirin
6. (Opsiyonel) Apple Sign-In'i aktifleştirin

## 5. Cloud Firestore Ayarları

1. Firebase Console → Firestore Database
2. "Create database" butonuna tıklayın
3. Production mode seçin (güvenlik kurallarını sonra ekleyeceğiz)
4. Lokasyon seçin (örn: europe-west3)

### Firestore Güvenlik Kuralları

Firestore Database → Rules sekmesine gidin ve aşağıdaki kuralları yapıştırın:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    function hasRelationship() {
      return isSignedIn() && 
             exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.relationshipId != null;
    }
    
    function getRelationshipId() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.relationshipId;
    }
    
    function isInRelationship(relationshipId) {
      return hasRelationship() && getRelationshipId() == relationshipId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn() && (isOwner(userId) || hasRelationship());
      allow create: if isSignedIn() && isOwner(userId);
      allow update: if isSignedIn() && isOwner(userId);
      allow delete: if isSignedIn() && isOwner(userId);
    }
    
    // Relationships collection
    match /relationships/{relationshipId} {
      allow read: if isSignedIn() && isInRelationship(relationshipId);
      allow create: if isSignedIn();
      allow update: if isSignedIn() && isInRelationship(relationshipId);
      allow delete: if isSignedIn() && isInRelationship(relationshipId);
    }
    
    // Invitations collection
    match /invitations/{invitationId} {
      allow read: if isSignedIn() && 
        (resource.data.senderUserId == request.auth.uid || 
         resource.data.receiverEmail == get(/databases/$(database)/documents/users/$(request.auth.uid)).data.email);
      allow create: if isSignedIn();
      allow update: if isSignedIn();
      allow delete: if isSignedIn();
    }
    
    // Memories collection
    match /memories/{memoryId} {
      allow read: if isSignedIn() && isInRelationship(resource.data.relationshipId);
      allow create: if isSignedIn() && hasRelationship();
      allow update: if isSignedIn() && isInRelationship(resource.data.relationshipId);
      allow delete: if isSignedIn() && isInRelationship(resource.data.relationshipId);
    }
    
    // Photos collection
    match /photos/{photoId} {
      allow read: if isSignedIn() && isInRelationship(resource.data.relationshipId);
      allow create: if isSignedIn() && hasRelationship();
      allow update: if isSignedIn() && isInRelationship(resource.data.relationshipId);
      allow delete: if isSignedIn() && isInRelationship(resource.data.relationshipId);
    }
    
    // Notes collection
    match /notes/{noteId} {
      allow read: if isSignedIn() && isInRelationship(resource.data.relationshipId);
      allow create: if isSignedIn() && hasRelationship();
      allow update: if isSignedIn() && isInRelationship(resource.data.relationshipId);
      allow delete: if isSignedIn() && isInRelationship(resource.data.relationshipId);
    }
    
    // Movies collection
    match /movies/{movieId} {
      allow read: if isSignedIn() && isInRelationship(resource.data.relationshipId);
      allow create: if isSignedIn() && hasRelationship();
      allow update: if isSignedIn() && isInRelationship(resource.data.relationshipId);
      allow delete: if isSignedIn() && isInRelationship(resource.data.relationshipId);
    }
    
    // Plans collection
    match /plans/{planId} {
      allow read: if isSignedIn() && isInRelationship(resource.data.relationshipId);
      allow create: if isSignedIn() && hasRelationship();
      allow update: if isSignedIn() && isInRelationship(resource.data.relationshipId);
      allow delete: if isSignedIn() && isInRelationship(resource.data.relationshipId);
    }
    
    // Messages collection
    match /messages/{messageId} {
      allow read: if isSignedIn() && isInRelationship(resource.data.relationshipId);
      allow create: if isSignedIn() && hasRelationship();
      allow update: if isSignedIn() && isInRelationship(resource.data.relationshipId);
      allow delete: if isSignedIn() && isInRelationship(resource.data.relationshipId);
    }
    
    // Typing indicators subcollection
    match /relationships/{relationshipId}/typing/{document=**} {
      allow read: if isSignedIn() && isInRelationship(relationshipId);
      allow write: if isSignedIn() && isInRelationship(relationshipId);
    }
  }
}
```

## 6. Firebase Storage Ayarları

1. Firebase Console → Storage
2. "Get started" butonuna tıklayın
3. Production mode seçin
4. Lokasyon seçin (Firestore ile aynı olmalı)

### Storage Güvenlik Kuralları

Storage → Rules sekmesine gidin ve aşağıdaki kuralları yapıştırın:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function hasRelationship() {
      return isSignedIn() && 
             firestore.exists(/databases/(default)/documents/users/$(request.auth.uid)) &&
             firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.relationshipId != null;
    }
    
    function getRelationshipId() {
      return firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.relationshipId;
    }
    
    // Profile images - only owner can upload
    match /profiles/{userId}/{allPaths=**} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && request.auth.uid == userId;
    }
    
    // Relationship photos - only users in the relationship can upload
    match /relationships/{relationshipId}/photos/{allPaths=**} {
      allow read: if isSignedIn() && hasRelationship() && getRelationshipId() == relationshipId;
      allow write: if isSignedIn() && hasRelationship() && getRelationshipId() == relationshipId;
    }
    
    // Relationship memories - only users in the relationship can upload
    match /relationships/{relationshipId}/memories/{allPaths=**} {
      allow read: if isSignedIn() && hasRelationship() && getRelationshipId() == relationshipId;
      allow write: if isSignedIn() && hasRelationship() && getRelationshipId() == relationshipId;
    }
    
    // Chat messages - only users in the relationship can upload
    match /relationships/{relationshipId}/messages/{allPaths=**} {
      allow read: if isSignedIn() && hasRelationship() && getRelationshipId() == relationshipId;
      allow write: if isSignedIn() && hasRelationship() && getRelationshipId() == relationshipId;
    }
  }
}
```

## 7. Cloud Messaging (Opsiyonel)

Push notifications için:

1. Firebase Console → Cloud Messaging
2. Apple Developer Portal'dan APNs Authentication Key oluşturun
3. Key'i Firebase Console'a yükleyin

## 8. Firestore İndeksleri

Performans için gerekli indeksler (Firebase otomatik olarak uyarı verecektir):

1. `memories` collection:
   - relationshipId (Ascending) + date (Descending)

2. `photos` collection:
   - relationshipId (Ascending) + date (Descending)

3. `notes` collection:
   - relationshipId (Ascending) + updatedAt (Descending)

4. `movies` collection:
   - relationshipId (Ascending) + watchedDate (Descending)

5. `plans` collection:
   - relationshipId (Ascending) + createdAt (Descending)

6. `messages` collection:
   - relationshipId (Ascending) + timestamp (Ascending)

## Sorun Giderme

### GoogleService-Info.plist bulunamadı hatası
- Dosyanın Xcode projesinde olduğundan emin olun
- Build Phases → Copy Bundle Resources'a eklendiğini kontrol edin

### Firebase bağlantı hatası
- Info.plist dosyasında gerekli izinlerin olduğundan emin olun
- İnternet bağlantınızı kontrol edin

### Authentication hatası
- Firebase Console'da Email/Password authentication'ın aktif olduğunu kontrol edin
- API Key'in doğru olduğunu kontrol edin

## Test Kullanıcıları

Geliştirme aşamasında test kullanıcıları oluşturun:
1. Firebase Console → Authentication → Users
2. "Add user" ile manuel kullanıcı ekleyin

## Üretim Öncesi Kontrol Listesi

- [ ] Firebase güvenlik kuralları aktif
- [ ] Storage güvenlik kuralları aktif
- [ ] Gerekli indeksler oluşturuldu
- [ ] GoogleService-Info.plist doğru yapılandırıldı
- [ ] Test kullanıcıları ile tüm özellikler test edildi
- [ ] Push notifications test edildi (eğer aktifse)
- [ ] Offline mod test edildi

