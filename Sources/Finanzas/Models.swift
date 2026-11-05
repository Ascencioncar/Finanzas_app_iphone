import Foundation

// MARK: - Movimientos (ingresos / gastos)

/// Tipo de movimiento: dinero que entra o que sale.
enum TipoMovimiento: String, Codable, CaseIterable, Identifiable {
    case ingreso
    case gasto

    var id: String { rawValue }

    var nombre: String {
        switch self {
        case .ingreso: return "Ingreso"
        case .gasto: return "Gasto"
        }
    }

    var icono: String {
        switch self {
        case .ingreso: return "arrow.down.circle.fill"
        case .gasto: return "arrow.up.circle.fill"
        }
    }
}

/// Categorías disponibles para clasificar un movimiento.
enum Categoria: String, Codable, CaseIterable, Identifiable {
    case salario = "Salario"
    case comida = "Comida"
    case transporte = "Transporte"
    case servicios = "Servicios"
    case salud = "Salud"
    case ocio = "Ocio"
    case hogar = "Hogar"
    case educacion = "Educación"
    case otros = "Otros"

    var id: String { rawValue }
    var nombre: String { rawValue }

    var icono: String {
        switch self {
        case .salario: return "banknote"
        case .comida: return "fork.knife"
        case .transporte: return "car.fill"
        case .servicios: return "bolt.fill"
        case .salud: return "cross.case.fill"
        case .ocio: return "gamecontroller.fill"
        case .hogar: return "house.fill"
        case .educacion: return "book.fill"
        case .otros: return "ellipsis.circle.fill"
        }
    }
}

/// Un movimiento financiero: ingreso o gasto registrado por el usuario,
/// asociado opcionalmente a una cuenta bancaria.
struct Movimiento: Identifiable, Codable, Hashable {
    var id: UUID
    var tipo: TipoMovimiento
    var monto: Double
    var categoria: Categoria
    var nota: String
    var fecha: Date
    var cuentaID: UUID?

    init(
        id: UUID = UUID(),
        tipo: TipoMovimiento,
        monto: Double,
        categoria: Categoria,
        nota: String = "",
        fecha: Date = Date(),
        cuentaID: UUID? = nil
    ) {
        self.id = id
        self.tipo = tipo
        self.monto = monto
        self.categoria = categoria
        self.nota = nota
        self.fecha = fecha
        self.cuentaID = cuentaID
    }

    /// Monto con signo: negativo para gastos, positivo para ingresos.
    var montoConSigno: Double {
        tipo == .ingreso ? monto : -monto
    }
}

// MARK: - Cuentas bancarias

enum TipoCuenta: String, Codable, CaseIterable, Identifiable {
    case ahorros = "Ahorros"
    case corriente = "Corriente"
    case efectivo = "Efectivo"
    case otro = "Otro"

    var id: String { rawValue }
    var nombre: String { rawValue }

    var icono: String {
        switch self {
        case .ahorros: return "building.columns.fill"
        case .corriente: return "creditcard.fill"
        case .efectivo: return "banknote.fill"
        case .otro: return "wallet.pass.fill"
        }
    }
}

/// Una cuenta bancaria (o efectivo) del usuario.
struct CuentaBancaria: Identifiable, Codable, Hashable {
    var id: UUID
    var nombre: String
    var banco: String
    var tipo: TipoCuenta
    var saldoInicial: Double
    var colorHex: String

    init(
        id: UUID = UUID(),
        nombre: String,
        banco: String = "",
        tipo: TipoCuenta = .ahorros,
        saldoInicial: Double = 0,
        colorHex: String = Paleta.colores[0]
    ) {
        self.id = id
        self.nombre = nombre
        self.banco = banco
        self.tipo = tipo
        self.saldoInicial = saldoInicial
        self.colorHex = colorHex
    }
}

// MARK: - Transferencias entre cuentas

