//
//  MealEntryModal.swift
//  Aurtsy
//
//  Multi-photo (before/after) + notes + voice-to-text
//

import SwiftUI
import PhotosUI
import UIKit
import Speech
import AVFAudio
import AVFoundation

struct MealEntryModal: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var networkManager: NetworkManager

    // MARK: - State
    enum Phase: String, CaseIterable { case before = "Before Meal", after = "After Meal" }

    @State private var phase: Phase = .before
    @State private var beforeImages: [UIImage] = []
    @State private var afterImages:  [UIImage] = []

    @State private var consumptionPct: Double = 75
    @State private var notes: String = ""

    // pickers
    @State private var showSourceSheet = false
    @State private var showCamera = false
    @State private var showLibrary = false           // ← real switch to present PhotosPicker
    @State private var libraryItems: [PhotosPickerItem] = []
    @State private var libraryTargetPhase: Phase = .before

    // speech
    @StateObject private var speech = SpeechRecorder()
    @State private var isRecording = false
    @State private var liveTranscript: String = ""
    @FocusState private var notesFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 24) {
                    phaseToggle
                    photosSection
                    consumptionSection
                    notesSection
                }
                .scrollDismissesKeyboard(.interactively)
                .onTapGesture { notesFocused = false }
                .padding(20)


            }
            .navigationTitle("Meal Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.primary.opacity(0.05)))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveEntry() }
                        .font(.subheadline).fontWeight(.semibold)
                }
                ToolbarItemGroup(placement: .keyboard) {      // ← ADD
                        Spacer()
                        Button("Done") { notesFocused = false }
                            .font(.body.weight(.semibold))
                    }
            }
            .background(
                LinearGradient(
                    colors: [Color(UIColor.systemBackground),
                             Color(UIColor.secondarySystemBackground).opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            // MARK: Source chooser (Camera or Library)
            .confirmationDialog("Add \(phase == .before ? "Before" : "After") Photos",
                                isPresented: $showSourceSheet,
                                titleVisibility: .visible) {
                Button("Camera")   { showCamera = true }
                Button("Photo Library") {
                    libraryTargetPhase = phase
                    showLibrary = true                      // ← present PhotosPicker
                }
                Button("Cancel", role: .cancel) {}
            }
            // MARK: Library picker (multi-select)
            .photosPicker(isPresented: $showLibrary,
                          selection: $libraryItems,
                          maxSelectionCount: 10,
                          matching: .images,
                          preferredItemEncoding: .automatic)
            .onChange(of: libraryItems) { newItems in     // iOS 16+ compatible; builds cleanly
                Task {
                    var uiImages: [UIImage] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let img  = UIImage(data: data) {
                            uiImages.append(img)
                        }
                    }
                    append(uiImages, to: libraryTargetPhase)
                    libraryItems = []
                }
            }
            // MARK: Camera picker
            .sheet(isPresented: $showCamera) {
                CameraPicker { image in
                    if let image { append([image], to: phase) }
                }
            }
        }
        .onReceive(speech.$transcript) { text in
            liveTranscript = text
        }
    }

    // MARK: - Subviews

    
        VStack(alignment: .leading, spacing: 10) {
            Text("DEBUG INFO")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Group {
                Text("Backend: \(networkManager.baseURL)")
                    .font(.caption)
                Text("User: \(networkManager.currentUser?.id ?? "None")")
                HStack {
                    Text("Child:")
                    Text(networkManager.selectedChild?.name ?? "NONE")
                        .bold()
                        .foregroundColor(networkManager.selectedChild == nil ? .red : .green)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .onAppear {
            print("🔵 MealEntryModal appeared - triggering fetch")
            networkManager.fetchChildren()
        }
    }

    @ViewBuilder private var phaseToggle: some View {
        HStack(spacing: 0) {
            ForEach(Phase.allCases, id: \.self) { p in
                Button {
                    phase = p
                } label: {
                    Text(p.rawValue)
                        .font(.subheadline).fontWeight(.medium)
                        .foregroundColor(phase == p ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(phase == p ? Color.primary : Color.clear)
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.05))
        )
    }

    @ViewBuilder private var photosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(phase == .before ? "Before Photos" : "After Photos")
                    .font(.subheadline).fontWeight(.medium)
                Spacer()
                Button {
                    showSourceSheet = true
                } label: {
                    Label("Add Photo", systemImage: "plus.circle.fill")
                        .labelStyle(.titleAndIcon)
                        .font(.subheadline)
                }
            }

            let images = (phase == .before) ? beforeImages : afterImages
            if images.isEmpty {
                emptyPhotoPlaceholder
                    .onTapGesture { showSourceSheet = true }
            } else {
                ImageGrid(images: images) { index in
                    removeImage(at: index, from: phase)
                }
            }
        }
    }

    private var emptyPhotoPlaceholder: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: "camera.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.primary)
            }
            Text("Add \(phase == .before ? "before" : "after") photos")
                .font(.subheadline).fontWeight(.medium)
            Text("You can still save without photos")
                .font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 144)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.primary.opacity(0.03), Color.primary.opacity(0.08)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                        .foregroundColor(.primary.opacity(0.2))
                )
        )
    }

    private var consumptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Amount Consumed")
                    .font(.subheadline).fontWeight(.medium)
                Spacer()
                Text("\(Int(consumptionPct))%")
                    .font(.subheadline).fontWeight(.medium)
                    .padding(.horizontal, 12).padding(.vertical, 4)
                    .background(Capsule().fill(Color.secondary.opacity(0.1)))
                    .foregroundColor(.primary)
            }

            Slider(value: $consumptionPct, in: 0...100, step: 5)
                .tint(.primary)

            HStack {
                Text("None").font(.caption).foregroundColor(.secondary)
                Spacer()
                Text("Some").font(.caption).foregroundColor(.secondary)
                Spacer()
                Text("Most").font(.caption).foregroundColor(.secondary)
                Spacer()
                Text("All").font(.caption).foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("Notes")
                    .font(.subheadline).fontWeight(.medium)
                Spacer()
                Button {
                    toggleRecording()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isRecording ? "stop.circle.fill" : "mic.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text(isRecording ? "Stop" : "Dictate")
                            .font(.footnote).fontWeight(.medium)
                    }
                    .foregroundColor(isRecording ? .white : .primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().fill(isRecording ? Color.red.opacity(0.9)
                                                   : Color.primary.opacity(0.08))
                    )
                }
                .accessibilityLabel(isRecording ? "Stop dictation" : "Start dictation")
            }

            if isRecording {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        ProgressView().scaleEffect(0.8)
                        Text("Listening…")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    if !liveTranscript.isEmpty {
                        Text(liveTranscript)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.primary.opacity(0.03))
                            )
                    }
                }
                .transition(.opacity)
            }

            ZStack(alignment: .topLeading) {
                if notes.isEmpty && !isRecording {
                    Text("Add any context about the meal…")
                        .foregroundColor(.secondary)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 8)
                }
                TextEditor(text: $notes)
                    .focused($notesFocused)
                    .frame(minHeight: 110)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.primary.opacity(0.03))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                    )
            }
        }
    }

    // MARK: - Actions

    private func append(_ images: [UIImage], to target: Phase) {
        switch target {
        case .before: beforeImages.append(contentsOf: images)
        case .after:  afterImages.append(contentsOf: images)
        }
    }

    private func removeImage(at index: Int, from target: Phase) {
        switch target {
        case .before:
            guard beforeImages.indices.contains(index) else { return }
            beforeImages.remove(at: index)
        case .after:
            guard afterImages.indices.contains(index) else { return }
            afterImages.remove(at: index)
        }
    }

    private func toggleRecording() {
        if isRecording {
            speech.stop()
            isRecording = false
            let final = liveTranscript.trimmingCharacters(in: .whitespacesAndNewlines)
            if !final.isEmpty {
                if notes.isEmpty {
                    notes = final
                } else {
                    notes += (notes.hasSuffix("\n") ? "" : "\n") + final
                }
            }
            liveTranscript = ""
        } else {
            let speechRecorder = speech
            Task {
                let ok = await speechRecorder.prepareAndStart()
                await MainActor.run {
                    if ok { isRecording = true }
                }
            }
        }
    }

    private func saveEntry() {
        print("🔵 Save button tapped")
        print("🔵 Selected child: \(networkManager.selectedChild?.name ?? "NONE")")
        print("🔵 Notes: \(notes)")
        print("🔵 Phase: \(phase.rawValue)")
        
        Task {
            do {
                // Upload photos first (placeholder logic)
                // In a real app, we'd upload images to an endpoint and get URLs back
                let photoUrl = "placeholder_url" 
                
                // Save meal data via API
                guard let child = networkManager.selectedChild else {
                    print("❌ No child selected - cannot save")
                    await MainActor.run {
                        // TODO: Show alert to user
                    }
                    return
                }
                
                print("🔵 Uploading meal for child: \(child.name)")
                try await NetworkManager.shared.uploadMeal(
                    childId: child.id,
                    type: phase == .before ? "PRE_MEAL" : "POST_MEAL",
                    notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                
                print("✅ Saved entry via API")
                dismiss()
            } catch {
                print("❌ Save failed: \(error.localizedDescription)")
                // Show error alert
            }
        }
    }
}

