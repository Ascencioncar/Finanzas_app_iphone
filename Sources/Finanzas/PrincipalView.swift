import SwiftUI

/// Contenedor principal con las cuatro secciones de la app.
struct PrincipalView: View {
    var body: some View {
        TabView {
            InicioView()
                .tabItem { Label("Inicio", systemImage: "chart.pie.fill") }

            CuentasView()
                .tabItem { Label("Cuentas", systemImage: "building.columns.fill") }

            TarjetasView()
                .tabItem { Label("Tarjetas", systemImage: "creditcard.fill") }

            MensualView()
                .tabItem { Label("Mensual", systemImage: "calendar") }
        }
    }
}
