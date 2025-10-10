//
//  MemoriesView.swift
//  sevgilim
//

import SwiftUI

struct MemoriesView: View {
    @EnvironmentObject var memoryService: MemoryService
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var showingAddMemory = false
    @State private var selectedMemory: Memory?
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [
                    themeManager.currentTheme.primaryColor.opacity(0.3),
                    themeManager.currentTheme.secondaryColor.opacity(0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Compact Header
                HStack(spacing: 12) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.pink, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Anılarımız")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("Birlikte yaşadığımız güzel anlar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
                
                // Content
                if memoryService.memories.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.text.square")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary.opacity(0.6))
                        
                        VStack(spacing: 8) {
                            Text("Henüz anı yok")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Güzel anlarınızı kaydetmeye başlayın")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: { showingAddMemory = true }) {
                            Label("İlk Anıyı Ekle", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(themeManager.currentTheme.primaryColor)
                                .cornerRadius(12)
                        }
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(memoryService.memories) { memory in
                                MemoryCardModern(memory: memory)
                                    .onTapGesture {
                                        selectedMemory = memory
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .overlay(alignment: .top) {
                        if memoryService.isLoading {
                            ProgressView()
                                .padding()
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
            
            // Floating Add Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAddMemory = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(themeManager.currentTheme.primaryColor)
                            .clipShape(Circle())
                            .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showingAddMemory) {
            AddMemoryView()
        }
        .sheet(item: $selectedMemory) { memory in
            MemoryDetailView(memory: memory)
        }
        .onAppear {
            if let relationshipId = authService.currentUser?.relationshipId {
                memoryService.listenToMemories(relationshipId: relationshipId)
            }
        }
    }
}

// Modern Memory Card
struct MemoryCardModern: View {
    let memory: Memory
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "heart.circle.fill")
                    .font(.title2)
                    .foregroundStyle(themeManager.currentTheme.primaryColor)
                    .frame(width: 44, height: 44)
                    .background(themeManager.currentTheme.primaryColor.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(memory.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Text(memory.date, formatter: DateFormatter.displayFormat)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let location = memory.location {
                            Text("•")
                                .foregroundColor(.secondary)
                            Label(location, systemImage: "location.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Photo with Caching (Thumbnail)
            if let photoURL = memory.photoURL {
                CachedAsyncImage(url: photoURL, thumbnail: true) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(12)
                } placeholder: {
                    ZStack {
                        Color.gray.opacity(0.1)
                            .frame(height: 200)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: themeManager.currentTheme.primaryColor))
                    }
                    .cornerRadius(12)
                }
            }
            
            // Content Preview
            Text(memory.content)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(3)
            
            // Tags Preview
            if let tags = memory.tags, !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(tags.prefix(3), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(themeManager.currentTheme.primaryColor.opacity(0.2))
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                                .cornerRadius(8)
                        }
                        if tags.count > 3 {
                            Text("+\(tags.count - 3)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Quick Stats
            HStack(spacing: 20) {
                HStack(spacing: 5) {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    Text("\(memory.likes.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 5) {
                    Image(systemName: "bubble.left.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(memory.comments.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// Memory Detail View
struct MemoryDetailView: View {
    let memory: Memory
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var memoryService: MemoryService
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var showingDeleteAlert = false
    @State private var showingComments = false
    @State private var commentText = ""
    
    // Get current memory from service for live updates
    private var currentMemory: Memory {
        memoryService.memories.first(where: { $0.id == memory.id }) ?? memory
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Photo
                    if let photoURL = currentMemory.photoURL {
                        CachedAsyncImage(url: photoURL, thumbnail: false) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                                .clipped()
                                .cornerRadius(12)
                        } placeholder: {
                            ZStack {
                                Color.gray.opacity(0.1)
                                    .frame(height: 300)
                                ProgressView()
                            }
                            .cornerRadius(12)
                        }
                    }
                    
                    // Title
                    Text(currentMemory.title)
                        .font(.title.bold())
                    
                    // Date and Location
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.secondary)
                            Text(currentMemory.date, formatter: DateFormatter.displayFormat)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let location = currentMemory.location {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.secondary)
                                Text(location)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Tags
                    if let tags = currentMemory.tags, !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(themeManager.currentTheme.primaryColor.opacity(0.2))
                                        .foregroundColor(themeManager.currentTheme.primaryColor)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Content
                    Text(currentMemory.content)
                        .font(.body)
                    
                    Divider()
                    
                    // Actions
                    HStack(spacing: 30) {
                        Button(action: toggleLike) {
                            VStack {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundStyle(isLiked ? themeManager.currentTheme.primaryColor : .secondary)
                                Text("\(currentMemory.likes.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button(action: { showingComments.toggle() }) {
                            VStack {
                                Image(systemName: "bubble.left")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                                Text("\(currentMemory.comments.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Comments Section
                    if showingComments {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Yorumlar")
                                .font(.headline)
                            
                            if currentMemory.comments.isEmpty {
                                Text("Henüz yorum yok")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else {
                                ForEach(currentMemory.comments) { comment in
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            Text(comment.userName)
                                                .font(.caption.bold())
                                            Text(comment.createdAt.timeAgo())
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                        Text(comment.text)
                                            .font(.caption)
                                    }
                                    .padding(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                            
                            // Add Comment
                            HStack {
                                TextField("Yorum ekle...", text: $commentText)
                                    .textFieldStyle(.roundedBorder)
                                
                                Button(action: addComment) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(themeManager.currentTheme.primaryColor)
                                }
                                .disabled(commentText.isEmpty)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Anı Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .alert("Anıyı Sil", isPresented: $showingDeleteAlert) {
                Button("İptal", role: .cancel) {}
                Button("Sil", role: .destructive) {
                    deleteMemory()
                }
            } message: {
                Text("Bu anıyı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.")
            }
        }
    }
    
    private var isLiked: Bool {
        guard let userId = authService.currentUser?.id else { return false }
        return currentMemory.likes.contains(userId)
    }
    
    private func toggleLike() {
        guard let userId = authService.currentUser?.id else { return }
        Task {
            try? await memoryService.toggleLike(memory: currentMemory, userId: userId)
        }
    }
    
    private func addComment() {
        guard let userId = authService.currentUser?.id,
              let userName = authService.currentUser?.name else { return }
        
        let comment = Comment(
            userId: userId,
            userName: userName,
            text: commentText,
            createdAt: Date()
        )
        
        Task {
            try? await memoryService.addComment(memory: currentMemory, comment: comment)
            await MainActor.run {
                commentText = ""
            }
        }
    }
    
    private func deleteMemory() {
        Task {
            do {
                try await memoryService.deleteMemory(currentMemory)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("❌ Error deleting memory: \(error.localizedDescription)")
            }
        }
    }
}

struct AddMemoryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var memoryService: MemoryService
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var title = ""
    @State private var content = ""
    @State private var date = Date()
    @State private var location = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var tagInput = ""
    @State private var tags: [String] = []
    @State private var isUploading = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .onTapGesture {
                                showingImagePicker = true
                            }
                    } else {
                        Button(action: { showingImagePicker = true }) {
                            Label("Fotoğraf Ekle (isteğe bağlı)", systemImage: "photo.badge.plus")
                        }
                    }
                }
                
                Section("Anı Detayları") {
                    TextField("Başlık", text: $title)
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                    DatePicker("Tarih", selection: $date, displayedComponents: .date)
                    TextField("Konum (isteğe bağlı)", text: $location)
                }
                
                Section("Etiketler") {
                    HStack {
                        TextField("Etiket ekle", text: $tagInput)
                        Button("Ekle") {
                            if !tagInput.isEmpty {
                                tags.append(tagInput)
                                tagInput = ""
                            }
                        }
                    }
                    
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    HStack {
                                        Text("#\(tag)")
                                        Button(action: { tags.removeAll { $0 == tag } }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Yeni Anı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        saveMemory()
                    }
                    .disabled(title.isEmpty || content.isEmpty || isUploading)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .overlay {
                if isUploading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 15) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Kaydediliyor...")
                                .foregroundColor(.white)
                        }
                        .padding(30)
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                    }
                }
            }
        }
    }
    
    private func saveMemory() {
        guard let userId = authService.currentUser?.id,
              let relationshipId = authService.currentUser?.relationshipId else { return }
        
        isUploading = true
        Task {
            do {
                var photoURL: String? = nil
                if let image = selectedImage {
                    photoURL = try await StorageService.shared.uploadMemoryPhoto(image, relationshipId: relationshipId)
                }
                
                try await memoryService.addMemory(
                    relationshipId: relationshipId,
                    title: title,
                    content: content,
                    date: date,
                    photoURL: photoURL,
                    location: location.isEmpty ? nil : location,
                    tags: tags.isEmpty ? nil : tags,
                    userId: userId
                )
                
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Error saving memory: \(error)")
                await MainActor.run {
                    isUploading = false
                }
            }
        }
    }
}

