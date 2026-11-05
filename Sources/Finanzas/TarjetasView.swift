import SwiftUI

/// Lista de tarjetas de crédito con su deuda, cuota mínima e interés.
struct TarjetasView: View {
    @Environment(FinanzasStore.self) private var store
    @State private var mostrandoAgregar = false
    @State private var tarjetaAEditar: TarjetaCredito?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if store.tarjetas.isEmpty {
                        ContentUnavailableView {
                            Label("Sin tarjetas", systemImage: "creditcard")
                        } description: {
                            Text("Agrega tus tarjetas de crédito con el botón +.")
                        }
                        .padding(.top, 60)
                    } else {
                        resumen
                        ForEach(store.tarjetas) { tarjeta in
                            TarjetaCreditoCard(tarjeta: tarjeta)
                                .onTapGesture { tarjetaAEditar = tarjeta }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Tarjetas")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        mostrandoAgregar = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $mostrandoAgregar) { AgregarTarjetaView() }
            .sheet(item: $tarjetaAEditar) { tarjeta in
                AgregarTarjetaView(tarjeta: tarjeta)
            }
        }
    }

    private var resumen: some View {
        Tarjeta {
            VStack(alignment: .leading, spacing: 10) {
                Text("Resumen de tarjetas").font(.headline)
                FilaValor(
                    titulo: "Deuda total",
                    valor: store.formatearMoneda(store.deudaTotalTarjetas),
                    color: .red
                )
                FilaValor(
                    titulo: "Cuota mínima total",
                    valor: store.formatearMoneda(store.cuotaMinimaTotalTarjetas)
                )
                FilaValor(
                    titulo: "Interés mensual estimado",
                    valor: store.formatearMoneda(store.interesMensualTotalTarjetas),
                    color: .orange
                )
            }
        }
    }
}

/// Tarjeta visual que representa una tarjeta de crédito.
struct TarjetaCreditoCard: View {
    @Environment(FinanzasStore.self) private var store
    let tarjeta: TarjetaCredito

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(tarjeta.nombre)
                        .font(.headline)
                        .foregroundStyle(.white)
                    if !tarjeta.banco.isEmpty {
                        Text(tarjeta.banco)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
                Spacer()
                Image(systemName: "creditcard.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.9))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Deuda total")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                Text(store.formatearMoneda(tarjeta.saldoTotal))
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            if let uso = tarjeta.usoCupo {
                ProgressView(value: uso)
                    .tint(.white)
                if let disponible = tarjeta.cupoDisponible {
                    Text("Disponible: \(store.formatearMoneda(disponible))")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }

            HStack {
                etiqueta("Cuota mínima", store.formatearMoneda(tarjeta.cuotaMinima))
                Spacer()
                etiqueta("Interés", "\(tarjeta.tasaInteresMensual.formatted())% mensual")
            }
            HStack {
                etiqueta("Interés estimado", store.formatearMoneda(tarjeta.interesMensualEstimado))
                Spacer()
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color(hex: tarjeta.colorHex), Color(hex: tarjeta.colorHex).opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 18)
        )
    }

    private func etiqueta(_ titulo: String, _ valor: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(titulo)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.85))
            Text(valor)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
    }
}
