# Habit Manager 🚀

Una aplicación nativa para iOS, simple, robusta y moderna, para construir, mantener y hacer seguimiento de tus hábitos diarios y semanales. Desarrollada 100% con las últimas tecnologías del ecosistema Apple, bajo los principios de **Clean Architecture**, el patrón **MVVM**, y enriquecida con un completo sistema de **Gamificación** y preparación para **Sincronización CloudKit**.

---

## 🏛️ Arquitectura del Proyecto (Clean Architecture + MVVM)

El proyecto está diseñado bajo una arquitectura limpia por capas desacopladas, garantizando mantenibilidad, testabilidad completa (100% de la lógica de negocio y presentación) e independencia de frameworks:

```
                              ┌──────────────────────────────────┐
                              │        Presentation Layer        │
                              │  SwiftUI Views & MVVM ViewModels │
                              │ (Today, Habits, Badges, Stats)   │
                              └─────────────────┬────────────────┘
                                                │ (usa)
                                                ▼
                              ┌──────────────────────────────────┐
                              │           Domain Layer           │
                              │    Entities, Use Cases & Ports   │
                              │     (Pure Swift - 0 DB - 0 UI)   │
                              └─────────────────▲────────────────┘
                                                │ (implementa)
                                                │
                              ┌─────────────────┴────────────────┐
                              │            Data Layer            │
                              │  SwiftData Repos, CloudKit Sync, │
                              │   UserDefaults & Notifications   │
                              └──────────────────────────────────┘
```

### 1. Capa de Dominio (`Domain/`)
* **Independencia absoluta:** Código Swift puro sin dependencias de SwiftUI, SwiftData ni ningún framework externo.
* **Entidades:** 
  * `HabitEntity`, `HabitLogEntity`, `Weekday`, `HabitFrequency`, `HabitType`, `HabitDomainError`.
  * `AchievementEntity`, `AchievementType`, `AchievementCategory`, `UserGamificationProfile`.
* **Protocolos (Puertos):** 
  * `HabitRepositoryProtocol`, `NotificationServiceProtocol`, `GamificationRepositoryProtocol`.
* **Casos de Uso:**
  * `GetHabitsUseCase`: Obtiene todos los hábitos.
  * `GetTodaysHabitsUseCase`: Filtra hábitos programados para la fecha actual.
  * `ToggleHabitCompletionUseCase`: Marca completitud o actualiza progresos cuantitativos.
  * `SaveHabitUseCase`: Valida datos, persiste y administra notificaciones.
  * `DeleteHabitUseCase`: Elimina el hábito y cancela sus notificaciones.
  * `CalculateHabitStatsUseCase`: Genera resúmenes estadísticos (rachas, 7 y 30 días).
  * `EvaluateAchievementsUseCase`: Evalúa reactivamente el catálogo de logros, calcula hitos y desbloquea insignias.
  * `GetGamificationProfileUseCase`: Construye el perfil de jugador (nivel, XP, progreso, insignias).
  * `AwardHabitCompletionXPUseCase`: Otorga experiencia dinámica al completar tareas (+10 XP simples, +15 XP cuantitativos).

### 2. Capa de Datos (`Data/`)
* **Mapeo Bidireccional (`HabitMapper`):** Transforma de forma segura modelos `@Model` de SwiftData (`Habit`, `HabitLog`) hacia/desde entidades de dominio puras (`HabitEntity`, `HabitLogEntity`).
* **Repositorios Concretos:**
  * `SwiftDataHabitRepository`: Implementa `HabitRepositoryProtocol` reteniendo el ciclo de vida de `ModelContainer` y garantizando relaciones inversas.
  * `UserDefaultsGamificationRepository`: Implementa `GamificationRepositoryProtocol` con almacenamiento rápido, atómico y thread-safe para logros y XP.
* **Servicio de Notificaciones (`AppNotificationService`):** Implementa `NotificationServiceProtocol` encapsulando `UNUserNotificationCenter`.

### 3. Capa de Presentación (`Presentation/`)
* **Contenedor de Inyección de Dependencias (`AppDependencyContainer`):**
  * Punto de composición central que inicializa repositorios, servicios, casos de uso y factorías de ViewModels.
* **ViewModels (`@Observable`):**
  * `TodayViewModel`: Gestiona hábitos del día, ejecución de toggles, steppers y banners reactivos de logro desbloqueado.
  * `HabitListViewModel`: Administra la lista completa y orquesta la eliminación en cascada.
  * `AddEditHabitViewModel`: Administra estado de formularios, validaciones y guardado.
  * `StatsViewModel`: Agrega métricas para gráficos y desgloses de rendimiento.
  * `GamificationViewModel`: Administra perfil de nivel, XP y catálogo filtrable de insignias.
