# Habit Manager 🚀

Una aplicación nativa para iOS, simple, robusta y moderna, para construir, mantener y hacer seguimiento de tus hábitos diarios y semanales. Desarrollada 100% con las últimas tecnologías del ecosistema Apple y bajo los principios de **Clean Architecture** junto al patrón **MVVM**.

---

## 🏛️ Arquitectura del Proyecto (Clean Architecture + MVVM)

El proyecto ha sido refactorizado desde una estructura simple directamente acoplada a SwiftData hacia una arquitectura limpia por capas desacopladas, garantizando mantenibilidad, testabilidad completa e independencia de frameworks.

```
                              ┌──────────────────────────────────┐
                              │        Presentation Layer        │
                              │  SwiftUI Views & MVVM ViewModels │
                              └─────────────────┬────────────────┘
                                                │ (usa)
                                                ▼
                              ┌──────────────────────────────────┐
                              │           Domain Layer           │
                              │    Entities, Use Cases & Ports   │
                              │        (Pure Swift - 0 DB)       │
                              └─────────────────▲────────────────┘
                                                │ (implementa)
                                                │
                              ┌─────────────────┴────────────────┐
                              │            Data Layer            │
                              │    SwiftData Repos, Mappers &    │
                              │      Notification Adapters       │
                              └──────────────────────────────────┘
```

### 1. Capa de Dominio (`Domain/`)
* **Independencia absoluta:** Código Swift puro sin dependencias de SwiftUI, SwiftData ni ningún framework externo.
* **Entidades:** `HabitEntity`, `HabitLogEntity`, `Weekday`, `HabitFrequency`, `HabitType` y `HabitDomainError`.
  * Toda la lógica de negocio (cálculo de rachas consecutivas `currentStreak`, verificación de días programados, porcentajes de cumplimiento) reside en las entidades de dominio.
* **Protocolos (Puertos):** `HabitRepositoryProtocol` y `NotificationServiceProtocol`.
* **Casos de Uso:**
  * `GetHabitsUseCase`: Obtiene todos los hábitos.
  * `GetTodaysHabitsUseCase`: Filtra únicamente los hábitos programados para la fecha actual (diarios o semanales correspondientes).
  * `ToggleHabitCompletionUseCase`: Marca hábitos simples como completados/incompletos o actualiza progresos cuantitativos.
  * `SaveHabitUseCase`: Valida datos del hábito, lo persiste y programa/cancela notificaciones automáticamente.
  * `DeleteHabitUseCase`: Elimina el hábito de la persistencia y cancela sus notificaciones asociadas.
  * `CalculateHabitStatsUseCase`: Genera resúmenes estadísticos (rachas, cumplimiento a 7 y 30 días).

### 2. Capa de Datos (`Data/`)
* **Mapeo Bidireccional (`HabitMapper`):** Transforma de forma segura modelos `@Model` de SwiftData (`Habit`, `HabitLog`) hacia/desde entidades de dominio puras (`HabitEntity`, `HabitLogEntity`).
* **Repositorio (`SwiftDataHabitRepository`):** Implementa `HabitRepositoryProtocol` controlando el `ModelContext` y reteniendo el ciclo de vida del `ModelContainer`.
* **Servicio de Notificaciones (`AppNotificationService`):** Implementa `NotificationServiceProtocol` encapsulando `UNUserNotificationCenter` para autorizaciones, programación y cancelación de alertas.

### 3. Capa de Presentación (`Presentation/`)
* **Contenedor de Inyección de Dependencias (`AppDependencyContainer`):**
  * Punto de composición central que inicializa repositorios, servicios, casos de uso y provee factorías para los ViewModels.
  * Inyectado en el entorno de SwiftUI de manera segura.
* **ViewModels (`@Observable`):**
  * `TodayViewModel`: Gestiona los hábitos del día, ejecución de toggles y steppers de progreso.
  * `HabitListViewModel`: Administra la lista completa y orquesta la eliminación en cascada.
  * `AddEditHabitViewModel`: Administra estado de formularios, validaciones reactivas y guardado.
  * `StatsViewModel`: Agrega métricas para gráficos y desgloses de rendimiento.
* **Vistas de SwiftUI:**
  * Totalmente desacopladas de SwiftData (`@Query` y `modelContext` eliminados). Consumen únicamente sus ViewModels y modelos de dominio.

---

## ✨ Características Principales

- **✅ Gestión Integral de Hábitos:** Creación, edición y eliminación fluida de hábitos.
- **📅 Frecuencia Flexible:**
  - Hábitos diarios.
  - Hábitos semanales con selección interactiva de días (L, M, X, J, V, S, D).
