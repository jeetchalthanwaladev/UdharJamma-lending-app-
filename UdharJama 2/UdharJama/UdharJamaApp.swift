import SwiftUI

@main
struct UdharJamaApp: App {

    let persistenceController = PersistenceController.shared

    init() {
        _ = NotificationManager.shared   // delegate setup
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(
                    \.managedObjectContext,
                    persistenceController.container.viewContext
                )
                .onAppear {
                    NotificationManager.shared.requestPermission()
                }
        }
    }
}
