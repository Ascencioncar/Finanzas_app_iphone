import SwiftUI

/// Paleta de colores para asignar a cuentas y tarjetas.
enum Paleta {
    static let colores: [String] = [
        "#34C759", // verde
        "#007AFF", // azul
        "#5856D6", // índigo
        "#FF9500", // naranja
        "#FF2D55", // rosa
        "#AF52DE", // morado
        "#FF3B30", // rojo
        "#30B0C7", // cian
        "#8E8E93"  // gris
    ]
}

extension Color {
    /// Crea un Color a partir de un hex tipo "#RRGGBB" (o "RRGGBB").
    init(hex: String) {
        let limpio = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var valor: UInt64 = 0
        Scanner(string: limpio).scanHexInt64(&valor)
        let r, g, b: Double
        if limpio.count == 6 {
            r = Double((valor & 0xFF0000) >> 16) / 255
            g = Double((valor & 0x00FF00) >> 8) / 255
            b = Double(valor & 0x0000FF) / 255
        } else {
            r = 0.5; g = 0.5; b = 0.5
        }
        self = Color(red: r, green: g, blue: b)
    }
}
