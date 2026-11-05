import Foundation
import SwiftUI
import Observation

/// Estado central de la app: cuentas, movimientos, transferencias, tarjetas e
/// ítems mensuales. Persiste los datos como JSON en Documents y las imágenes
/// de comprobantes como archivos aparte. No usa SwiftData (no soportado en xtool).
@Observable
final class FinanzasStore {

    var cuentas: [CuentaBancaria] = [] { didSet { guardar() } }
    var movimientos: [Movimiento] = [] { didSet { guardar() } }
    var transferencias: [Transferencia] = [] { didSet { guardar() } }
    var tarjetas: [TarjetaCredito] = [] { didSet { guardar() } }
    var itemsMensuales: [ItemMensual] = [] { didSet { guardar() } }

    /// Evita guardar mientras se cargan los datos iniciales.
    @ObservationIgnored private var cargando = false

    // MARK: - Persistencia

    private var carpetaDatos: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var archivoDatos: URL {
        carpetaDatos.appendingPathComponent("finanzas.json")
    }

    init() {
        cargar()
    }

    private func cargar() {
        cargando = true
        defer { cargando = false }
        guard let datos = try? Data(contentsOf: archivoDatos) else { return }
        do {
            let estado = try JSONDecoder().decode(EstadoFinanzas.self, from: datos)
            cuentas = estado.cuentas
            movimientos = estado.movimientos
            transferencias = estado.transferencias
            tarjetas = estado.tarjetas
            itemsMensuales = estado.itemsMensuales
        } catch {
            print("No se pudo cargar el estado: \(error)")
        }
    }

    private func guardar() {
        guard !cargando else { return }
        let estado = EstadoFinanzas(
            cuentas: cuentas,
            movimientos: movimientos,
            transferencias: transferencias,
            tarjetas: tarjetas,
            itemsMensuales: itemsMensuales
        )
        do {
            let datos = try JSONEncoder().encode(estado)
            try datos.write(to: archivoDatos, options: .atomic)
        } catch {
            print("No se pudo guardar el estado: \(error)")
        }
    }

    // MARK: - Cuentas

    func agregarCuenta(_ cuenta: CuentaBancaria) { cuentas.append(cuenta) }

    func eliminarCuenta(_ cuenta: CuentaBancaria) {
        // Al borrar la cuenta, desvincula sus movimientos y borra sus transferencias.
        for i in movimientos.indices where movimientos[i].cuentaID == cuenta.id {
            movimientos[i].cuentaID = nil
        }
        let transfABorrar = transferencias.filter {
            $0.cuentaOrigenID == cuenta.id || $0.cuentaDestinoID == cuenta.id
        }
        transfABorrar.forEach { eliminarComprobante(de: $0) }
        transferencias.removeAll {
            $0.cuentaOrigenID == cuenta.id || $0.cuentaDestinoID == cuenta.id
        }
        cuentas.removeAll { $0.id == cuenta.id }
    }

    func cuenta(_ id: UUID?) -> CuentaBancaria? {
        guard let id else { return nil }
        return cuentas.first { $0.id == id }
    }

    /// Saldo actual de una cuenta: saldo inicial + ingresos − gastos
    /// + transferencias recibidas − transferencias enviadas.
    func saldo(de cuenta: CuentaBancaria) -> Double {
        var total = cuenta.saldoInicial
        for m in movimientos where m.cuentaID == cuenta.id {
            total += m.montoConSigno
        }
        for t in transferencias {
            if t.cuentaDestinoID == cuenta.id { total += t.monto }
            if t.cuentaOrigenID == cuenta.id { total -= t.monto }
        }
        return total
    }

    // MARK: - Movimientos

    func agregar(_ movimiento: Movimiento) { movimientos.append(movimiento) }

    func eliminarMovimiento(_ movimiento: Movimiento) {
        movimientos.removeAll { $0.id == movimiento.id }
    }

    func eliminarMovimientos(en offsets: IndexSet, de lista: [Movimiento]) {
        let ids = offsets.map { lista[$0].id }
        movimientos.removeAll { ids.contains($0.id) }
    }

    var movimientosOrdenados: [Movimiento] {
        movimientos.sorted { $0.fecha > $1.fecha }
    }

    func movimientos(de cuenta: CuentaBancaria) -> [Movimiento] {
        movimientos
            .filter { $0.cuentaID == cuenta.id }
            .sorted { $0.fecha > $1.fecha }
    }

    // MARK: - Transferencias

    func agregar(_ transferencia: Transferencia) { transferencias.append(transferencia) }

