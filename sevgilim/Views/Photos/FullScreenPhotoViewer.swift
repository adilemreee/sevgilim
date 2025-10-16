//
//  FullScreenPhotoViewer.swift
//  sevgilim
//

import SwiftUI

struct FullScreenPhotoViewer: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var photoService: PhotoService
    
    @Binding var photos: [Photo]
    @State var selectedIndex: Int
    
    @State private var showControls = true
    @State private var showShareSheet = false
    @State private var showDeleteAlert = false
    @State private var imageToShare: UIImage?
    
    var currentPhoto: Photo? {
        guard !photos.isEmpty, selectedIndex >= 0, selectedIndex < photos.count else {
            return nil
        }
        return photos[selectedIndex]
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            // Güvenlik kontrolü: Eğer photos boşsa dismiss
            if photos.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "photo.fill.on.rectangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.5))
                    Text("Fotoğraf bulunamadı")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        dismiss()
                    }
                }
            }
            
            // Main Content
            VStack(spacing: 0) {
                // Photo carousel - Swipe hızlı geçişler için
                TabView(selection: $selectedIndex) {
                    ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                        PhotoViewerContent(photo: photo) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showControls.toggle()
                            }
                        }
                        .id(photo.id) // Her fotoğraf için yeni view oluştur
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .never))
            }
            
            // Overlay Controls
            VStack {
                // Top bar
                if showControls {
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
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Button(action: { shareCurrentPhoto() }) {
                                ZStack {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Button(action: { showDeleteAlert = true }) {
                                ZStack {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "trash")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Spacer()
                
                // Bottom info
                if showControls, let photo = currentPhoto {
                    VStack(spacing: 16) {
                        // Photo info
                        VStack(spacing: 8) {
                            if let title = photo.title, !title.isEmpty {
                                Text(title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .transition(.opacity)
                            }
                            
                            Text(photo.date, formatter: DateFormatter.displayFormat)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            if let location = photo.location, !location.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "location.fill")
                                        .font(.caption)
                                    Text(location)
                                        .font(.caption)
                                }
                                .foregroundColor(.white.opacity(0.7))
                                .transition(.opacity)
                            }
                        }
                        .animation(.easeInOut(duration: 0.3), value: photo.id)
                        
                        // Page indicator
                        if photos.count > 1 {
                            // Sadece 10'dan az fotoğraf varsa noktaları göster
                            if photos.count <= 10 {
                                HStack(spacing: 8) {
                                    ForEach(0..<photos.count, id: \.self) { index in
                                        Circle()
                                            .fill(index == selectedIndex ? Color.white : Color.white.opacity(0.4))
                                            .frame(width: 6, height: 6)
                                            .animation(.easeInOut(duration: 0.2), value: selectedIndex)
                                    }
                                }
                            }
                            
                            Text("\(selectedIndex + 1) / \(photos.count)")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.top, 4)
                                .animation(.easeInOut(duration: 0.2), value: selectedIndex)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                    .background(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 250)
                        .ignoresSafeArea(edges: .bottom)
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .statusBar(hidden: !showControls)
        .sheet(isPresented: $showShareSheet) {
            if let image = imageToShare {
                ShareSheet(items: [image])
            }
        }
        .alert("Fotoğrafı Sil", isPresented: $showDeleteAlert) {
            Button("İptal", role: .cancel) {}
            Button("Sil", role: .destructive) {
                deleteCurrentPhoto()
            }
        } message: {
            Text("Bu fotoğrafı silmek istediğinizden emin misiniz?")
        }
        .onChange(of: selectedIndex) { _, _ in
            // Reset controls when changing photos
            withAnimation {
                showControls = true
            }
        }
    }
    
    private func shareCurrentPhoto() {
        guard let photo = currentPhoto else {
            print("❌ No current photo to share")
            return
        }
        
        print("📤 Starting share for photo: \(photo.imageURL)")
        
        guard let url = URL(string: photo.imageURL) else {
            print("❌ Invalid URL for sharing")
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        imageToShare = image
                        showShareSheet = true
                        print("✅ Share sheet opened with image")
                    }
                }
            } catch {
                print("❌ Error loading image for sharing: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteCurrentPhoto() {
        guard let photo = currentPhoto else {
            print("❌ No current photo to delete")
            return
        }
        
        print("🗑️ Deleting photo at index: \(selectedIndex)")
        
        Task {
            do {
                try await photoService.deletePhoto(photo)
                
                await MainActor.run {
                    print("✅ Photo deleted successfully")
                    
                    // If it was the last photo, close the viewer
                    if photos.count <= 1 {
                        dismiss()
                    } else {
                        // Adjust index if needed
                        if selectedIndex >= photos.count - 1 {
                            selectedIndex = max(0, photos.count - 2)
                        }
                    }
                }
            } catch {
                print("❌ Error deleting photo: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Photo Viewer Content
struct PhotoViewerContent: View {
    let photo: Photo
    let onTap: () -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var loadedImage: UIImage?
    @State private var isLoading = true
    @State private var loadError: Error?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(2)
                        
                        Text("Yükleniyor...")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text(photo.imageURL)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.horizontal)
                            .lineLimit(2)
                    }
                } else if let error = loadError {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        VStack(spacing: 8) {
                            Text("Fotoğraf Yüklenemedi")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(error.localizedDescription)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Text(photo.imageURL)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal)
                                .lineLimit(3)
                        }
                    }
                    .padding(40)
                } else if let image = loadedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    let newScale = scale * delta
                                    scale = min(max(newScale, 1), 4)
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                    if scale < 1 {
                                        withAnimation(.spring()) {
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
                                    } else {
                                        withAnimation(.spring()) {
                                            offset = .zero
                                            lastOffset = .zero
                                        }
                                    }
                                }
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.spring()) {
                                if scale > 1 {
                                    scale = 1
                                    offset = .zero
                                    lastOffset = .zero
                                } else {
                                    scale = 2.5
                                }
                            }
                        }
                        .onTapGesture(count: 1) {
                            onTap()
                        }
                }
            }
            .onAppear {
                loadImage()
            }
        }
    }
    
    private func loadImage() {
        isLoading = true
        loadError = nil
        
        Task {
            do {
                // Use cached image loading for better performance
                if let image = try await ImageCacheService.shared.loadImage(from: photo.imageURL, thumbnail: false) {
                    await MainActor.run {
                        loadedImage = image
                        isLoading = false
                    }
                } else {
                    throw NSError(domain: "PhotoViewer", code: -2, userInfo: [NSLocalizedDescriptionKey: "Görüntü verisi okunamadı"])
                }
            } catch {
                await MainActor.run {
                    loadError = error
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
