import SwiftUI

/// Detalle de una cuenta: saldo, sus movimientos y sus transferencias.
struct CuentaDetalleView: View {
    @Environment(FinanzasStore.self) private var store
    let cuenta: CuentaBancaria

    @State private var mostrandoMovimiento = false
    @State private var mostrandoTransferencia = false

    private var movimientos: [Movimiento] { store.movimientos(de: cuenta) }
    private var transferencias: [Transferencia] { store.transferencias(de: cuenta) }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Saldo actual")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(store.formatearMoneda(store.saldo(de: cuenta)))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    if !cuenta.banco.isEmpty {
                        Text("\(cuenta.banco) · \(cuenta.tipo.nombre)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Movimientos") {
                if movimientos.isEmpty {
                    Text("Sin movimientos en esta cuenta.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(movimientos) { m in
                        FilaMovimiento(movimiento: m)
                    }
                    .onDelete { offsets in
                        store.eliminarMovimientos(en: offsets, de: movimientos)
                    }
                }
            }

            if !transferencias.isEmpty {
                Section("Transferencias") {
                    ForEach(transferencias) { t in
                        FilaTransferencia(transferencia: t)
                    }
                }
            }
        }
        .navigationTitle(cuenta.nombre)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        mostrandoMovimiento = true
                    } label: {
                        Label("Movimiento", systemImage: "plus.circle")
                    }
                    Button {
                        mostrandoTransferencia = true
                    } label: {
                        Label("Transferencia", systemImage: "arrow.left.arrow.right")
                    }
                    .disabled(store.cuentas.count < 2)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $mostrandoMovimiento) {
            AgregarMovimientoView(cuentaPreseleccionada: cuenta)
        }
        .sheet(isPresented: $mostrandoTransferencia) {
            TransferenciaView(origenPreseleccionado: cuenta)
        }
    }
}

/// Fila de un movimiento (ingreso o gasto).
struct FilaMovimiento: View {
    @Environment(FinanzasStore.self) private var store
    let movimiento: Movimiento

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: movimiento.categoria.icono)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(movimiento.tipo == .ingreso ? Color.green : Color.red, in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(movimiento.categoria.nombre)
                if !movimiento.nota.isEmpty {
                    Text(movimiento.nota)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Text(movimiento.fecha, format: .dateTime.day().month().year())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(store.formatearMoneda(movimiento.montoConSigno))
                .font(.headline)
                .foregroundStyle(movimiento.tipo == .ingreso ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}
