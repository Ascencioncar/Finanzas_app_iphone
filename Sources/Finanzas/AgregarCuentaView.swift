import SwiftUI

/// Formulario para crear una nueva cuenta bancaria o de efectivo.
struct AgregarCuentaView: View {
    @Environment(FinanzasStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var nombre = ""
    @State private var banco = ""
    @State private var tipo: TipoCuenta = .ahorros
    @State private var saldoInicialTexto = ""
    @State private var colorHex = Paleta.colores[0]

    private var valido: Bool {
        !nombre.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Datos de la cuenta") {
                    TextField("Nombre (ej. Ahorros Bancolombia)", text: $nombre)
                    TextField("Banco", text: $banco)
                    Picker("Tipo", selection: $tipo) {
                        ForEach(TipoCuenta.allCases) { t in
                            Text(t.nombre).tag(t)
                        }
                    }
                }

                Section("Saldo inicial") {
                    CampoMonto(titulo: "0", texto: $saldoInicialTexto)
                }

                Section("Color") {
                    SelectorColor(seleccion: $colorHex)
                }
            }
            .navigationTitle("Nueva cuenta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar", action: guardar).disabled(!valido)
                }
            }
        }
    }

    private func guardar() {
        let cuenta = CuentaBancaria(
            nombre: nombre.trimmingCharacters(in: .whitespaces),
            banco: banco.trimmingCharacters(in: .whitespaces),
            tipo: tipo,
            saldoInicial: montoDesde(saldoInicialTexto),
            colorHex: colorHex
        )
        store.agregarCuenta(cuenta)
        dismiss()
    }
}
