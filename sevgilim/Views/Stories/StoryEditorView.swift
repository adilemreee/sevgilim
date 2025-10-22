//
//  StoryEditorView.swift
//  sevgilim
//

import SwiftUI
import UIKit
import CoreImage

@available(iOS 16.0, *)
struct StoryEditorView: View {
    let image: UIImage
    let onCancel: () -> Void
    let onSave: (UIImage) -> Void
    
    @State private var textBoxes: [StoryTextBox] = []
    @State private var strokes: [StoryDrawingStroke] = []
    @State private var currentStrokePoints: [CGPoint] = []
    @State private var isDrawingMode = false
    @State private var selectedTextBoxID: UUID?
    @State private var currentColor: Color = .white
    @State private var brushWidth: CGFloat = 0.01 // Normalized relative to canvas width
    @State private var canvasFrame: CGRect = .zero
    @FocusState private var isTextFieldFocused: Bool
    
    private let minimumBrushWidth: CGFloat = 0.004
    private let maximumBrushWidth: CGFloat = 0.03
    
    // Common color palette inspired by Instagram
    private let colorPalette: [Color] = [
        .white, .black, .yellow, .orange, .red, .pink, .purple, .blue, .teal, .green
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let containerSize = geometry.size
            let contentFrame = calculateContentFrame(in: containerSize, for: image.size)
            
            ZStack {
                Color.black
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissTextEditing()
                    }
                
                // Canvas
                StoryCanvasView(
                    image: image,
                    contentFrame: contentFrame,
                    strokes: strokes,
                    currentStrokePoints: currentStrokePoints,
                    currentStrokeColor: currentColor,
                    currentStrokeWidth: brushWidth
                )
                .gesture(drawingGesture(in: contentFrame))
                .overlay(
                    StoryTextBoxesOverlay(
                        textBoxes: $textBoxes,
                        selectedTextBoxID: $selectedTextBoxID,
                        contentFrame: contentFrame,
                        isDrawingMode: isDrawingMode,
                        onSelect: { id in
                            selectedTextBoxID = id
                            isDrawingMode = false
                            isTextFieldFocused = true
                        },
                        onDelete: { id in
                            if let index = textBoxes.firstIndex(where: { $0.id == id }) {
                                textBoxes.remove(at: index)
                                if selectedTextBoxID == id {
                                    selectedTextBoxID = nil
                                }
                            }
                        }
                    )
                )
                .onAppear {
                    canvasFrame = contentFrame
                }
                .onChange(of: contentFrame) { newValue in
                    canvasFrame = newValue
                }
                
                // Header controls
                VStack {
                    HStack {
                        Button(action: cancelEditing) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        
                        Spacer()
                        
                        Button(action: saveStory) {
                            Text("Paylaş")
                                .fontWeight(.semibold)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(LinearGradient(
                                            colors: [Color.primary, Color.primary],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                    
                    Spacer()
                }
                
                // Bottom toolbar
                VStack(spacing: 16) {
                    // Color palette
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(colorPalette, id: \.self) { color in
                                let isSelected = isPaletteColorSelected(color)
                                Button {
                                    apply(color: color)
                                } label: {
                                    Circle()
                                        .fill(color)
                                        .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(isSelected ? 0.9 : 0.3), lineWidth: isSelected ? 3 : 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Drawing controls
                    if isDrawingMode {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "pencil.tip")
                                Slider(value: $brushWidth, in: minimumBrushWidth...maximumBrushWidth)
                                Text("\(Int(brushWidth * 1000))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            
                            HStack(spacing: 16) {
                                Button {
                                    undoStroke()
                                } label: {
                                    Label("Geri Al", systemImage: "arrow.uturn.left")
                                        .labelStyle(.iconOnly)
                                        .frame(width: 48, height: 48)
                                        .background(.ultraThinMaterial, in: Circle())
                                }
                                
                                Button {
                                    clearStrokes()
                                } label: {
                                    Label("Temizle", systemImage: "trash")
                                        .labelStyle(.iconOnly)
                                        .frame(width: 48, height: 48)
                                        .background(.ultraThinMaterial, in: Circle())
                                }
                            }
                        }
                    }
                    
                    // Primary actions
                    HStack(spacing: 20) {
                        Button {
                            isDrawingMode.toggle()
                            if isDrawingMode {
                                selectedTextBoxID = nil
                                isTextFieldFocused = false
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: isDrawingMode ? "pencil.tip.crop.circle.fill" : "pencil.tip")
                                    .font(.system(size: 22, weight: .semibold))
                                Text("Çizim")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(isDrawingMode ? Color.purple.opacity(0.85) : Color.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        }
                        
                        Button {
                            addTextBox()
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: "textformat.alt")
                                    .font(.system(size: 22, weight: .semibold))
                                Text("Yazı")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Color.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        }
                        
                        Button {
                            if let selectedID = selectedTextBoxID {
                                deleteTextBox(with: selectedID)
                            } else {
                                undoStroke()
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: "arrow.uturn.left")
                                    .font(.system(size: 22, weight: .semibold))
                                Text(selectedTextBoxID != nil ? "Yazıyı Sil" : "Çizimi Geri Al")
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                            }
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Color.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        }
                    }
                }
                .padding(.bottom, 24)
                .padding(.top, 12)
                .background(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.85),
                            Color.black.opacity(0.7),
                            Color.black.opacity(0.0)
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .ignoresSafeArea(edges: .bottom)
                )
                .frame(maxHeight: .infinity, alignment: .bottom)
                
                // Text field overlay
                if let selectedID = selectedTextBoxID,
                   let index = textBoxes.firstIndex(where: { $0.id == selectedID }) {
                    VStack {
                        Spacer()
                        VStack(spacing: 12) {
                            HStack {
                                Text("Metni düzenle")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button {
                                    deleteTextBox(with: selectedID)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            
                            TextField("Metin yaz...", text: $textBoxes[index].text, axis: .vertical)
                                .focused($isTextFieldFocused)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(size: 18, weight: .semibold))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.black.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 160)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var selectedColor: Color {
        if let selectedID = selectedTextBoxID,
           let textBox = textBoxes.first(where: { $0.id == selectedID }) {
            return textBox.color
        }
        return currentColor
    }
    
    private func isPaletteColorSelected(_ color: Color) -> Bool {
        colorsAreEqual(color, selectedColor)
    }
    
    private func addTextBox() {
        let newBox = StoryTextBox(
            text: "",
            position: CGPoint(x: 0.5, y: 0.5),
            color: currentColor,
            fontScale: 0.08
        )
        textBoxes.append(newBox)
        selectedTextBoxID = newBox.id
        isDrawingMode = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isTextFieldFocused = true
        }
    }
    
    private func deleteTextBox(with id: UUID) {
        if let index = textBoxes.firstIndex(where: { $0.id == id }) {
            textBoxes.remove(at: index)
        }
        selectedTextBoxID = nil
        isTextFieldFocused = false
    }
    
    private func apply(color: Color) {
        if let selectedID = selectedTextBoxID,
           let index = textBoxes.firstIndex(where: { $0.id == selectedID }) {
            textBoxes[index].color = color
        } else {
            currentColor = color
        }
    }
    
    private func dismissTextEditing() {
        selectedTextBoxID = nil
        isTextFieldFocused = false
    }
    
    private func undoStroke() {
        if !currentStrokePoints.isEmpty {
            currentStrokePoints.removeAll()
        } else if let last = strokes.last {
            // Remove last stroke
            if let index = strokes.firstIndex(where: { $0.id == last.id }) {
                strokes.remove(at: index)
            }
        }
    }
    
    private func clearStrokes() {
        strokes.removeAll()
        currentStrokePoints.removeAll()
    }
    
    private func cancelEditing() {
        onCancel()
    }
    
    private func saveStory() {
        guard let rendered = renderStoryImage() else { return }
        onSave(rendered)
    }
    
    private func renderStoryImage() -> UIImage? {
        let renderView = StoryRenderView(
            image: image,
            textBoxes: textBoxes,
            strokes: strokes
        )
        let renderer = ImageRenderer(content: renderView)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
    
    private func drawingGesture(in frame: CGRect) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                guard isDrawingMode else { return }
                guard frame.contains(value.location) else { return }
                
                if currentStrokePoints.isEmpty {
                    currentStrokePoints.append(value.location)
                } else {
                    currentStrokePoints.append(value.location)
                }
            }
            .onEnded { value in
                guard isDrawingMode else { return }
                guard !currentStrokePoints.isEmpty else { return }
                
                let normalizedPoints = currentStrokePoints.map { point -> CGPoint in
                    CGPoint(
                        x: (point.x - frame.minX) / frame.width,
                        y: (point.y - frame.minY) / frame.height
                    )
                }.filter { $0.x.isFinite && $0.y.isFinite }
                
                guard !normalizedPoints.isEmpty else {
                    currentStrokePoints.removeAll()
                    return
                }
                
                let stroke = StoryDrawingStroke(
                    points: normalizedPoints,
                    color: currentColor,
                    normalizedLineWidth: brushWidth
                )
                strokes.append(stroke)
                currentStrokePoints.removeAll()
            }
    }
    
    private func calculateContentFrame(in containerSize: CGSize, for imageSize: CGSize) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return CGRect(origin: .zero, size: containerSize)
        }
        
        let scale = min(containerSize.width / imageSize.width, containerSize.height / imageSize.height)
        let width = imageSize.width * scale
        let height = imageSize.height * scale
        let originX = (containerSize.width - width) / 2.0
        let originY = (containerSize.height - height) / 2.0
        
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
}

// MARK: - Supporting Views & Models

@available(iOS 16.0, *)
private struct StoryCanvasView: View {
    let image: UIImage
    let contentFrame: CGRect
    let strokes: [StoryDrawingStroke]
    let currentStrokePoints: [CGPoint]
    let currentStrokeColor: Color
    let currentStrokeWidth: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let frame = contentFrame
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: frame.width, height: frame.height)
                    .position(x: frame.midX, y: frame.midY)
                    .clipped()
                    .shadow(radius: 12)
                
                // Existing strokes
                ForEach(strokes) { stroke in
                    strokePath(stroke, in: frame)
                        .stroke(
                            stroke.color,
                            style: StrokeStyle(
                                lineWidth: stroke.normalizedLineWidth * frame.width,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                }
                
                // Current stroke (during drawing)
                if !currentStrokePoints.isEmpty {
                    currentStrokePath(currentStrokePoints)
                        .stroke(
                            currentStrokeColor,
                            style: StrokeStyle(
                                lineWidth: currentStrokeWidth * frame.width,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    private func strokePath(_ stroke: StoryDrawingStroke, in frame: CGRect) -> Path {
        var path = Path()
        guard let first = stroke.points.first else { return path }
        let start = CGPoint(
            x: frame.minX + first.x * frame.width,
            y: frame.minY + first.y * frame.height
        )
        path.move(to: start)
        
        for point in stroke.points.dropFirst() {
            let next = CGPoint(
                x: frame.minX + point.x * frame.width,
                y: frame.minY + point.y * frame.height
            )
            path.addLine(to: next)
        }
        return path
    }
    
    private func currentStrokePath(_ points: [CGPoint]) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
}

@available(iOS 16.0, *)
private struct StoryTextBoxesOverlay: View {
    @Binding var textBoxes: [StoryTextBox]
    @Binding var selectedTextBoxID: UUID?
    let contentFrame: CGRect
    let isDrawingMode: Bool
    let onSelect: (UUID) -> Void
    let onDelete: (UUID) -> Void
    
    var body: some View {
        ZStack {
            ForEach($textBoxes) { $textBox in
                StoryTextBoxView(
                    textBox: $textBox,
                    contentFrame: contentFrame,
                    isSelected: selectedTextBoxID == textBox.id,
                    onSelect: {
                        onSelect(textBox.id)
                    },
                    onDelete: {
                        onDelete(textBox.id)
                    }
                )
            }
        }
        .allowsHitTesting(!isDrawingMode)
    }
}

@available(iOS 16.0, *)
private struct StoryTextBoxView: View {
    @Binding var textBox: StoryTextBox
    let contentFrame: CGRect
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    @State private var dragStartPosition: CGPoint = .zero
    @State private var initialFontScale: CGFloat = 0.08
    @State private var isDragging = false
    @State private var isScaling = false
    
    private let minFontScale: CGFloat = 0.04
    private let maxFontScale: CGFloat = 0.18
    
    var body: some View {
        Text(textBox.text.isEmpty ? " " : textBox.text)
            .font(.system(size: contentFrame.width * textBox.fontScale, weight: .semibold))
            .foregroundColor(textBox.color)
            .multilineTextAlignment(.center)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.black.opacity(textBox.text.isEmpty ? 0.0 : 0.25))
            )
            .position(
                x: contentFrame.minX + textBox.position.x * contentFrame.width,
                y: contentFrame.minY + textBox.position.y * contentFrame.height
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .shadow(radius: 3)
                    }
                    .offset(x: 12, y: -12)
                }
            }
            .gesture(dragGesture)
            .simultaneousGesture(magnificationGesture)
            .onTapGesture {
                onSelect()
            }
            .onAppear {
                initialFontScale = textBox.fontScale
            }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if !isDragging {
                    dragStartPosition = textBox.position
                    isDragging = true
                }
                
                guard contentFrame.width > 0, contentFrame.height > 0 else { return }
                
                let deltaX = value.translation.width / contentFrame.width
                let deltaY = value.translation.height / contentFrame.height
                
                let newX = (dragStartPosition.x + deltaX).clamped(to: 0.0...1.0)
                let newY = (dragStartPosition.y + deltaY).clamped(to: 0.0...1.0)
                
                textBox.position = CGPoint(x: newX, y: newY)
            }
            .onEnded { _ in
                isDragging = false
            }
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                if !isScaling {
                    initialFontScale = textBox.fontScale
                    isScaling = true
                }
                let newScale = (initialFontScale * value).clamped(to: minFontScale...maxFontScale)
                textBox.fontScale = newScale
            }
            .onEnded { _ in
                isScaling = false
            }
    }
}

@available(iOS 16.0, *)
private struct StoryRenderView: View {
    let image: UIImage
    let textBoxes: [StoryTextBox]
    let strokes: [StoryDrawingStroke]
    
    var body: some View {
        let imageSize = image.size
        ZStack {
            Image(uiImage: image)
                .resizable()
                .interpolation(.high)
                .frame(width: imageSize.width, height: imageSize.height)
                .clipped()
            
            ForEach(strokes) { stroke in
                path(for: stroke, in: CGRect(origin: .zero, size: imageSize))
                    .stroke(
                        stroke.color,
                        style: StrokeStyle(
                            lineWidth: stroke.normalizedLineWidth * imageSize.width,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
            }
            
            ForEach(textBoxes) { textBox in
                Text(textBox.text.isEmpty ? " " : textBox.text)
                    .font(.system(size: imageSize.width * textBox.fontScale, weight: .semibold))
                    .foregroundColor(textBox.color)
                    .multilineTextAlignment(.center)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.black.opacity(textBox.text.isEmpty ? 0.0 : 0.25))
                    )
                    .position(
                        x: textBox.position.x * imageSize.width,
                        y: textBox.position.y * imageSize.height
                    )
            }
        }
        .frame(width: imageSize.width, height: imageSize.height)
    }
    
    private func path(for stroke: StoryDrawingStroke, in rect: CGRect) -> Path {
        var path = Path()
        guard let first = stroke.points.first else { return path }
        
        let start = CGPoint(
            x: first.x * rect.width,
            y: first.y * rect.height
        )
        path.move(to: start)
        
        for point in stroke.points.dropFirst() {
            let next = CGPoint(
                x: point.x * rect.width,
                y: point.y * rect.height
            )
            path.addLine(to: next)
        }
        
        return path
    }
}

@available(iOS 16.0, *)
private struct StoryTextBox: Identifiable {
    let id = UUID()
    var text: String
    var position: CGPoint // Normalized (0...1)
    var color: Color
    var fontScale: CGFloat
}

@available(iOS 16.0, *)
private struct StoryDrawingStroke: Identifiable {
    let id = UUID()
    var points: [CGPoint] // Normalized (0...1)
    var color: Color
    var normalizedLineWidth: CGFloat
}

// MARK: - Helpers

private func colorsAreEqual(_ lhs: Color, _ rhs: Color) -> Bool {
    let lhsUIColor = UIColor(lhs)
    let rhsUIColor = UIColor(rhs)
    
    let lhsCI = CIColor(color: lhsUIColor)
    let rhsCI = CIColor(color: rhsUIColor)
    
    let threshold: CGFloat = 0.002
    return abs(lhsCI.red - rhsCI.red) < threshold &&
           abs(lhsCI.green - rhsCI.green) < threshold &&
           abs(lhsCI.blue - rhsCI.blue) < threshold &&
           abs(lhsCI.alpha - rhsCI.alpha) < threshold
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
