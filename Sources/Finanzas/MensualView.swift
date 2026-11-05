import SwiftUI

/// Control mensual: ingresos fijos y obligaciones (gastos fijos) del mes.
struct MensualView: View {
    @Environment(FinanzasStore.self) private var store
    @State private var mostrandoAgregar = false

    private var ingresos: [ItemMensual] { store.itemsMensuales(.ingreso) }
    private var obligaciones: [ItemMensual] { store.itemsMensuales(.obligacion) }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    FilaValor(
                        titulo: "Ingresos del mes",
                        valor: store.formatearMoneda(store.totalIngresosMensuales),
                        color: .green
                    )
                    FilaValor(
                        titulo: "Obligaciones del mes",
                        valor: store.formatearMoneda(store.totalObligacionesMensuales),
                        color: .red
                    )
                    FilaValor(
                        titulo: "Disponible",
                        valor: store.formatearMoneda(store.disponibleMensual),
                        color: store.disponibleMensual >= 0 ? .green : .red
                    )
                }

                Section("Ingresos fijos") {
                    if ingresos.isEmpty {
                        Text("Agrega tus ingresos mensuales (sueldo, arriendo, etc.).")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(ingresos) { item in FilaItemMensual(item: item) }
                            .onDelete { borrar(ingresos, $0) }
                    }
                }

                Section("Obligaciones") {
                    if obligaciones.isEmpty {
                        Text("Agrega tus gastos fijos (servicios, cuotas, suscripciones).")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(obligaciones) { item in FilaItemMensual(item: item) }
                            .onDelete { borrar(obligaciones, $0) }
                    }
                }
            }
            .navigationTitle("Mensual")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        mostrandoAgregar = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $mostrandoAgregar) { AgregarItemMensualView() }
        }
    }

    private func borrar(_ lista: [ItemMensual], _ offsets: IndexSet) {
        offsets.map { lista[$0] }.forEach { store.eliminarItemMensual($0) }
    }
}

struct FilaItemMensual: View {
    @Environment(FinanzasStore.self) private var store
    let item: ItemMensual

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.nombre)
                if let dia = item.diaDelMes {
                    Text("Día \(dia) de cada mes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(store.formatearMoneda(item.monto))
                .fontWeight(.semibold)
                .foregroundStyle(item.tipo == .ingreso ? .green : .red)
        }
    }
}

/// Formulario para agregar un ingreso fijo o una obligación mensual.
struct AgregarItemMensualView: View {
    @Environment(FinanzasStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var tipo: TipoItemMensual = .obligacion
    @State private var nombre = ""
    @State private var montoTexto = ""
    @State private var tieneDia = false
    @State private var dia = 1

    private var valido: Bool {
        !nombre.trimmingCharacters(in: .whitespaces).isEmpty && montoDesde(montoTexto) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Tipo", selection: $tipo) {
                    ForEach(TipoItemMensual.allCases) { t in
                        Text(t.nombre).tag(t)
                    }
                }
                .pickerStyle(.segmented)

                Section {
                    TextField("Nombre (ej. Sueldo, Arriendo, Netflix)", text: $nombre)
                    CampoMonto(titulo: "0", texto: $montoTexto)
                }

                Section {
                    Toggle("Tiene día de cobro/pago", isOn: $tieneDia)
                    if tieneDia {
                        Picker("Día del mes", selection: $dia) {
                            ForEach(1...31, id: \.self) { d in
                                Text("\(d)").tag(d)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Nuevo concepto")
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
        let item = ItemMensual(
            nombre: nombre.trimmingCharacters(in: .whitespaces),
            monto: montoDesde(montoTexto),
            tipo: tipo,
            diaDelMes: tieneDia ? dia : nil
        )
        store.agregar(item)
        dismiss()
    }
}
