import SwiftUI

@main
struct LaceFrontWigsApp: App {
    @StateObject private var viewModel = FaceTrackingViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