/// Movimiento de dinero de una cuenta a otra, con comprobante opcional
/// (nombre del archivo de imagen guardado en Documents).
struct Transferencia: Identifiable, Codable, Hashable {
    var id: UUID
    var cuentaOrigenID: UUID
    var cuentaDestinoID: UUID
    var monto: Double
    var nota: String
    var fecha: Date
    var comprobanteArchivo: String?

    init(
        id: UUID = UUID(),
        cuentaOrigenID: UUID,
        cuentaDestinoID: UUID,
        monto: Double,
        nota: String = "",
        fecha: Date = Date(),
        comprobanteArchivo: String? = nil
    ) {
        self.id = id
        self.cuentaOrigenID = cuentaOrigenID
        self.cuentaDestinoID = cuentaDestinoID
        self.monto = monto
        self.nota = nota
        self.fecha = fecha
        self.comprobanteArchivo = comprobanteArchivo
    }
}

// MARK: - Tarjetas de crédito

/// Una tarjeta de crédito con su deuda, cuota mínima e interés.
struct TarjetaCredito: Identifiable, Codable, Hashable {
    var id: UUID
    var nombre: String
    var banco: String
    var saldoTotal: Double        // deuda total actual
    var cuotaMinima: Double
    var tasaInteresMensual: Double // % mensual
    var cupoTotal: Double?         // cupo total asignado (opcional)
    var colorHex: String

    init(
        id: UUID = UUID(),
        nombre: String,
        banco: String = "",
        saldoTotal: Double = 0,
        cuotaMinima: Double = 0,
        tasaInteresMensual: Double = 0,
        cupoTotal: Double? = nil,
        colorHex: String = Paleta.colores[3]
    ) {
        self.id = id
        self.nombre = nombre
        self.banco = banco
        self.saldoTotal = saldoTotal
        self.cuotaMinima = cuotaMinima
        self.tasaInteresMensual = tasaInteresMensual
        self.cupoTotal = cupoTotal
        self.colorHex = colorHex
    }

    /// Interés mensual estimado sobre la deuda actual.
    var interesMensualEstimado: Double {
        saldoTotal * (tasaInteresMensual / 100)
    }

    /// Cupo disponible, si se definió un cupo total.
    var cupoDisponible: Double? {
        guard let cupoTotal else { return nil }
        return max(cupoTotal - saldoTotal, 0)
    }

    /// Porcentaje de uso del cupo (0...1), si hay cupo total.
    var usoCupo: Double? {
        guard let cupoTotal, cupoTotal > 0 else { return nil }
        return min(saldoTotal / cupoTotal, 1)
    }
}

// MARK: - Control mensual (ingresos y obligaciones)

enum TipoItemMensual: String, Codable, CaseIterable, Identifiable {
    case ingreso = "Ingreso"
    case obligacion = "Obligación"

    var id: String { rawValue }
    var nombre: String { rawValue }
}

/// Un concepto recurrente mensual: un ingreso fijo o una obligación (gasto fijo).
struct ItemMensual: Identifiable, Codable, Hashable {
    var id: UUID
    var nombre: String
    var monto: Double
    var tipo: TipoItemMensual
    var diaDelMes: Int?   // día de cobro/pago (1...31), opcional

    init(
        id: UUID = UUID(),
        nombre: String,
        monto: Double,
        tipo: TipoItemMensual,
        diaDelMes: Int? = nil
    ) {
        self.id = id
        self.nombre = nombre
        self.monto = monto
        self.tipo = tipo
        self.diaDelMes = diaDelMes
    }
}

// MARK: - Contenedor persistible

/// Instantánea completa del estado, lo que se guarda/carga como JSON.
struct EstadoFinanzas: Codable {
    var cuentas: [CuentaBancaria] = []
    var movimientos: [Movimiento] = []
    var transferencias: [Transferencia] = []
    var tarjetas: [TarjetaCredito] = []
    var itemsMensuales: [ItemMensual] = []
}
