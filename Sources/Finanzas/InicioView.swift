import SwiftUI

/// Pantalla de resumen: visión global de todo el dinero.
struct InicioView: View {
    @Environment(FinanzasStore.self) private var store

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    balance
                    mensual
                    cuentas
                    tarjetas
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Finanzas")
        }
    }

    // MARK: - Balance total

    private var balance: some View {
        Tarjeta {
            VStack(alignment: .leading, spacing: 6) {
                Text("Balance total")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(store.formatearMoneda(store.balanceTotal))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(store.balanceTotal >= 0 ? .green : .red)
                Text("Suma de todas tus cuentas")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Resumen mensual

    private var mensual: some View {
        Tarjeta {
            VStack(alignment: .leading, spacing: 10) {
                Text("Este mes")
                    .font(.headline)
                FilaValor(
                    titulo: "Ingresos",
                    valor: store.formatearMoneda(store.totalIngresosMensuales),
                    color: .green
                )
                FilaValor(
                    titulo: "Obligaciones",
                    valor: store.formatearMoneda(store.totalObligacionesMensuales),
                    color: .red
                )
                Divider()
                FilaValor(
                    titulo: "Disponible",
                    valor: store.formatearMoneda(store.disponibleMensual),
                    color: store.disponibleMensual >= 0 ? .green : .red
                )
            }
        }
    }

    // MARK: - Cuentas

    private var cuentas: some View {
        Tarjeta {
            VStack(alignment: .leading, spacing: 10) {
                Text("Cuentas")
                    .font(.headline)
                if store.cuentas.isEmpty {
                    Text("Aún no tienes cuentas. Agrégalas en la pestaña Cuentas.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.cuentas) { cuenta in
                        HStack {
                            Circle()
                                .fill(Color(hex: cuenta.colorHex))
                                .frame(width: 10, height: 10)
                            Text(cuenta.nombre)
                            Spacer()
                            Text(store.formatearMoneda(store.saldo(de: cuenta)))
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Tarjetas de crédito

    private var tarjetas: some View {
        Tarjeta {
            VStack(alignment: .leading, spacing: 10) {
                Text("Tarjetas de crédito")
                    .font(.headline)
                if store.tarjetas.isEmpty {
                    Text("Agrega tus tarjetas en la pestaña Tarjetas.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    FilaValor(
                        titulo: "Deuda total",
                        valor: store.formatearMoneda(store.deudaTotalTarjetas),
                        color: .red
                    )
                    FilaValor(
                        titulo: "Cuota mínima",
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
}
