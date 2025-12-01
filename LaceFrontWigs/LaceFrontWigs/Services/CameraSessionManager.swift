import AVFoundation
import Foundation

final class CameraSessionManager: NSObject {
    let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "com.lacefrontwigs.camera")
    private var permissionsGranted = false

    var onFrame: ((CMSampleBuffer) -> Void)?

    func configureSession() async throws {
        guard await requestPermission() else {
            throw CameraError.permissionDenied
        }

        session.beginConfiguration()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            session.commitConfiguration()
            throw CameraError.missingDevice
        }

        guard let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) else {
            session.commitConfiguration()
            throw CameraError.unableToAddInput
        }
        session.addInput(input)

        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]

        guard session.canAddOutput(videoOutput) else {
            session.commitConfiguration()
            throw CameraError.unableToAddOutput
        }
        session.addOutput(videoOutput)

        videoOutput.connection(with: .video)?.isEnabled = true
        videoOutput.connection(with: .video)?.isVideoMirrored = true

        session.commitConfiguration()
    }

    func start() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    private func requestPermission() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionsGranted = true
            return true
        case .notDetermined:
            permissionsGranted = await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    continuation.resume(returning: granted)
                }
            }
            return permissionsGranted
        default:
            permissionsGranted = false
            return false
        }
    }
}

extension CameraSessionManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        DispatchQueue.main.async { [weak self] in
            self?.onFrame?(sampleBuffer)
        }
    }
}

extension CameraSessionManager {
    enum CameraError: LocalizedError, Identifiable {
        case permissionDenied
        case missingDevice
        case unableToAddInput
        case unableToAddOutput

        var id: String { localizedDescription }

        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "Camera permission is required to place your wig. Enable it in Settings."
            case .missingDevice:
                return "We couldn’t access the front camera on this device."
            case .unableToAddInput:
                return "The camera feed could not be added to the session."
            case .unableToAddOutput:
                return "We were not able to read frames from the camera."
            }
        }

        var message: String { errorDescription ?? "Unknown camera error" }
    }
}