* **Vistas de SwiftUI:**
  * `TodayView`: Vista principal con banner flotante de celebración al desbloquear logros.
  * `HabitListView`: Administración de hábitos.
  * `AchievementsView`: Nueva pantalla dedicada con tarjeta de nivel/XP, filtros por categoría, cuadrícula de medallas e inspección en modal.
  * `StatsView`: Gráficos con Swift Charts y Gauges de cumplimiento.

---

## 🏆 Sistema de Gamificación (Logros, XP y Niveles)

La aplicación integra una experiencia de gamificación diseñada para fomentar la constancia diaria:

### 1. Niveles de Usuario y Experiencia (XP)
* **Recompensas en XP:**
  * +10 XP por cada hábito simple completado.
  * +15 XP por hábito cuantitativo alcanzado.
  * +20 a +1000 XP por cada insignia/logro desbloqueado.
* **Escalafón de Niveles:**
  * **Nivel 1:** *Novato* (0 – 100 XP)
  * **Nivel 2:** *Aprendiz* (100 – 300 XP)
  * **Nivel 3:** *Constante* (300 – 650 XP)
  * **Nivel 4:** *Disciplinado* (650 – 1,200 XP)
  * **Nivel 5:** *Maestro del Hábito* (1,200 – 2,000 XP)
  * **Nivel 6:** *Gran Maestro* (2,000 – 3,200 XP)
  * **Nivel 7:** *Leyenda* (3,200+ XP)

### 2. Catálogo de 14 Insignias (Badges)
* **Primeros Pasos:** *Primer Paso* (crear hábito), *Punto de Partida* (completar primer hábito).
* **Rachas de Fuego:** *Chispa* (3 días), *Llama Viva* (7 días), *Hoguera* (14 días), *Hábito Forjado* (21 días), *Imparable* (30 días), *Hábito de Hierro* (100 días).
* **Constancia:** *Día Perfecto* (todos los hábitos completados, mín. 3), *Primeros Diez* (10 registros), *Medio Centenar* (50 registros), *Centurión* (100 registros).
* **Metas Numéricas:** *Meta Cumplida* (primera meta cuantitativa lograda), *Medición Implacable* (20 metas cuantitativas logradas).

---

## ☁️ Sincronización con CloudKit (iCloud)

El esquema de datos de la aplicación ha sido adaptado y preparado para sincronización automática en la nube con CloudKit:

* **Esquema SwiftData compatible con CloudKit:**
  * Se removieron restricciones únicas no soportadas por CloudKit (`@Attribute(.unique)`).
  * Todas las relaciones entre `Habit` y `HabitLog` son explícitamente inversas y opcionales (`logs: [HabitLog]?` y `habit: Habit?`).
  * Todas las propiedades cuentan con valores predeterminados para admitir migraciones fluidas en la nube.
* **Inicialización Resiliente:**
  * `ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)`: sincroniza automáticamente con el contenedor privado de iCloud cuando los entitlements están activos.
  * **Fallback Local Automático:** Si el dispositivo no tiene iCloud configurado o aún no se han asignado los certificados de desarrollador en Xcode, la app realiza un fallback transparente a `cloudKitDatabase: .none` garantizando 0 fallos de ejecución.

### Cómo activar CloudKit en Xcode (Pasos para el Desarrollador):
1. Abre el proyecto en Xcode.
2. Selecciona el target **Habit Manager** > pestaña **Signing & Capabilities**.
3. Haz clic en **+ Capability** y añade **iCloud**.
4. Marca la casilla **CloudKit** y crea/selecciona tu contenedor (ej. `iCloud.com.tudominio.HabitManager`).
5. Haz clic en **+ Capability** y añade **Background Modes**, marcando la opción **Remote notifications** (para sincronización silenciosa entre dispositivos).

---

## 📱 Widgets Interactivos y Live Activities (WidgetKit + AppIntents + ActivityKit)

La aplicación incluye soporte completo para **Widgets Interactivos en iOS 17+** y **Live Activities con Dynamic Island**:

### 1. Widgets Interactivos (WidgetKit + AppIntents)
* **Sincronización mediante App Groups:**
  * Almacenamiento compartido y thread-safe con `group.com.agusrusso.HabitManager` a través de `SharedHabitStore`.
  * La app principal sincroniza automáticamente los hábitos del día y rachas en cada apertura o cambio en `TodayViewModel`.
