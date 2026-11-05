import SwiftUI

/// Tarjeta genérica con fondo de material y esquinas redondeadas.
struct Tarjeta<Contenido: View>: View {
    @ViewBuilder var contenido: Contenido

    var body: some View {
        contenido
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}

/// Fila con etiqueta a la izquierda y valor monetario a la derecha.
struct FilaValor: View {
    let titulo: String
    let valor: String
    var color: Color = .primary

    var body: some View {
        HStack {
            Text(titulo).foregroundStyle(.secondary)
            Spacer()
            Text(valor).fontWeight(.semibold).foregroundStyle(color)
        }
    }
}

/// Campo de texto para capturar un monto en pesos, con teclado decimal.
struct CampoMonto: View {
    let titulo: String
    @Binding var texto: String

    var body: some View {
        HStack {
            Text("$").foregroundStyle(.secondary)
            TextField(titulo, text: $texto)
                .keyboardType(.decimalPad)
        }
    }
}

/// Selector de color a partir de la paleta.
struct SelectorColor: View {
    @Binding var seleccion: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Paleta.colores, id: \.self) { hex in
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 30, height: 30)
                        .overlay {
                            if hex == seleccion {
                                Image(systemName: "checkmark")
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                            }
                        }
                        .onTapGesture { seleccion = hex }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

/// Convierte un texto de monto (con coma o punto) a Double.
func montoDesde(_ texto: String) -> Double {
    Double(texto.replacingOccurrences(of: ",", with: ".")) ?? 0
}
