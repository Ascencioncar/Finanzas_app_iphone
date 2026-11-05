import SwiftUI

/// Formulario para crear o editar una tarjeta de crédito.
struct AgregarTarjetaView: View {
    @Environment(FinanzasStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    /// Si se pasa, el formulario edita esa tarjeta; si es nil, crea una nueva.
    var tarjeta: TarjetaCredito?

    @State private var nombre = ""
    @State private var banco = ""
    @State private var saldoTotalTexto = ""
    @State private var cuotaMinimaTexto = ""
    @State private var tasaTexto = ""
    @State private var cupoTexto = ""
    @State private var colorHex = Paleta.colores[3]

    private var editando: Bool { tarjeta != nil }
    private var valido: Bool {
        !nombre.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Tarjeta") {
                    TextField("Nombre (ej. Visa Oro)", text: $nombre)
                    TextField("Banco", text: $banco)
                }

                Section("Deuda e interés") {
                    campo("Deuda total", $saldoTotalTexto)
                    campo("Cuota mínima", $cuotaMinimaTexto)
                    HStack {
                        Text("Interés mensual")
                        Spacer()
                        TextField("0", text: $tasaTexto)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("%").foregroundStyle(.secondary)
                    }
                }

                Section("Cupo (opcional)") {
                    campo("Cupo total", $cupoTexto)
                }

                Section("Color") {
                    SelectorColor(seleccion: $colorHex)
                }

                if editando, let tarjeta {
                    Section {
                        Button(role: .destructive) {
                            store.eliminarTarjeta(tarjeta)
                            dismiss()
                        } label: {
                            Label("Eliminar tarjeta", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle(editando ? "Editar tarjeta" : "Nueva tarjeta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar", action: guardar).disabled(!valido)
                }
            }
            .onAppear(perform: precargar)
        }
    }

    private func campo(_ titulo: String, _ binding: Binding<String>) -> some View {
        HStack {
            Text(titulo)
            Spacer()
            Text("$").foregroundStyle(.secondary)
            TextField("0", text: binding)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 120)
        }
    }

    private func precargar() {
        guard let tarjeta, nombre.isEmpty else { return }
        nombre = tarjeta.nombre
        banco = tarjeta.banco
        saldoTotalTexto = String(tarjeta.saldoTotal)
        cuotaMinimaTexto = String(tarjeta.cuotaMinima)
        tasaTexto = String(tarjeta.tasaInteresMensual)
        cupoTexto = tarjeta.cupoTotal.map { String($0) } ?? ""
        colorHex = tarjeta.colorHex
    }

    private func guardar() {
        let cupo = cupoTexto.trimmingCharacters(in: .whitespaces).isEmpty
            ? nil : montoDesde(cupoTexto)
        var nueva = TarjetaCredito(
            id: tarjeta?.id ?? UUID(),
            nombre: nombre.trimmingCharacters(in: .whitespaces),
            banco: banco.trimmingCharacters(in: .whitespaces),
            saldoTotal: montoDesde(saldoTotalTexto),
            cuotaMinima: montoDesde(cuotaMinimaTexto),
            tasaInteresMensual: montoDesde(tasaTexto),
            cupoTotal: cupo,
            colorHex: colorHex
        )
        if editando {
            store.actualizar(nueva)
        } else {
            nueva.id = UUID()
            store.agregar(nueva)
        }
        dismiss()
    }
}
