import AVFoundation
import Combine
import SwiftUI
@preconcurrency import Vision

@MainActor
final class FaceTrackingViewModel: ObservableObject {
    @Published var guidelineState: WigGuidelineState?
    @Published var statusMessage: String = "Center your face and keep still"
    @Published var error: CameraSessionManager.CameraError?

    let cameraSessionManager = CameraSessionManager()
    var cameraSession: AVCaptureSession { cameraSessionManager.session }

    private let processingQueue = DispatchQueue(label: "com.lacefrontwigs.vision", qos: .userInitiated)
    private let guidelineCalculator = WigGuidelineCalculator()
    private var cancellables = Set<AnyCancellable>()
    private var overlayFrozen = false
    private var lastUpdate = Date.distantPast
    private let throttlingInterval: TimeInterval = 0.08

    func start() async {
        do {
            try await cameraSessionManager.configureSession()
            cameraSessionManager.onFrame = { [weak self] sampleBuffer in
                self?.handle(sampleBuffer: sampleBuffer)
            }
            cameraSessionManager.start()
        } catch let cameraError as CameraSessionManager.CameraError {
            error = cameraError
        } catch {
            statusMessage = "Unexpected error: \(error.localizedDescription)"
        }
    }

    func stop() {
        cameraSessionManager.stop()
    }

    private func handle(sampleBuffer: CMSampleBuffer) {
        guard !overlayFrozen else { return }

        let current = Date()
        guard current.timeIntervalSince(lastUpdate) > throttlingInterval else { return }
        lastUpdate = current

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        processingQueue.async { [weak self, pixelBuffer] in
            guard let self else { return }
            let request = VNDetectFaceLandmarksRequest { [weak self] request, error in
                guard let self else { return }
                if let error {
                    Task { @MainActor in
                        self.statusMessage = "Vision error: \(error.localizedDescription)"
                    }
                    return
                }

                guard let observations = request.results as? [VNFaceObservation], let face = observations.first else {
                    Task { @MainActor in
                        self.guidelineState = nil
                        self.statusMessage = "No face detected — keep your head steady"
                    }
                    return
                }

                let newState = self.guidelineCalculator.guidelines(for: face)
                Task { @MainActor in
                    self.guidelineState = newState
                    self.statusMessage = newState.advice
                }
            }

            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored, options: [:])
            do {
                try handler.perform([request])
            } catch {
                Task { @MainActor in
                    self.statusMessage = "Processing error: \(error.localizedDescription)"
                }
            }
        }
    }

    func captureFrame() {
        overlayFrozen = true
        statusMessage = "Snapshot saved. Resume when ready."
        // Real capture/export pipeline would go here
    }

    func setOverlayFrozen(_ frozen: Bool) {
        overlayFrozen = frozen
        statusMessage = frozen ? "Frozen overlay — adjust wig referencing the guide" : "Live guidance active"
    }
}

extension FaceTrackingViewModel {
    static let preview: FaceTrackingViewModel = {
        let vm = FaceTrackingViewModel()
        vm.guidelineState = WigGuidelineState(
            hairlineCurve: [CGPoint(x: 0.2, y: 0.2), CGPoint(x: 0.5, y: 0.18), CGPoint(x: 0.8, y: 0.2)],
            earToEar: .init(start: CGPoint(x: 0.1, y: 0.4), end: CGPoint(x: 0.9, y: 0.4)),
            centerLine: .init(start: CGPoint(x: 0.5, y: 0.1), end: CGPoint(x: 0.5, y: 0.9)),
            temples: [CGPoint(x: 0.2, y: 0.35), CGPoint(x: 0.8, y: 0.35)],
            tiltDegrees: 2.1,
            foreheadOffsetMillimeters: 5,
            advice: "Shift the lace 0.5 cm back to protect edges"
        )
        return vm
    }()
}