    func eliminarTransferencia(_ transferencia: Transferencia) {
        eliminarComprobante(de: transferencia)
        transferencias.removeAll { $0.id == transferencia.id }
    }

    var transferenciasOrdenadas: [Transferencia] {
        transferencias.sorted { $0.fecha > $1.fecha }
    }

    func transferencias(de cuenta: CuentaBancaria) -> [Transferencia] {
        transferencias
            .filter { $0.cuentaOrigenID == cuenta.id || $0.cuentaDestinoID == cuenta.id }
            .sorted { $0.fecha > $1.fecha }
    }

    // MARK: - Comprobantes (imágenes)

    /// Guarda la imagen del comprobante en Documents y devuelve el nombre del archivo.
    func guardarComprobante(_ datos: Data) -> String? {
        let nombre = "comprobante-\(UUID().uuidString).jpg"
        let url = carpetaDatos.appendingPathComponent(nombre)
        do {
            try datos.write(to: url, options: .atomic)
            return nombre
        } catch {
            print("No se pudo guardar el comprobante: \(error)")
            return nil
        }
    }

    func datosComprobante(_ nombre: String?) -> Data? {
        guard let nombre else { return nil }
        let url = carpetaDatos.appendingPathComponent(nombre)
        return try? Data(contentsOf: url)
    }

    private func eliminarComprobante(de transferencia: Transferencia) {
        guard let nombre = transferencia.comprobanteArchivo else { return }
        let url = carpetaDatos.appendingPathComponent(nombre)
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Tarjetas de crédito

    func agregar(_ tarjeta: TarjetaCredito) { tarjetas.append(tarjeta) }

    func actualizar(_ tarjeta: TarjetaCredito) {
        guard let i = tarjetas.firstIndex(where: { $0.id == tarjeta.id }) else { return }
        tarjetas[i] = tarjeta
    }

    func eliminarTarjeta(_ tarjeta: TarjetaCredito) {
        tarjetas.removeAll { $0.id == tarjeta.id }
    }

    var deudaTotalTarjetas: Double { tarjetas.reduce(0) { $0 + $1.saldoTotal } }
    var cuotaMinimaTotalTarjetas: Double { tarjetas.reduce(0) { $0 + $1.cuotaMinima } }
    var interesMensualTotalTarjetas: Double {
        tarjetas.reduce(0) { $0 + $1.interesMensualEstimado }
    }

    // MARK: - Ítems mensuales

    func agregar(_ item: ItemMensual) { itemsMensuales.append(item) }

    func eliminarItemMensual(_ item: ItemMensual) {
        itemsMensuales.removeAll { $0.id == item.id }
    }

    func itemsMensuales(_ tipo: TipoItemMensual) -> [ItemMensual] {
        itemsMensuales
            .filter { $0.tipo == tipo }
            .sorted { ($0.diaDelMes ?? 99) < ($1.diaDelMes ?? 99) }
    }

    var totalIngresosMensuales: Double {
        itemsMensuales.filter { $0.tipo == .ingreso }.reduce(0) { $0 + $1.monto }
    }

    var totalObligacionesMensuales: Double {
        itemsMensuales.filter { $0.tipo == .obligacion }.reduce(0) { $0 + $1.monto }
    }

    /// Lo que queda al mes tras cubrir las obligaciones fijas.
    var disponibleMensual: Double {
        totalIngresosMensuales - totalObligacionesMensuales
    }

    // MARK: - Datos derivados globales

    var totalIngresos: Double {
        movimientos.filter { $0.tipo == .ingreso }.reduce(0) { $0 + $1.monto }
    }

    var totalGastos: Double {
        movimientos.filter { $0.tipo == .gasto }.reduce(0) { $0 + $1.monto }
    }

    /// Balance total: suma de saldos de todas las cuentas
    /// más los movimientos sin cuenta asignada.
    var balanceTotal: Double {
        let deCuentas = cuentas.reduce(0) { $0 + saldo(de: $1) }
        let sinCuenta = movimientos
            .filter { $0.cuentaID == nil }
            .reduce(0) { $0 + $1.montoConSigno }
        return deCuentas + sinCuenta
    }

    // MARK: - Formato de moneda

    private static let formateadorMoneda: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "COP"
        f.locale = Locale(identifier: "es_CO")
        f.maximumFractionDigits = 0
        return f
    }()

    /// Formatea un valor como pesos colombianos sin decimales.
    /// Único lugar donde se decide el formato de moneda de la app.
    func formatearMoneda(_ valor: Double) -> String {
        FinanzasStore.formateadorMoneda.string(from: NSNumber(value: valor))
            ?? "$\(Int(valor))"
    }
}