* **Interactividad con `AppIntent` (`ToggleHabitIntent`):**
  * Al presionar el botón de checkmark en el widget mediano, se dispara `ToggleHabitIntent`, actualizando el estado atómicamente y recargando el timeline con `WidgetCenter.shared.reloadAllTimelines()`.
* **Familias de Widgets Soportadas:**
  * **`.systemSmall`:** Anillo circular animado con porcentaje de cumplimiento del día, racha más alta 🔥 y contador de pendientes.
  * **`.systemMedium`:** Lista interactiva de los hábitos de hoy con botones directos para completarlos, tachado de texto y progreso para cuantitativos.
  * **Lock Screen (`.accessoryCircular`, `.accessoryRectangular`, `.accessoryInline`):** Información visible en pantalla de bloqueo y StandBy.

### 2. Live Activities y Dynamic Island (ActivityKit)
* **Sesiones de Enfoque en Tiempo Real:**
  * Desde la vista "Hoy", cada hábito cuenta con un botón de temporizador que despliega un modal (`FocusSessionSheet`) para iniciar sesiones de enfoque (5, 10, 15, 25 Pomodoro 🍅, 45 o 60 minutos).
* **Dynamic Island Integrado (`HabitActivityWidget`):**
  * **Compact Leading/Trailing:** Nombre del hábito, fuego 🔥 y cuenta regresiva en vivo (`timerInterval:countsDown:`).
  * **Minimal:** Ícono de racha animado.
  * **Expanded:** Vista expandida completa con racha, tiempo restante en dígitos monoespaciados, objetivo de minutos e indicador de concentración activa.
* **Lock Screen / Banner en Vivo:**
  * Tarjeta visual con tipografía grande, tiempo restante en vivo, racha y mensajes de aliento.
  * Opción de finalizar sesión y marcar el hábito automáticamente como completado otorgando experiencia (XP).

---

## 🛠️ Tecnologías Utilizadas

- **Lenguaje:** Swift 6 / iOS 17+ (Swift Concurrency: `async`/`await`, `Sendable`, `@MainActor`, `actor`).
- **Framework de Interfaz:** SwiftUI con macros `@Observable`.
- **Persistencia:** SwiftData (aislado en capa de datos) + compatibilidad CloudKit.
- **Widgets y Live Activities:** WidgetKit + AppIntents (interactividad) + ActivityKit (Dynamic Island y Lock Screen).
- **Gráficos:** Swift Charts.
- **Notificaciones:** UserNotifications (`UNUserNotificationCenter`).
- **Framework de Pruebas:** Swift Testing (`@Suite`, `@Test`, `#expect`) + XCTest.

---

## 🧪 Pruebas Unitarias, Integración y UI (47/47 Pasando)

El proyecto cuenta con cobertura exhaustiva de pruebas automáticas en todas las capas, validadas con el modo estricto de concurrencia de Swift 6 (`-strict-concurrency=complete`):

| Capa / Suite | Cantidad | Qué valida |
|---|:---:|---|
| **HabitEntityTests** | 7 | Cálculo de rachas, días incompletos, porcentajes de cumplimiento y frecuencias. |
| **UseCasesTests** | 8 | Lógica de negocio y casos de uso con mocks de repositorios y notificaciones. |
| **GamificationDomainTests** | 5 | Progresión de niveles de usuario, evaluación de hitos, rachas, día perfecto y XP. |
| **SwiftDataHabitRepositoryTests** | 5 | Integración con contenedor SwiftData en memoria (`isStoredInMemoryOnly: true`). |
| **TodayViewModelTests** | 5 | Filtrado del día, toggles de estado, progreso numérico, sincronización de widgets y sesiones de Live Activities. |
| **HabitActivityAttributesTests** | 1 | Codificación, serialización JSON y preservación de estado en Live Activities (`ContentState`). |
| **SharedHabitStoreTests** | 3 | Codificación, serialización atómica en App Group y alternancia interactiva de hábitos en widgets. |
| **HabitListViewModelTests** | 2 | Carga de lista y eliminación de hábitos. |
| **AddEditHabitViewModelTests** | 4 | Reglas de validación, creación, edición y eliminación de hábitos. |
| **GamificationViewModelTests** | 2 | Carga de perfil, conteo de insignias y filtrado reactivo por categoría. |
| **StatsViewModelTests** | 1 | Procesamiento de estadísticas y filtrado de rachas activas para gráficos. |
| **Habit_ManagerTests** | 1 | Integridad general del bundle de pruebas. |
| **Habit_ManagerUITests (XCUITest)** | 3 | **Flujo Crítico End-to-End**: creación de hábito desde "Todos", verificación de aparición en "Hoy", completitud interactiva, reflejo en "Logros" y rendimiento de lanzamiento. |

