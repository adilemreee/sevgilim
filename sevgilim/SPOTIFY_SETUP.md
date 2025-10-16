# Spotify API Entegrasyonu Kurulum Rehberi

## 1. Spotify Developer Dashboard'a Kayıt Olun

1. [Spotify Developer Dashboard](https://developer.spotify.com/dashboard) adresine gidin
2. Spotify hesabınızla giriş yapın
3. "Create App" butonuna tıklayın

## 2. Uygulama Oluşturun

1. **App Name**: `Sevgilim` (veya istediğiniz isim)
2. **App Description**: `Çiftler için özel uygulama`
3. **Website**: Uygulamanızın web sitesi (isteğe bağlı)
4. **Redirect URI**: `sevgilim://callback` (iOS uygulaması için)
5. **API/SDKs**: `Web API` seçin
6. **Terms of Service**: Kendi şartlarınızı ekleyin
7. **Privacy Policy**: Gizlilik politikası ekleyin

## 3. Client Credentials Alın

1. Oluşturduğunuz uygulamaya tıklayın
2. **Settings** sekmesine gidin
3. **Client ID** ve **Client Secret** değerlerini kopyalayın

## 4. Kodda Güncelleme Yapın

`Services/SpotifyService.swift` dosyasında aşağıdaki satırları güncelleyin:

```swift
private let clientId = "YOUR_SPOTIFY_CLIENT_ID" // Buraya Client ID'nizi yazın
private let clientSecret = "YOUR_SPOTIFY_CLIENT_SECRET" // Buraya Client Secret'ınızı yazın
```

## 5. Info.plist Güncellemesi (İsteğe Bağlı)

Eğer kullanıcıların Spotify'da oturum açmasını istiyorsanız, `Info.plist` dosyasına şu URL scheme'i ekleyin:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>spotify</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>sevgilim</string>
        </array>
    </dict>
</array>
```

## 6. Test Etme

1. Uygulamayı çalıştırın
2. Şarkılar sekmesine gidin
3. "+" butonuna tıklayın
4. "Spotify'dan Şarkı Ara" bölümünde bir şarkı adı yazın
5. Sonuçlardan bir şarkı seçin
6. Şarkı bilgilerinin otomatik olarak doldurulduğunu görün

## Önemli Notlar

- **Client Secret**: Bu değer güvenlik için önemlidir, asla public repository'de paylaşmayın
- **Rate Limits**: Spotify API'nin rate limit'leri vardır, çok fazla istek göndermeyin
- **Authentication**: Şu anda sadece public şarkıları arayabilirsiniz, kullanıcı playlist'leri için ek authentication gerekir

## Sorun Giderme

### "Invalid Credentials" Hatası
- Client ID ve Client Secret'ın doğru olduğundan emin olun
- Spotify Developer Dashboard'da uygulamanızın aktif olduğunu kontrol edin

### "Network Error" Hatası
- İnternet bağlantınızı kontrol edin
- VPN kullanıyorsanız kapatmayı deneyin

### Arama Sonuçları Gelmiyor
- Arama teriminin en az 3 karakter olduğundan emin olun
- Farklı şarkı adları deneyin
- API quota'nızı kontrol edin

## Gelişmiş Özellikler (İsteğe Bağlı)

### Kullanıcı Playlist'leri
Eğer kullanıcıların kendi playlist'lerini görmesini istiyorsanız:
1. OAuth 2.0 authentication implement edin
2. User scope'ları ekleyin: `playlist-read-private`, `playlist-read-collaborative`
3. Kullanıcı token'ı ile API istekleri yapın

### Şarkı Önizleme
Spotify API'den gelen `preview_url` ile 30 saniyelik önizleme ekleyebilirsiniz.

### Favori Şarkılar
Kullanıcıların favori şarkılarını çekmek için `user-top-read` scope'u gerekir.
