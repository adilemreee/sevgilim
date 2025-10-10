# Info.plist Ayarları

Uygulama için gerekli Info.plist ayarları.

## Gerekli İzinler

Xcode'da projeyi açtıktan sonra, Info.plist dosyasına aşağıdaki izinleri eklemeniz gerekir:

### 1. Kamera Erişimi (Fotoğraf çekmek için)

**Key:** `NSCameraUsageDescription`  
**Value:** `Anılarınızı kaydetmek için kameraya erişim gerekiyor`

### 2. Fotoğraf Kütüphanesi Erişimi

**Key:** `NSPhotoLibraryUsageDescription`  
**Value:** `Fotoğraflarınızı seçmek ve kaydetmek için galeriye erişim gerekiyor`

### 3. Fotoğraf Kütüphanesine Ekleme

**Key:** `NSPhotoLibraryAddUsageDescription`  
**Value:** `Anılarınızı kaydetmek için galeriye ekleme izni gerekiyor`

## Xcode'da Ekleme

### Yöntem 1: Info.plist'i Doğrudan Düzenleme

1. Xcode'da `Info.plist` dosyasını açın
2. Sağ tıklayın → "Add Row"
3. Yukarıdaki key'leri ekleyin
4. Her biri için açıklama metnini value olarak girin

### Yöntem 2: Project Settings Üzerinden

1. Xcode'da projeyi seçin
2. Targets → sevgilim → Info sekmesi
3. Custom iOS Target Properties kısmında + butonuna tıklayın
4. İlgili permission'ları ekleyin

## XML Formatı

Info.plist dosyasını source code olarak açarsanız, aşağıdaki XML'i ekleyin:

```xml
<key>NSCameraUsageDescription</key>
<string>Anılarınızı kaydetmek için kameraya erişim gerekiyor</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Fotoğraflarınızı seçmek ve kaydetmek için galeriye erişim gerekiyor</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Anılarınızı kaydetmek için galeriye ekleme izni gerekiyor</string>
```

## Firebase URL Schemes (Opsiyonel)

Google Sign-In kullanıyorsanız, GoogleService-Info.plist'ten REVERSED_CLIENT_ID'yi URL Schemes'e eklemeniz gerekir:

1. Xcode → Project → Targets → sevgilim
2. Info sekmesi → URL Types
3. + butonuna tıklayın
4. URL Schemes: `REVERSED_CLIENT_ID_HERE` (GoogleService-Info.plist'ten alın)

## App Transport Security (ATS)

Firebase varsayılan olarak HTTPS kullanır, ancak bazı durumlarda ATS ayarlarını yapmanız gerekebilir:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

## Push Notifications (Opsiyonel)

Firebase Cloud Messaging kullanıyorsanız:

1. Capabilities → Push Notifications → ON
2. Capabilities → Background Modes → Remote notifications → ON

Info.plist'e ekleyin:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

## Minimum iOS Version

Info.plist'te iOS deployment target kontrol edin:

**Minimum:** iOS 16.0

Xcode → Project → Deployment Info → iOS Deployment Target → 16.0

## Supported Interface Orientations

Telefon için sadece portrait modu önerilir:

```xml
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
</array>
```

## Appearance

Açık ve karanlık mod desteği için:

Info.plist'te `UIUserInterfaceStyle` key'i yoksa, her iki mod da desteklenir (önerilen).

## Launch Screen

Launch screen için gerekli ayarlar:

```xml
<key>UILaunchScreen</key>
<dict>
    <key>UIImageName</key>
    <string>LaunchImage</string>
</dict>
```

## Kontrol Listesi

Uygulamayı çalıştırmadan önce:

- [x] NSCameraUsageDescription eklendi
- [x] NSPhotoLibraryUsageDescription eklendi
- [x] NSPhotoLibraryAddUsageDescription eklendi
- [ ] GoogleService-Info.plist projeye eklendi
- [ ] Firebase URL Schemes eklendi (eğer Google Sign-In kullanılıyorsa)
- [ ] iOS Deployment Target 16.0 olarak ayarlandı
- [ ] Supported Orientations ayarlandı

## Test

İzinleri test etmek için:

1. Simülatörü/cihazı sıfırlayın
2. Uygulamayı çalıştırın
3. Fotoğraf eklemeye çalışın
4. İzin popup'ı görünmeli
5. İzni verin ve fotoğraf seçin

## Sorun Giderme

### İzin popup'ı çıkmıyor
- Info.plist'te ilgili key'in olduğundan emin olun
- Uygulamayı silip yeniden yükleyin
- Simülatörü reset edin

### "This app has crashed because it attempted to access privacy-sensitive data"
- İlgili NSUsageDescription key'ini Info.plist'e ekleyin
- Xcode'u temizleyin (Product → Clean Build Folder)
- Yeniden build edin

## Örnek Info.plist İçeriği

Tam bir Info.plist örneği:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleDisplayName</key>
    <string>Sevgilim</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <true/>
    </dict>
    <key>UIApplicationSupportsIndirectInputEvents</key>
    <true/>
    <key>UILaunchScreen</key>
    <dict/>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>armv7</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    <key>NSCameraUsageDescription</key>
    <string>Anılarınızı kaydetmek için kameraya erişim gerekiyor</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Fotoğraflarınızı seçmek ve kaydetmek için galeriye erişim gerekiyor</string>
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>Anılarınızı kaydetmek için galeriye ekleme izni gerekiyor</string>
</dict>
</plist>
```

