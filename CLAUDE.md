# CLAUDE.md — Proyecto Finanzas (app iOS con xtool)

Instrucciones para Claude Code. Lee esto completo antes de tocar el proyecto.

## Objetivo del proyecto

App para **iPhone** llamada **Finanzas** que me permite llevar control de mis
**gastos e ingresos**. Es de uso personal (no va a la App Store). Interfaz en
**español**, moneda en **pesos colombianos (COP)**.

Funciones actuales:
- Registrar movimientos (ingreso/gasto) con monto, categoría, nota y fecha.
- Balance en vivo: total ingresos − total gastos.
- Lista de movimientos ordenada por fecha, con opción de eliminar.
- Persistencia local en el dispositivo.

## Entorno (MUY importante)

- Compilo desde **Windows 10 + WSL (Ubuntu)**. **NO tengo Mac ni Xcode.**
- La herramienta de compilación es **xtool** (https://xtool.sh), un reemplazo
  de Xcode que usa SwiftPM. Todo corre dentro de WSL.
- El iPhone se conecta por USB y se comparte hacia WSL con `usbipd-win`.

Por lo tanto: **nunca** sugieras abrir Xcode, crear un `.xcodeproj`, usar
`xcodebuild`, Simulator de Mac, CocoaPods ni nada exclusivo de macOS.

## Reglas de xtool (NO confundir con Xcode/XcodeGen)

| Usa esto                     | NO uses esto                          |
|------------------------------|---------------------------------------|
| `xtool.yml`                  | `project.yml`, `Project.swift`        |
| `Package.swift` (SwiftPM)    | archivos de proyecto de Xcode         |
| `.library` en los targets    | `.executable`                         |
| carpeta `Sources/`           | carpeta `Extensions/`                 |
| `xtool dev`                  | `xtool build`, `xtool run`            |

### Compatibilidad de Swift en xtool
- ✅ Macros estándar de Swift como `@Observable` **sí** funcionan.
- ❌ Macros específicas de Apple como `@Model` (SwiftData) **NO** están soportadas.
  No introduzcas SwiftData ni Core Data. Para persistir usa `Codable` +
  `UserDefaults` (como ya está implementado), o archivos JSON.
- App extensions (widgets, etc.) requieren producto + target en `Package.swift`
  y su propio `Info.plist`. No agregues ninguna salvo que yo lo pida.

## Estructura del proyecto

```
Finanzas/
├── CLAUDE.md                         # Este archivo
├── xtool.yml                         # Config de xtool (bundleID, product)
├── Package.swift                     # Paquete SwiftPM (iOS 17, product .library)
└── Sources/
    └── Finanzas/
        ├── FinanzasApp.swift         # @main, inyecta el store en el environment
        ├── Models.swift              # Movimiento, TipoMovimiento, Categoria
        ├── FinanzasStore.swift       # @Observable + persistencia + formatearMoneda()
        ├── ContentView.swift         # Pantalla principal (balance + lista)
        └── AgregarMovimientoView.swift  # Formulario de nuevo movimiento
```

El estado se comparte con un único `FinanzasStore` (`@Observable`) inyectado con
`.environment(store)` y leído con `@Environment(FinanzasStore.self)`.

## Comandos

```bash
# Configuración (una vez)
xtool setup            # Configura SDK (pide ruta al Xcode.xip) + autenticación
xtool auth status      # Verifica sesión con Apple ID

# Ciclo de desarrollo
xtool devices          # Lista iPhones conectados
xtool dev              # Compila, firma e instala en el iPhone (build + run)
xtool dev build        # Solo compila
xtool dev build --ipa  # Genera el .ipa
xtool dev run -s       # Corre en el simulador (solo disponible en macOS)
```

La primera compilación es lenta porque construye los módulos del SDK: es normal, espera.

## Convenciones de código

- Todo el texto visible al usuario, en **español**.
- Montos formateados con `formatearMoneda(_:)` (COP, sin decimales). No hardcodear
  el símbolo `$` en otros lugares; si cambia la moneda, se cambia en un solo sitio.
- SwiftUI nativo, nada de dependencias externas salvo que yo lo apruebe.
- Objetivo mínimo: iOS 17 (lo exige `@Observable`). No subas ni bajes esta versión
  sin avisarme.
- Nombres de tipos y propiedades en español, consistentes con los archivos actuales.

## Errores comunes a evitar

- Usar `xtool build` → es `xtool dev build`.
- Crear `project.yml` o un `.xcodeproj` → este proyecto es solo `xtool.yml` + `Package.swift`.
- Meter código en `Extensions/` → va en `Sources/`.
- Olvidar que cada producto necesita su target en `Package.swift`.
- Proponer SwiftData/`@Model` → no compila en xtool.

## Recordatorios del dispositivo

- Primera instalación: en el iPhone, **Ajustes > General > VPN y Gestión de
  dispositivos** → confiar en mi certificado de desarrollador.
- Con Apple ID gratuito la app caduca a los ~7 días; se reinstala con `xtool dev`.
- Si el iPhone no aparece en `xtool devices`: revisar cable USB, `usbipd-win`
  compartiendo el dispositivo hacia WSL, y Modo Desarrollador activado en el iPhone.

## Cómo quiero trabajar contigo

- Antes de un cambio grande, explícame en una o dos líneas qué vas a hacer.
- Después de editar, dime con qué comando lo pruebo.
- Si algo no es posible en xtool/WSL, dímelo claro en vez de asumir que tengo Mac.