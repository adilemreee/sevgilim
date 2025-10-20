//
//  FullScreenPhotoViewer.swift
//  sevgilim
//

import SwiftUI
import UIKit

struct FullScreenPhotoViewer: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var photoService: PhotoService
    
    @Binding private var currentIndex: Int
    private let onClose: () -> Void
    
    @State private var pageIndex: Int
    @State private var showControls = true
    @State private var showShareSheet = false
    @State private var showDeleteAlert = false
    @State private var imageToShare: UIImage?
    @State private var hasDismissed = false
    
    private var photos: [Photo] { photoService.photos }
    private var photoCount: Int { photos.count }
    
    private var clampedPageIndex: Int {
        guard photoCount > 0 else { return 0 }
        return min(max(pageIndex, 0), photoCount - 1)
    }
    
    private var currentPhoto: Photo? {
        guard photoCount > 0 else { return nil }
        return photos[clampedPageIndex]
    }
    
    init(currentIndex: Binding<Int>, onClose: @escaping () -> Void) {
        _currentIndex = currentIndex
        self.onClose = onClose
        _pageIndex = State(initialValue: currentIndex.wrappedValue)
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if photoCount == 0 {
                VStack(spacing: 20) {
                    Image(systemName: "photo.fill.on.rectangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.5))
                    Text("Fotoğraf bulunamadı")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                .onAppear {
                    closeViewer()
                }
            } else {
                carousel
                overlayControls
            }
        }
        .statusBar(hidden: photoCount > 0 ? !showControls : false)
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
        .onAppear {
            syncPageIndex()
        }
        .onChange(of: photoService.photos.count) { _, _ in
            guard photoCount > 0 else {
                closeViewer()
                return
            }
            syncPageIndex()
        }
        .onChange(of: currentIndex) { _, _ in
            syncPageIndex()
        }
        .onChange(of: pageIndex) { _, newValue in
            guard photoCount > 0 else { return }
            let clamped = min(max(newValue, 0), photoCount - 1)
            if clamped != newValue {
                pageIndex = clamped
            }
            if currentIndex != clamped {
                currentIndex = clamped
            }
            withAnimation {
                showControls = true
            }
        }
        .onDisappear {
            if !hasDismissed {
                onClose()
            }
        }
    }
    
    private var carousel: some View {
        TabView(selection: $pageIndex) {
            ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                PhotoViewerContent(photo: photo) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showControls.toggle()
                    }
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .indexViewStyle(.page(backgroundDisplayMode: .never))
    }
    
    private var overlayControls: some View {
        VStack(spacing: 0) {
            if showControls {
                HStack(alignment: .top) {
                    Button(action: closeViewer) {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 10) {
                        quickInfoChip
                        HStack(spacing: 10) {
                            actionButton(systemImage: "square.and.arrow.up") {
                                shareCurrentPhoto()
                            }
                            actionButton(systemImage: "trash", color: .red) {
                                showDeleteAlert = true
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer()
        }
    }
    
    private var quickInfoChip: some View {
        HStack(spacing: 10) {
            if let photo = currentPhoto, let location = photo.location, !location.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                    Text(location)
                        .font(.caption.bold())
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.18), in: Capsule())
            }
            
            if photoCount > 1 {
                Text("\(clampedPageIndex + 1) / \(photoCount)")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.18), in: Capsule())
            }
        }
        .foregroundColor(.white)
    }
    
    private func actionButton(systemImage: String, color: Color = .white, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                )
        }
    }
    
    private func shareCurrentPhoto() {
        guard let photo = currentPhoto, let url = URL(string: photo.imageURL) else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        imageToShare = image
                        showShareSheet = true
                    }
                }
            } catch {
                print("❌ Share error: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteCurrentPhoto() {
        guard let photo = currentPhoto else { return }
        Task {
            do {
                try await photoService.deletePhoto(photo)
                await MainActor.run {
                    let updatedCount = photoService.photos.count
                    if updatedCount == 0 {
                        closeViewer()
                    } else {
                        let newIndex = max(0, min(pageIndex, updatedCount - 1))
                        pageIndex = newIndex
                        currentIndex = newIndex
                    }
                }
            } catch {
                print("❌ Delete error: \(error.localizedDescription)")
            }
        }
    }
    
    private func closeViewer() {
        guard !hasDismissed else { return }
        hasDismissed = true
        onClose()
        dismiss()
    }
    
    private func syncPageIndex() {
        guard photoCount > 0 else { return }
        let clamped = min(max(currentIndex, 0), photoCount - 1)
        if pageIndex != clamped {
            pageIndex = clamped
        }
        if currentIndex != clamped {
            currentIndex = clamped
        }
    }
}


private struct PhotoViewerContent: View {
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
                    .ignoresSafeArea()
                
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
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal)
                    }
                } else if let error = loadError {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        Text("Fotoğraf yüklenemedi")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else if let image = loadedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaleEffect(scale)
                        .offset(offset)
                        .simultaneousGesture(magnificationGesture(in: geometry))
                        .simultaneousGesture(dragGesture(in: geometry))
                        .onTapGesture(count: 2) {
                            withAnimation(.spring()) {
                                if scale > 1 {
                                    resetTransform()
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
            .onAppear { loadImage() }
        }
    }
    
    private func magnificationGesture(in geometry: GeometryProxy) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                let newScale = scale * delta
                scale = min(max(newScale, 1), 4)
                offset = clamped(offset, in: geometry)
            }
            .onEnded { _ in
                lastScale = 1
                if scale < 1 {
                    withAnimation(.spring()) {
                        resetTransform()
                    }
                }
            }
    }
    
    private func dragGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: scale > 1 ? 0 : .infinity)
            .onChanged { value in
                guard scale > 1 else { return }
                let proposed = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
                offset = clamped(proposed, in: geometry)
            }
            .onEnded { _ in
                if scale > 1 {
                    lastOffset = offset
                } else {
                    withAnimation(.spring()) {
                        resetTransform()
                    }
                }
            }
    }
    
    private func resetTransform() {
        scale = 1
        offset = .zero
        lastOffset = .zero
    }

    private func clamped(_ proposed: CGSize, in geometry: GeometryProxy) -> CGSize {
        guard let image = loadedImage else { return .zero }
        let container = geometry.size
        let baseScale = min(container.width / image.size.width, container.height / image.size.height)
        let fittedSize = CGSize(width: image.size.width * baseScale, height: image.size.height * baseScale)
        let scaledSize = CGSize(width: fittedSize.width * scale, height: fittedSize.height * scale)
        let maxX = max(0, (scaledSize.width - container.width) / 2)
        let maxY = max(0, (scaledSize.height - container.height) / 2)
        let clampedX = max(-maxX, min(proposed.width, maxX))
        let clampedY = max(-maxY, min(proposed.height, maxY))
        return CGSize(width: clampedX, height: clampedY)
    }
    
    private func loadImage() {
        isLoading = true
        loadError = nil
        Task {
            do {
                if let image = try await ImageCacheService.shared.loadImage(from: photo.imageURL, thumbnail: false) {
                    await MainActor.run {
                        loadedImage = image
                        isLoading = false
                    }
                } else {
                    throw NSError(domain: "PhotoViewer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Görüntü verisi okunamadı"])
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

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
