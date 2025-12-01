import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: FaceTrackingViewModel
    @State private var isOverlayFrozen = false
    @State private var showsWebExperience = false

    var body: some View {
        ZStack(alignment: .bottom) {
            CameraPreviewView(session: viewModel.cameraSession)
                .ignoresSafeArea()
                .overlay(
                    Group {
                        if let guidelineState = viewModel.guidelineState {
                            GuidelineOverlayView(state: guidelineState, isFrozen: isOverlayFrozen)
                        } else {
                            Text("Position your face within the frame")
                                .font(.headline)
                                .padding(12)
                                .background(.ultraThinMaterial, in: Capsule())
                        }
                    }
                )

            controlPanel
                .padding()
        }
        .task {
            await viewModel.start()
        }
        .alert(item: $viewModel.error) { error in
            Alert(title: Text("Camera Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showsWebExperience) {
            WebExperienceView {
                showsWebExperience = false
            }
            .presentationDetents([.large])
        }
    }

    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.statusMessage)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

            HStack(spacing: 16) {
                Button(action: toggleFreeze) {
                    Label(isOverlayFrozen ? "Resume" : "Freeze", systemImage: isOverlayFrozen ? "play.fill" : "pause.fill")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.2), in: Capsule())
                }

                Button(action: viewModel.captureFrame) {
                    Label("Snapshot", systemImage: "camera.fill")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.2), in: Capsule())
                }

                Button(action: { showsWebExperience = true }) {
                    Label("Lookbook", systemImage: "sparkles")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.2), in: Capsule())
                }
            }
            .labelStyle(.titleAndIcon)
            .foregroundColor(.white)
        }
    }

    private func toggleFreeze() {
        isOverlayFrozen.toggle()
        viewModel.setOverlayFrozen(isOverlayFrozen)
    }
}

#Preview {
    ContentView()
        .environmentObject(FaceTrackingViewModel.preview)
}
