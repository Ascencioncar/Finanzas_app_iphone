import SwiftUI

/// Lista de cuentas bancarias con su saldo. Permite agregar cuentas,
/// registrar transferencias y entrar al detalle de cada cuenta.
struct CuentasView: View {
    @Environment(FinanzasStore.self) private var store
    @State private var mostrandoAgregarCuenta = false
    @State private var mostrandoTransferencia = false
    @State private var mostrandoAgregarMovimiento = false

    var body: some View {
        NavigationStack {
            List {
                if store.cuentas.isEmpty {
                    ContentUnavailableView {
                        Label("Sin cuentas", systemImage: "building.columns")
                    } description: {
                        Text("Agrega tu primera cuenta de banco o efectivo con el botón +.")
                    }
                } else {
                    Section {
                        ForEach(store.cuentas) { cuenta in
                            NavigationLink(value: cuenta) {
                                FilaCuenta(cuenta: cuenta)
                            }
                        }
                    }

                    Section {
                        Button {
                            mostrandoTransferencia = true
                        } label: {
                            Label("Nueva transferencia", systemImage: "arrow.left.arrow.right")
                        }
                        .disabled(store.cuentas.count < 2)

                        Button {
                            mostrandoAgregarMovimiento = true
                        } label: {
                            Label("Nuevo movimiento", systemImage: "plus.circle")
                        }
                    }

                    if !store.transferenciasOrdenadas.isEmpty {
                        Section("Transferencias recientes") {
                            ForEach(store.transferenciasOrdenadas.prefix(10)) { t in
                                NavigationLink(value: t) {
                                    FilaTransferencia(transferencia: t)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Cuentas")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            mostrandoAgregarCuenta = true
                        } label: {
                            Label("Nueva cuenta", systemImage: "building.columns")
                        }
                        Button {
                            mostrandoAgregarMovimiento = true
                        } label: {
                            Label("Nuevo movimiento", systemImage: "plus.circle")
                        }
                        Button {
                            mostrandoTransferencia = true
                        } label: {
                            Label("Nueva transferencia", systemImage: "arrow.left.arrow.right")
                        }
                        .disabled(store.cuentas.count < 2)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: CuentaBancaria.self) { cuenta in
                CuentaDetalleView(cuenta: cuenta)
            }
            .navigationDestination(for: Transferencia.self) { t in
                TransferenciaDetalleView(transferencia: t)
            }
            .sheet(isPresented: $mostrandoAgregarCuenta) { AgregarCuentaView() }
            .sheet(isPresented: $mostrandoTransferencia) { TransferenciaView() }
            .sheet(isPresented: $mostrandoAgregarMovimiento) { AgregarMovimientoView() }
        }
    }
}

struct FilaCuenta: View {
    @Environment(FinanzasStore.self) private var store
    let cuenta: CuentaBancaria

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: cuenta.tipo.icono)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Color(hex: cuenta.colorHex), in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(cuenta.nombre).font(.body)
                Text(cuenta.banco.isEmpty ? cuenta.tipo.nombre : cuenta.banco)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(store.formatearMoneda(store.saldo(de: cuenta)))
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}

struct FilaTransferencia: View {
    @Environment(FinanzasStore.self) private var store
    let transferencia: Transferencia

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.left.arrow.right")
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Color.blue, in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text("\(store.cuenta(transferencia.cuentaOrigenID)?.nombre ?? "—") → \(store.cuenta(transferencia.cuentaDestinoID)?.nombre ?? "—")")
                    .font(.subheadline)
                    .lineLimit(1)
                Text(transferencia.fecha, format: .dateTime.day().month().year())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if transferencia.comprobanteArchivo != nil {
                Image(systemName: "paperclip")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(store.formatearMoneda(transferencia.monto))
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}
