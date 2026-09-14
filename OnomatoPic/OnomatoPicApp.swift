import SwiftUI
import SwiftData

@main
struct OnomatoPicApp: App{
    var body: some Scene {
        WindowGroup {ContentView()}
            .modelContainer(for: [PhotoRecord.self,OnomatopeFinding.self])
    }
}