// MARK: - Image Grid

private struct ImageGrid: View {
    let images: [UIImage]
    var onDelete: (Int) -> Void

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(images.enumerated()), id: \.offset) { idx, img in
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 90)
                        .clipped()
                        .cornerRadius(10)

                    Button {
                        onDelete(idx)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                            .padding(6)
                    }
                }
            }
        }
    }
}

// MARK: - Camera Picker (UIKit bridge)

private struct CameraPicker: UIViewControllerRepresentable {
    var onImage: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onImage: onImage) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        // Check if camera is available (won't be on simulator)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            // Fallback to photo library on simulator
            picker.sourceType = .photoLibrary
        }
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onImage: (UIImage?) -> Void
        init(onImage: @escaping (UIImage?) -> Void) { self.onImage = onImage }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.originalImage] as? UIImage
            picker.dismiss(animated: true) { self.onImage(image) }
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true) { self.onImage(nil) }
        }
    }
}

// MARK: - Speech Recorder

final class SpeechRecorder: NSObject, ObservableObject {
    @Published var transcript: String = ""

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: Locale.current.identifier))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    private func requestSpeechAuth() async -> Bool {
        await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status == .authorized)
            }
        }
    }

    private func requestMicPermission() async -> Bool {
        await withCheckedContinuation { cont in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                cont.resume(returning: granted)
            }
        }
    }

    /// Requests permission (speech + mic), configures audio, and starts recognition.
    func prepareAndStart() async -> Bool {
        guard await requestSpeechAuth() else { return false }
        guard await requestMicPermission() else { return false }

        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true, options: [.notifyOthersOnDeactivation])
        } catch { return false }

        request = SFSpeechAudioBufferRecognitionRequest()
        request?.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.request?.append(buffer)
        }

        audioEngine.prepare()
        do { try audioEngine.start() } catch { return false }

        task = recognizer?.recognitionTask(with: request!) { [weak self] result, error in
            guard let self else { return }
            if let result = result {
                self.transcript = result.bestTranscription.formattedString
            }
            if error != nil || (result?.isFinal ?? false) {
                self.audioEngine.stop()
                self.request?.endAudio()
            }
        }
        return true
    }

    func stop() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        request?.endAudio()
        task?.cancel()
        task = nil
        request = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