---

## 📁 Estructura del Código

```
Habit Manager/
├── Habit_ManagerApp.swift           # Composición raíz, configuración CloudKit y Tabs
├── Domain/                          # Lógica de Negocio Pura (0 DB, 0 UI)
│   ├── Model/                       # HabitEntity, AchievementEntity, UserGamificationProfile, Enums
│   ├── Repository/                  # HabitRepositoryProtocol, GamificationRepositoryProtocol
│   ├── Service/                     # NotificationServiceProtocol, FocusSessionServiceProtocol
│   └── UseCases/                    # Casos de uso de Hábitos y Gamificación
├── Data/                            # Persistencia y Servicios Concretos
│   ├── Mapping/                     # HabitMapper (SwiftData <-> Dominio)
│   ├── Repository/                  # SwiftDataHabitRepository, UserDefaultsGamificationRepository (actor)
│   └── Service/                     # AppNotificationService, ActivityKitFocusSessionService (actor)
├── Presentation/                    # MVVM y DI
│   ├── DI/                          # AppDependencyContainer (inyección de servicios y casos de uso)
│   └── ViewModels/                  # ViewModels (@Observable)
├── View/                            # Vistas SwiftUI
│   ├── TodayView.swift              # Pantalla principal "Hoy" con banner de celebración y botón de enfoque
│   ├── FocusSessionSheet.swift      # Modal de configuración y control de Live Activities
│   ├── HabitListView.swift          # Pantalla de gestión "Mis Hábitos"
│   ├── AchievementsView.swift       # Pantalla de Nivel, Insignias y Detalle
│   ├── StatsView.swift              # Métricas y Swift Charts
│   └── DayOfWeekSelector.swift      # Selector de días de la semana
├── Model/                           # Esquemas SwiftData CloudKit-ready (@Model)
│   ├── Habit.swift
│   └── HabitLog.swift
├── HabitWidgetExtension/            # Target de Extensión para Widgets y Live Activities de iOS
│   ├── HabitWidgetBundle.swift      # Entry point @main del widget bundle
│   ├── HabitWidget.swift            # TimelineProvider y configuración del Widget interactivo
│   ├── HabitWidgetViews.swift       # Vistas SwiftUI (small, medium, accessory)
│   ├── HabitActivityWidget.swift    # Configuración de Live Activity (Dynamic Island & Lock Screen)
│   ├── HabitActivityAttributes.swift# Atributos estáticos y estado dinámico de ActivityKit
│   ├── ToggleHabitIntent.swift      # AppIntent para interacción directa
│   ├── SharedHabitStore.swift       # Acceso thread-safe vía App Groups
│   └── HabitWidgetSnapshot.swift    # Snapshot serializable de hábitos del día
└── Habit ManagerUITests/             # Pruebas de Interfaz de Usuario (XCUITest)
    └── Habit_ManagerUITests.swift   # Flujo crítico end-to-end de creación y completitud
```

---

## 🚧 Hoja de Ruta (Roadmap)

- [x] **MVP Inicial** (guardado en la rama `mvp`).
- [x] **Refactorización a Clean Architecture con MVVM**.
- [x] **Suite de pruebas unitarias e integración (44 tests)**.
- [x] **Gamificación Completa:** Niveles (1 al 7), sistema de XP, 14 insignias con detalle y alertas reactivas.
- [x] **Preparación CloudKit:** Modelos compatibles, relaciones inversas y contenedor vinculado.
- [x] **Pruebas de UI (XCUITest):** Automatización de flujos críticos end-to-end.
- [x] **Cero Warnings con Swift 6 Strict Concurrency** (`-strict-concurrency=complete`).
- [x] **Widgets Interactivos:** Widgets en pantalla de inicio y bloqueo con AppIntents para completar hábitos sin abrir la app.
- [x] **Live Activities y Dynamic Island:** Temporizador de sesión de enfoque con Dynamic Island (compact, minimal, expanded) y tarjeta en Lock Screen.

---

## ✍️ Autor

**Agustín Russo**
- GitHub: [@Agusrusso](https://github.com/Agusrusso)


