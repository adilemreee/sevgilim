//
//  ChatView.swift
//  sevgilim
//

import SwiftUI
import PhotosUI

struct ChatView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var relationshipService: RelationshipService
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var messageService: MessageService
    
    @State private var messageText = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var showImagePicker = false
    @State private var imageToSend: UIImage?
    @State private var showImagePreview = false
    @State private var isLoadingImage = false
    @State private var showError = false
    @State private var errorMessage = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        mainContent
            .navigationTitle("💬 Sohbet")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: setupView)
            .onDisappear(perform: cleanupView)
            .photosPicker(
                isPresented: $showImagePicker,
                selection: $selectedImage,
                matching: .images,
                photoLibrary: .shared()
            )
            .onChange(of: selectedImage) { oldValue, newValue in
                if newValue != nil && oldValue != newValue {
                    handleImageSelection(newValue)
                }
            }
            .sheet(isPresented: $showImagePreview) {
                imagePreviewSheet
            }
            .alert("Hata", isPresented: $showError) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .overlay {
                if isLoadingImage {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text("Fotoğraf yükleniyor...")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding(30)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                    }
                }
            }
    }
    
    private var mainContent: some View {
        ZStack {
            AnimatedGradientBackground(theme: themeManager.currentTheme)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                messagesListView
                inputBarView
            }
        }
    }
    
    private var messagesListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(messageService.messages) { message in
                        MessageBubble(
                            message: message,
                            isCurrentUser: message.senderId == authService.currentUser?.id,
                            theme: themeManager.currentTheme
                        )
                        .id(message.id)
                    }
                    
                    if messageService.partnerIsTyping {
                        TypingIndicatorView()
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: messageService.messages.count) { _, _ in
                if let lastMessage = messageService.messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
                // Yeni mesajlar geldiğinde okundu olarak işaretle
                markUnreadMessagesAsRead()
            }
            .onChange(of: messageService.messages.map { $0.id }) { _, _ in
                // Mesaj listesi değiştiğinde (isRead güncellemeleri dahil)
                // Scroll pozisyonunu koru ve okundu işaretle
                markUnreadMessagesAsRead()
            }
        }
    }
    
    private var inputBarView: some View {
        InputBar(
            messageText: $messageText,
            imageToSend: $imageToSend,
            showImagePicker: $showImagePicker,
            showImagePreview: $showImagePreview,
            isTextFieldFocused: $isTextFieldFocused,
            theme: themeManager.currentTheme,
            onSend: sendMessage,
            onTextChanged: handleTextChanged
        )
    }
    
    @ViewBuilder
    private var imagePreviewSheet: some View {
        if let image = imageToSend {
            ImagePreviewSheet(
                image: image,
                messageText: $messageText,
                onSend: {
                    sendMessageWithImage()
                    showImagePreview = false
                },
                onCancel: {
                    imageToSend = nil
                    showImagePreview = false
                }
            )
        }
    }
    
    private func setupView() {
        guard let relationshipId = relationshipService.currentRelationship?.id,
              let userId = authService.currentUser?.id else {
            return
        }
        
        messageService.listenToMessages(relationshipId: relationshipId, currentUserId: userId)
        messageService.listenToTypingIndicator(relationshipId: relationshipId, currentUserId: userId)
        markUnreadMessagesAsRead()
    }
    
    private func cleanupView() {
        guard let relationshipId = relationshipService.currentRelationship?.id,
              let userId = authService.currentUser?.id,
              let userName = authService.currentUser?.name else {
            return
        }
        
        messageService.stopTyping(relationshipId: relationshipId, userId: userId, userName: userName)
    }
    
    private func handleImageSelection(_ newItem: PhotosPickerItem?) {
        guard let newItem = newItem else {
            print("⚠️ No image selected")
            return
        }
        
        isLoadingImage = true
        
        Task {
            do {
                // Try to load as Data first
                if let data = try await newItem.loadTransferable(type: Data.self) {
                    if let image = UIImage(data: data) {
                        await MainActor.run {
                            imageToSend = image
                            showImagePreview = true
                            isLoadingImage = false
                            // Reset selected image for next selection
                            selectedImage = nil
                        }
                        print("✅ Image loaded successfully")
                        return
                    }
                }
                
                // If Data loading failed, show error
                await MainActor.run {
                    errorMessage = "Fotoğraf yüklenemedi. Lütfen tekrar deneyin."
                    showError = true
                    isLoadingImage = false
                    selectedImage = nil
                }
                print("❌ Failed to convert data to UIImage")
                
            } catch {
                await MainActor.run {
                    errorMessage = "Fotoğraf yüklenirken hata oluştu: \(error.localizedDescription)"
                    showError = true
                    isLoadingImage = false
                    selectedImage = nil
                }
                print("❌ Error loading image: \(error.localizedDescription)")
            }
        }
    }
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty,
              let relationshipId = relationshipService.currentRelationship?.id,
              let senderId = authService.currentUser?.id,
              let senderName = authService.currentUser?.name else {
            return
        }
        
        messageText = ""
        isTextFieldFocused = false
        
        Task {
            do {
                try await messageService.sendMessage(
                    relationshipId: relationshipId,
                    senderId: senderId,
                    senderName: senderName,
                    text: text
                )
            } catch {
                print("❌ Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    private func sendMessageWithImage() {
        guard let image = imageToSend,
              let relationshipId = relationshipService.currentRelationship?.id,
              let senderId = authService.currentUser?.id,
              let senderName = authService.currentUser?.name else {
            return
        }
        
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        messageText = ""
        imageToSend = nil
        isLoadingImage = true
        
        Task {
            do {
                try await messageService.sendMessageWithImage(
                    relationshipId: relationshipId,
                    senderId: senderId,
                    senderName: senderName,
                    text: text,
                    image: image
                )
                await MainActor.run {
                    isLoadingImage = false
                }
                print("✅ Message with image sent successfully")
            } catch {
                await MainActor.run {
                    isLoadingImage = false
                    errorMessage = "Fotoğraf gönderilemedi: \(error.localizedDescription)"
                    showError = true
                }
                print("❌ Error sending message with image: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleTextChanged() {
        guard let relationshipId = relationshipService.currentRelationship?.id,
              let userId = authService.currentUser?.id,
              let userName = authService.currentUser?.name else {
            return
        }
        
        if !messageText.isEmpty {
            messageService.startTyping(relationshipId: relationshipId, userId: userId, userName: userName)
        } else {
            messageService.stopTyping(relationshipId: relationshipId, userId: userId, userName: userName)
        }
    }
    
    private func markUnreadMessagesAsRead() {
        guard let currentUserId = authService.currentUser?.id else { return }
        
        Task {
            for message in messageService.messages {
                if !message.isRead && message.senderId != currentUserId {
                    if let messageId = message.id {
                        try? await messageService.markAsRead(messageId: messageId)
                    }
                }
            }
        }
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    let theme: AppTheme
    
    @State private var showTimestamp = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isCurrentUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                // Message Content
                VStack(alignment: .leading, spacing: 8) {
                    // Story image if exists (küçük thumbnail)
                    if let storyImageURL = message.storyImageURL {
                        HStack(spacing: 8) {
                            CachedAsyncImage(url: storyImageURL, thumbnail: true) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                            } placeholder: {
                                ZStack {
                                    Color.gray.opacity(0.2)
                                    ProgressView()
                                        .scaleEffect(0.7)
                                }
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)
                            }
                            
                            Text("Story")
                                .font(.caption)
                                .foregroundColor(isCurrentUser ? .white.opacity(0.8) : .secondary)
                        }
                    }
                    
                    // Image if exists
                    if let imageURL = message.imageURL {
                        MessageImageView(imageURL: imageURL)
                    }
                    
                    // Text
                    if !message.text.isEmpty && message.text != "📷 Fotoğraf" {
                        Text(message.text)
                            .font(.body)
                            .foregroundColor(isCurrentUser ? .white : .primary)
                    }
                    
                    // Timestamp and read receipt
                    HStack(spacing: 4) {
                        Text(message.timestamp, formatter: DateFormatter.timeFormat)
                            .font(.caption2)
                            .foregroundColor(isCurrentUser ? .white.opacity(0.7) : .secondary)
                        
                        if isCurrentUser {
                            Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                                .font(.caption2)
                                .foregroundColor(message.isRead ? .green : .white.opacity(0.7))
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    isCurrentUser ?
                    AnyView(
                        LinearGradient(
                            colors: [theme.primaryColor, theme.secondaryColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    ) :
                    AnyView(Color(.systemGray6))
                )
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            
            if !isCurrentUser {
                Spacer(minLength: 60)
            }
        }
        .onTapGesture {
            withAnimation {
                showTimestamp.toggle()
            }
        }
    }
}

// MARK: - Message Image View with Caching
struct MessageImageView: View {
    let imageURL: String
    @State private var loadedImage: UIImage?
    @State private var showFullScreen = false
    @State private var isLoadingFullImage = false
    
    var body: some View {
        ZStack {
            CachedAsyncImage(url: imageURL, thumbnail: true) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 200, maxHeight: 200)
                    .cornerRadius(12)
                    .onTapGesture {
                        loadFullImageAndShow()
                    }
            } placeholder: {
                ZStack {
                    Color.gray.opacity(0.2)
                    ProgressView()
                }
                .frame(width: 200, height: 200)
                .cornerRadius(12)
            }
            
            if isLoadingFullImage {
                ZStack {
                    Color.black.opacity(0.4)
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.2)
                }
                .frame(maxWidth: 200, maxHeight: 200)
                .cornerRadius(12)
            }
        }
        .fullScreenCover(isPresented: $showFullScreen) {
            if let image = loadedImage {
                FullScreenImageView(image: image)
            } else {
                // Fallback if image fails to load
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        Text("Fotoğraf yüklenemedi")
                            .foregroundColor(.white)
                            .font(.headline)
                        Button("Kapat") {
                            showFullScreen = false
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    private func loadFullImageAndShow() {
        isLoadingFullImage = true
        print("📸 Loading full resolution image: \(imageURL)")
        
        Task {
            do {
                if let fullImage = try await ImageCacheService.shared.loadImage(from: imageURL, thumbnail: false) {
                    await MainActor.run {
                        print("✅ Full image loaded successfully")
                        loadedImage = fullImage
                        isLoadingFullImage = false
                        showFullScreen = true
                    }
                } else {
                    await MainActor.run {
                        print("⚠️ Full image returned nil")
                        isLoadingFullImage = false
                        // Show the full screen cover even if image is nil to show error message
                        showFullScreen = true
                    }
                }
            } catch {
                await MainActor.run {
                    print("❌ Error loading full image: \(error.localizedDescription)")
                    isLoadingFullImage = false
                    showFullScreen = true
                }
            }
        }
    }
}

// MARK: - Full Screen Image View
struct FullScreenImageView: View {
    @Environment(\.dismiss) var dismiss
    let image: UIImage
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastScale
                            lastScale = value
                            scale = min(max(scale * delta, 1), 4)
                        }
                        .onEnded { _ in
                            lastScale = 1.0
                            if scale < 1 {
                                withAnimation {
                                    scale = 1
                                    offset = .zero
                                    lastOffset = .zero
                                }
                            }
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if scale > 1 {
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                        }
                        .onEnded { _ in
                            if scale > 1 {
                                lastOffset = offset
                            }
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation {
                        if scale > 1 {
                            scale = 1
                            offset = .zero
                            lastOffset = .zero
                        } else {
                            scale = 2.5
                        }
                    }
                }
            
            // Close button
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 44, height: 44)
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(20)
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

// MARK: - Typing Indicator View
struct TypingIndicatorView: View {
    @State private var animateScale = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animateScale ? 1.0 : 0.5)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                            value: animateScale
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(18)
            
            Spacer()
        }
        .onAppear {
            animateScale = true
        }
    }
}

// MARK: - Input Bar
struct InputBar: View {
    @Binding var messageText: String
    @Binding var imageToSend: UIImage?
    @Binding var showImagePicker: Bool
    @Binding var showImagePreview: Bool
    var isTextFieldFocused: FocusState<Bool>.Binding
    let theme: AppTheme
    let onSend: () -> Void
    let onTextChanged: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Photo Button with animation
            Button(action: { 
                print("📸 Photo button tapped")
                showImagePicker = true 
            }) {
                ZStack {
                    Circle()
                        .fill(theme.primaryColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "photo.fill")
                        .font(.system(size: 20))
                        .foregroundColor(theme.primaryColor)
                }
            }
            .buttonStyle(.plain)
            
            // Text Field
            HStack(spacing: 8) {
                TextField("Mesaj yaz...", text: $messageText, axis: .vertical)
                    .lineLimit(1...5)
                    .focused(isTextFieldFocused)
                    .onChange(of: messageText) { _, _ in
                        onTextChanged()
                    }
                
                if !messageText.isEmpty {
                    Button(action: {
                        messageText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(20)
            
            // Send Button
            Button(action: onSend) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                                [Color.gray.opacity(0.3), Color.gray.opacity(0.3)] :
                                [theme.primaryColor, theme.secondaryColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "arrow.up")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemBackground).opacity(0.95))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
    }
}

// MARK: - Image Preview Sheet
struct ImagePreviewSheet: View {
    let image: UIImage
    @Binding var messageText: String
    let onSend: () -> Void
    let onCancel: () -> Void
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Image Preview
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)
                    .padding()
                
                // Caption TextField
                TextField("Başlık ekle (opsiyonel)", text: $messageText, axis: .vertical)
                    .lineLimit(1...3)
                    .focused($isTextFieldFocused)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Fotoğraf Gönder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Gönder") {
                        onSend()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Date Formatter Extensions
extension DateFormatter {
    static let timeFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

#Preview {
    NavigationStack {
        ChatView()
            .environmentObject(AuthenticationService())
            .environmentObject(RelationshipService())
            .environmentObject(ThemeManager())
    }
}

