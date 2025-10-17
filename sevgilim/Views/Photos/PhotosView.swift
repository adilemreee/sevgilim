//
//  PhotosView.swift
//  sevgilim
//

import SwiftUI

struct PhotoSelection: Identifiable {
    let id = UUID()
    let photo: Photo
    let index: Int
}

struct PhotosView: View {
    @EnvironmentObject var photoService: PhotoService
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var showingAddPhoto = false
    @State private var selectedPhotoForViewer: PhotoSelection?
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
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
                    Image(systemName: "photo.stack.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Fotoğraflarımız")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("Birlikte çektiğimiz fotoğraflar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
                
                // Content
                if photoService.photos.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary.opacity(0.6))
                        
                        VStack(spacing: 8) {
                            Text("Henüz fotoğraf yok")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Güzel anlarınızı fotoğraf olarak ekleyin")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: { showingAddPhoto = true }) {
                            Label("İlk Fotoğrafı Ekle", systemImage: "plus.circle.fill")
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
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(Array(photoService.photos.enumerated()), id: \.element.id) { index, photo in
                                PhotoCardModern(photo: photo)
                                    .onTapGesture {
                                        guard !photoService.photos.isEmpty && index < photoService.photos.count else {
                                            return
                                        }
                                        selectedPhotoForViewer = PhotoSelection(photo: photo, index: index)
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .overlay(alignment: .top) {
                        if photoService.isLoading {
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
                    Button(action: { showingAddPhoto = true }) {
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
        .sheet(isPresented: $showingAddPhoto) {
            AddPhotoView()
                .environmentObject(photoService)
                .environmentObject(authService)
                .environmentObject(themeManager)
        }
        .fullScreenCover(item: $selectedPhotoForViewer) { selection in
            if !photoService.photos.isEmpty && selection.index < photoService.photos.count {
                FullScreenPhotoViewer(photos: $photoService.photos, selectedIndex: selection.index)
                    .environmentObject(photoService)
            }
        }
        .onAppear {
            if let relationshipId = authService.currentUser?.relationshipId {
                photoService.listenToPhotos(relationshipId: relationshipId)
            }
        }
    }
}

// Modern Photo Card with Caching
struct PhotoCardModern: View {
    let photo: Photo
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Use CachedAsyncImage for better performance
            CachedAsyncImage(url: photo.imageURL, thumbnail: true) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipped()
            } placeholder: {
                ZStack {
                    Color.gray.opacity(0.1)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: themeManager.currentTheme.primaryColor))
                }
            }
            .frame(height: 180)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                if let title = photo.title, !title.isEmpty {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                
                Text(photo.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct PhotoDetailView: View {
    let photo: Photo
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var photoService: PhotoService
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    AsyncImage(url: URL(string: photo.imageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure:
                            Image(systemName: "photo.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        if let title = photo.title {
                            Text(title)
                                .font(.title2.bold())
                        }
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.secondary)
                            Text(photo.date, formatter: DateFormatter.displayFormat)
                                .foregroundColor(.secondary)
                        }
                        
                        if let location = photo.location {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.secondary)
                                Text(location)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let tags = photo.tags, !tags.isEmpty {
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
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
            }
            .navigationTitle("Fotoğraf Detayı")
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
            .alert("Fotoğrafı Sil", isPresented: $showingDeleteAlert) {
                Button("İptal", role: .cancel) {}
                Button("Sil", role: .destructive) {
                    Task {
                        try? await photoService.deletePhoto(photo)
                        dismiss()
                    }
                }
            } message: {
                Text("Bu fotoğrafı silmek istediğinizden emin misiniz?")
            }
        }
    }
}

struct AddPhotoView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var photoService: PhotoService
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var title = ""
    @State private var location = ""
    @State private var date = Date()
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
                            .frame(maxHeight: 300)
                            .onTapGesture {
                                showingImagePicker = true
                            }
                    } else {
                        Button(action: { showingImagePicker = true }) {
                            HStack {
                                Image(systemName: "photo.badge.plus")
                                    .font(.title2)
                                Text("Fotoğraf Seç")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                }
                
                Section("Detaylar") {
                    TextField("Başlık (isteğe bağlı)", text: $title)
                    TextField("Konum (isteğe bağlı)", text: $location)
                    DatePicker("Tarih", selection: $date, displayedComponents: .date)
                    .environment(\.locale, Locale(identifier: "tr_TR"))
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
            .navigationTitle("Fotoğraf Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        uploadPhoto()
                    }
                    .disabled(selectedImage == nil || isUploading)
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
                            Text("Yükleniyor...")
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
    
    private func uploadPhoto() {
        guard let image = selectedImage,
              let userId = authService.currentUser?.id,
              let relationshipId = authService.currentUser?.relationshipId else { return }
        
        isUploading = true
        Task {
            do {
                let imageURL = try await StorageService.shared.uploadPhoto(image, relationshipId: relationshipId)
                try await photoService.addPhoto(
                    relationshipId: relationshipId,
                    imageURL: imageURL,
                    title: title.isEmpty ? nil : title,
                    date: date,
                    location: location.isEmpty ? nil : location,
                    tags: tags.isEmpty ? nil : tags,
                    userId: userId
                )
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Error uploading photo: \(error)")
                await MainActor.run {
                    isUploading = false
                }
            }
        }
    }
}

