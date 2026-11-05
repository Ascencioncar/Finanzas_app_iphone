import SwiftUI

/// Formulario para registrar un nuevo movimiento (ingreso o gasto),
/// opcionalmente asociado a una cuenta.
struct AgregarMovimientoView: View {
    @Environment(FinanzasStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var cuentaPreseleccionada: CuentaBancaria?

    @State private var tipo: TipoMovimiento = .gasto
    @State private var montoTexto = ""
    @State private var categoria: Categoria = .comida
    @State private var nota = ""
    @State private var fecha = Date()
    @State private var cuentaID: UUID?

    private var valido: Bool { montoDesde(montoTexto) > 0 }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Tipo", selection: $tipo) {
                        ForEach(TipoMovimiento.allCases) { t in
                            Text(t.nombre).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Monto") {
                    CampoMonto(titulo: "0", texto: $montoTexto)
                }

                if !store.cuentas.isEmpty {
                    Section("Cuenta") {
                        Picker("Cuenta", selection: $cuentaID) {
                            Text("Sin cuenta").tag(UUID?.none)
                            ForEach(store.cuentas) { cuenta in
                                Text(cuenta.nombre).tag(Optional(cuenta.id))
                            }
                        }
                    }
                }

                Section("Categoría") {
                    Picker("Categoría", selection: $categoria) {
                        ForEach(Categoria.allCases) { c in
                            Label(c.nombre, systemImage: c.icono).tag(c)
                        }
                    }
                }

                Section("Detalles") {
                    TextField("Nota (opcional)", text: $nota, axis: .vertical)
                        .lineLimit(1...3)
                    DatePicker("Fecha", selection: $fecha, displayedComponents: .date)
                }
            }
            .navigationTitle("Nuevo movimiento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar", action: guardar).disabled(!valido)
                }
            }
            .onAppear {
                if cuentaID == nil { cuentaID = cuentaPreseleccionada?.id }
            }
        }
    }

    private func guardar() {
        let movimiento = Movimiento(
            tipo: tipo,
            monto: montoDesde(montoTexto),
            categoria: categoria,
            nota: nota.trimmingCharacters(in: .whitespacesAndNewlines),
            fecha: fecha,
            cuentaID: cuentaID
        )
        store.agregar(movimiento)
        dismiss()
    }
}