- **📊 Dos Tipos de Hábitos:**
  - **Simples:** Registro tipo checkbox (sí/no) para tareas cotidianas.
  - **Cuantitativos:** Metas numéricas con contador y unidad personalizada (ej. "8 vasos de agua", "30 minutos de lectura").
- **🔔 Recordatorios Locales:** Notificaciones automáticas basadas en la hora configurada por el usuario.
- **📈 Estadísticas y Métricas en Tiempo Real:**
  - Gráficos interactivos de rachas consecutivas activas mediante **Swift Charts**.
  - Indicadores visuales de porcentaje de cumplimiento para los últimos 7 y 30 días con **Gauge**.

---

## 🛠️ Tecnologías Utilizadas

- **Lenguaje:** Swift 6 / iOS 17+ (Swift Concurrency: `async`/`await`, `Sendable`, `@MainActor`).
- **Framework de Interfaz:** SwiftUI con macros `@Observable`.
- **Persistencia:** SwiftData (aislado en la capa de datos).
- **Gráficos:** Swift Charts.
- **Notificaciones:** UserNotifications (`UNUserNotificationCenter`).
- **Framework de Pruebas:** Swift Testing (`@Suite`, `@Test`, `#expect`) + XCTest.

---

## 🧪 Pruebas Unitarias e Integración (30/30 Pasando)

El proyecto cuenta con una cobertura de pruebas completa en todas las capas lógicas:

| Capa / Suite | Cantidad | Qué valida |
|---|:---:|---|
| **HabitEntityTests** | 7 | Cálculo de rachas, días incompletos, porcentajes de cumplimiento y frecuencias. |
| **UseCasesTests** | 8 | Lógica de negocio y casos de uso con mocks aislados de persistencia y notificaciones. |
| **SwiftDataHabitRepositoryTests** | 5 | Pruebas de integración con `ModelContainer` en memoria (`isStoredInMemoryOnly: true`). |
| **TodayViewModelTests** | 3 | Filtrado de hoy, toggles de estado y cambios de progreso cuantitativo en el ViewModel. |
| **HabitListViewModelTests** | 2 | Carga de lista y eliminación de hábitos a través del ViewModel. |
| **AddEditHabitViewModelTests** | 3 | Reglas de validación, creación y edición de hábitos. |
| **StatsViewModelTests** | 1 | Procesamiento de estadísticas y filtrado de rachas activas para gráficos. |
| **Smoke Tests** | 1 | Integridad general del bundle de pruebas. |

---

## 📁 Estructura del Código

```
Habit Manager/
├── Habit_ManagerApp.swift           # Composición raíz y arranque
├── Domain/                          # Lógica de Negocio (Pura)
│   ├── Model/                       # Entidades y Enums del Dominio
│   ├── Repository/                  # Protocolo HabitRepositoryProtocol
│   ├── Service/                     # Protocolo NotificationServiceProtocol
│   └── UseCases/                    # Casos de uso de la aplicación
├── Data/                            # Persistencia y Servicios Concretos
│   ├── Mapping/                     # HabitMapper (SwiftData <-> Dominio)
│   ├── Repository/                  # SwiftDataHabitRepository
│   └── Service/                     # AppNotificationService
├── Presentation/                    # MVVM y DI
│   ├── DI/                          # AppDependencyContainer
│   └── ViewModels/                  # ViewModels (@Observable)
├── View/                            # Vistas SwiftUI
│   ├── TodayView.swift              # Pantalla principal "Hoy"
│   ├── HabitListView.swift          # Pantalla de gestión "Mis Hábitos"
│   ├── AddEditHabitView.swift       # Formulario creación / edición
│   ├── StatsView.swift              # Métricas y Swift Charts
│   └── DayOfWeekSelector.swift      # Selector de días de la semana
└── Model/                           # Esquemas SwiftData (@Model)
    ├── Habit.swift
    └── HabitLog.swift
```

---

## 🚧 Hoja de Ruta (Roadmap)

- [x] **MVP Inicial** (guardado en la rama `mvp`).
- [x] **Refactorización a Clean Architecture con MVVM**.
- [x] **Suite de pruebas unitarias e integración (30 tests)**.
- [ ] **Gamificación:** Insignias (*badges*) y recompensas por hitos alcanzados.
- [ ] **Sincronización CloudKit:** Respaldo y sincronización entre dispositivos.
- [ ] **Widgets y Live Activities:** Acceso rápido para marcar hábitos desde la pantalla de inicio o bloqueo.
- [ ] **UI Tests:** Automatización de flujos end-to-end con XCUITest.

---

## ✍️ Autor

**Agustín Russo**
- GitHub: [@Agusrusso](https://github.com/Agusrusso)
