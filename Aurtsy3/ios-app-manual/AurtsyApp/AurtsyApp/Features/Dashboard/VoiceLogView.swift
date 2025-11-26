import SwiftUI
import Speech
import AVFoundation

struct VoiceLogView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var network: NetworkManager
    
    @State private var isRecording = false
    @State private var transcript = ""
    @State private var isProcessing = false
    @State private var showSaveConfirmation = false
    @State private var errorMessage: String?
    
    // Pulse animation state
    @State private var pulse1 = false
    @State private var pulse2 = false
    
    // Speech Recognition
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Status Text
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Text(isRecording ? "Listening..." : (transcript.isEmpty ? "Tap to Speak" : "Transcript"))
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                // Microphone Button
                ZStack {
                    // Pulse Circles
                    if isRecording {
                        Circle()
                            .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                            .scaleEffect(pulse1 ? 1.5 : 1)
                            .opacity(pulse1 ? 0 : 1)
                            .frame(width: 100, height: 100)
                            .onAppear {
                                withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                                    pulse1 = true
                                }
                            }
                        
                        Circle()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                            .scaleEffect(pulse2 ? 1.5 : 1)
                            .opacity(pulse2 ? 0 : 1)
                            .frame(width: 100, height: 100)
                            .onAppear {
                                withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false).delay(0.5)) {
                                    pulse2 = true
                                }
                            }
                    }
                    
                    // Main Button
                    Button(action: toggleRecording) {
                        ZStack {
                            Circle()
                                .fill(isRecording ? Color.red : Color.blue)
                                .frame(width: 100, height: 100)
                                .shadow(radius: 10)
                            
                            Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                    }
                }
                
                // Transcript / Notes Area
                VStack(alignment: .leading) {
                    HStack {
                        Text("Notes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        if !isRecording && !transcript.isEmpty {
                            Text("Tap text to edit")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.leading, 4)
                    
                    TextEditor(text: $transcript)
                        .frame(height: 150)
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isRecording ? Color.blue : Color.gray.opacity(0.2), lineWidth: isRecording ? 2 : 1)
                        )
                        .disabled(isRecording) // Disable editing while recording
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action Buttons
                if !isRecording && !transcript.isEmpty {
                    HStack(spacing: 20) {
                        // Discard Button
                        Button(action: {
                            transcript = ""
                            errorMessage = nil
                        }) {
                            VStack {
                                Image(systemName: "trash")
                                    .font(.system(size: 20))
                                Text("Discard")
                                    .font(.caption)
                            }
                            .foregroundColor(.red)
                            .frame(width: 60)
                        }
                        
                        // Save Button
                        Button(action: saveLog) {
                            HStack {
                                if isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Confirm & Save")
                                        .fontWeight(.semibold)
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        }
                        .disabled(isProcessing)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                } else {
                    // Placeholder space to keep layout stable
                    Color.clear.frame(height: 80)
                }
            }
            .navigationTitle("Voice Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                requestSpeechAuthorization()
            }
        }
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    break
                case .denied:
                    self.errorMessage = "Speech recognition access denied"
                case .restricted:
                    self.errorMessage = "Speech recognition restricted on this device"
                case .notDetermined:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Audio session error: \(error.localizedDescription)"
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "Unable to create recognition request"
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                self.transcript = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.isRecording = false
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        self.audioEngine.prepare()
        
        do {
            try self.audioEngine.start()
            self.isRecording = true
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Audio engine couldn't start: \(error.localizedDescription)"
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isRecording = false
    }
    
    private func saveLog() {
        guard !transcript.isEmpty else { return }
        
        isProcessing = true
        
        // Use AI to process the voice log
        if let child = network.selectedChild {
            network.processVoiceLog(
                childId: child.id,
                text: transcript
            )
            
            // Simulate network delay for UI feedback
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isProcessing = false
                dismiss()
            }
        }
    }
}
