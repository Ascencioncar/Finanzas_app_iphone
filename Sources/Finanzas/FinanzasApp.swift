import SwiftUI

/// Punto de entrada de la app. Crea el store único y lo inyecta en el
/// environment para que todas las vistas lo compartan.
@main
struct FinanzasApp: App {
    @State private var store = FinanzasStore()

    var body: some Scene {
        WindowGroup {
            PrincipalView()
                .environment(store)
        }
    }
}
