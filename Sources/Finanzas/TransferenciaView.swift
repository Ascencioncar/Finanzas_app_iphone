import SwiftUI
import PhotosUI
import UIKit

/// Formulario para registrar una transferencia entre dos cuentas,
/// con la opción de adjuntar un pantallazo como comprobante.
struct TransferenciaView: View {
    @Environment(FinanzasStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var origenPreseleccionado: CuentaBancaria?

    @State private var origenID: UUID?
    @State private var destinoID: UUID?
    @State private var montoTexto = ""
    @State private var nota = ""
    @State private var fecha = Date()

    @State private var itemFoto: PhotosPickerItem?
    @State private var datosComprobante: Data?

    private var valido: Bool {
        guard let origenID, let destinoID else { return false }
        return origenID != destinoID && montoDesde(montoTexto) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Cuentas") {
                    Picker("Origen", selection: $origenID) {
                        Text("Selecciona").tag(UUID?.none)
                        ForEach(store.cuentas) { c in
                            Text(c.nombre).tag(Optional(c.id))
                        }
                    }
                    Picker("Destino", selection: $destinoID) {
                        Text("Selecciona").tag(UUID?.none)
                        ForEach(store.cuentas) { c in
                            Text(c.nombre).tag(Optional(c.id))
                        }
                    }
                }

                if origenID != nil, origenID == destinoID {
                    Text("El origen y el destino deben ser distintos.")
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Section("Monto") {
                    CampoMonto(titulo: "0", texto: $montoTexto)
                }

                Section("Comprobante (pantallazo)") {
                    if let datosComprobante, let imagen = imagenDesde(datosComprobante) {
                        imagen
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        Button(role: .destructive) {
                            self.datosComprobante = nil
                            itemFoto = nil
                        } label: {
                            Label("Quitar imagen", systemImage: "trash")
                        }
                    } else {
                        PhotosPicker(selection: $itemFoto, matching: .images) {
                            Label("Adjuntar pantallazo", systemImage: "photo")
                        }
                    }
                }

                Section("Detalles") {
                    TextField("Nota (opcional)", text: $nota, axis: .vertical)
                        .lineLimit(1...3)
                    DatePicker("Fecha", selection: $fecha, displayedComponents: .date)
                }
            }
            .navigationTitle("Transferencia")
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
                if origenID == nil { origenID = origenPreseleccionado?.id }
            }
            .onChange(of: itemFoto) { _, nuevo in
                Task {
                    if let datos = try? await nuevo?.loadTransferable(type: Data.self) {
                        datosComprobante = datos
                    }
                }
            }
        }
    }

    private func imagenDesde(_ datos: Data) -> Image? {
        guard let ui = UIImage(data: datos) else { return nil }
        return Image(uiImage: ui)
    }

    private func guardar() {
        guard let origenID, let destinoID else { return }
        var archivo: String?
        if let datosComprobante {
            archivo = store.guardarComprobante(datosComprobante)
        }
        let transferencia = Transferencia(
            cuentaOrigenID: origenID,
            cuentaDestinoID: destinoID,
            monto: montoDesde(montoTexto),
            nota: nota.trimmingCharacters(in: .whitespacesAndNewlines),
            fecha: fecha,
            comprobanteArchivo: archivo
        )
        store.agregar(transferencia)
        dismiss()
    }
}

/// Detalle de una transferencia, incluido el pantallazo si existe.
struct TransferenciaDetalleView: View {
    @Environment(FinanzasStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let transferencia: Transferencia

    var body: some View {
        List {
            Section {
                FilaValor(
                    titulo: "Monto",
                    valor: store.formatearMoneda(transferencia.monto)
                )
                HStack {
                    Text("Origen").foregroundStyle(.secondary)
                    Spacer()
                    Text(store.cuenta(transferencia.cuentaOrigenID)?.nombre ?? "—")
                }
                HStack {
                    Text("Destino").foregroundStyle(.secondary)
                    Spacer()
                    Text(store.cuenta(transferencia.cuentaDestinoID)?.nombre ?? "—")
                }
                HStack {
                    Text("Fecha").foregroundStyle(.secondary)
                    Spacer()
                    Text(transferencia.fecha, format: .dateTime.day().month().year())
                }
                if !transferencia.nota.isEmpty {
                    HStack {
                        Text("Nota").foregroundStyle(.secondary)
                        Spacer()
                        Text(transferencia.nota)
                    }
                }
            }

            if let datos = store.datosComprobante(transferencia.comprobanteArchivo),
               let ui = UIImage(data: datos) {
                Section("Comprobante") {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            Section {
                Button(role: .destructive) {
                    store.eliminarTransferencia(transferencia)
                    dismiss()
                } label: {
                    Label("Eliminar transferencia", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Transferencia")
        .navigationBarTitleDisplayMode(.inline)
    }
}
