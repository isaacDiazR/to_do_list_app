# 📝 Lista de Tareas - Aplicación Flutter

Una aplicación completa de gestión de tareas desarrollada en Flutter con un sistema de testing exhaustivo que incluye pruebas de Caja Negra, Caja Blanca y Caja Gris.

## 🚀 Tecnologías Utilizadas

- **Lenguaje**: Dart 3.9.2+
- **Framework**: Flutter 3.x+
- **Persistencia**: SharedPreferences 2.2.2
- **Generación de IDs**: UUID 4.3.3
- **Testing**: flutter_test, mockito 5.4.4

## ✨ Funcionalidades

### Funcionalidades Principales
1. **Agregar Tareas**
   - Título obligatorio (3-100 caracteres)
   - Descripción opcional (hasta 500 caracteres)
   - Prioridad seleccionable (Alta, Media, Baja)
   - Validación en tiempo real

2. **Listar y Filtrar Tareas**
   - Visualización de todas las tareas
   - Filtrado por prioridad
   - Filtrado por estado (completadas/pendientes)
   - Búsqueda por texto en título y descripción
   - Ordenamiento automático por prioridad

3. **Editar Tareas**
   - Modificación de título, descripción y prioridad
   - Validaciones consistentes
   - Actualización en tiempo real

4. **Eliminar Tareas**
   - Confirmación antes de eliminar
   - Eliminación individual
   - Limpieza masiva disponible

5. **Marcar Estado**
   - Alternar entre completada/pendiente
   - Timestamps automáticos
   - Indicadores visuales de estado

### Características Adicionales
- 📊 **Estadísticas**: Contadores de tareas totales, completadas y pendientes
- 🎨 **UI Responsiva**: Interfaz adaptativa con Material Design
- 💾 **Persistencia**: Almacenamiento local automático
- 🔍 **Búsqueda**: Búsqueda en tiempo real
- ⚡ **Rendimiento**: Optimizado para manejar miles de tareas

## 📦 Instalación

### Prerrequisitos
- Flutter SDK 3.9.2 o superior
- Dart SDK incluido con Flutter
- Android Studio / VS Code (recomendado)
- Git

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <url-del-repositorio>
   cd to_do_list_app
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Verificar instalación**
   ```bash
   flutter doctor
   ```

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 🏃‍♂️ Ejecución

### Ejecutar la Aplicación
```bash
# Modo debug (desarrollo)
flutter run

# Modo release (optimizado)
flutter run --release

# Para web
flutter run -d chrome

# Para dispositivo específico
flutter devices  # Listar dispositivos disponibles
flutter run -d <device_id>
```

### Generar APK (Android)
```bash
flutter build apk --release
```

### Generar App Bundle (Android - Para Play Store)
```bash
flutter build appbundle --release
```

## 🧪 Testing

La aplicación incluye un sistema de testing exhaustivo con **más de 60 casos de prueba** distribuidos en tres enfoques:

### Ejecutar Todas las Pruebas
```bash
flutter test
```

### Pruebas de Caja Negra (24 casos)
Verifican la funcionalidad sin conocer la implementación interna.

```bash
flutter test test/black_box_tests.dart
```

**Particiones de Equivalencia y Valores Límite:**
- ✅ Títulos válidos (3-100 caracteres)
- ✅ Títulos inválidos (vacíos, solo espacios)
- ✅ Descripciones opcionales
- ✅ Prioridades (Alta, Media, Baja)
- ✅ Estados (completada/pendiente)
- ✅ Operaciones CRUD completas

### Pruebas de Caja Blanca (27 casos)
Verifican la cobertura de código y caminos de ejecución.

```bash
flutter test test/white_box_tests.dart
```

**Cobertura Incluida:**
- 🎯 **>85% de cobertura de líneas**
- 🎯 Todos los métodos públicos testados
- 🎯 Manejo de errores y excepciones
- 🎯 Validaciones de entrada
- 🎯 Transformaciones de datos
- 🎯 Persistencia y recuperación

### Pruebas de Caja Gris (13 casos)
Combinan conocimiento interno con pruebas funcionales.

```bash
flutter test test/gray_box_tests.dart
```

**Incluye:**
- 🔗 **Pruebas de Integración**: TaskService ↔ TaskRepository
- 🧠 **Validación de Estados Internos**: Contadores, memoria, consistencia
- ⚡ **Pruebas de Rendimiento**: 
  - Agregar 1000 tareas: ~30ms
  - Búsqueda en 1000 tareas: ~1ms
  - Filtrado en 2000 tareas: ~0ms
  - Limpieza de 1000 tareas: ~0ms

### Pruebas de Widget (2 casos)
```bash
flutter test test/widget_test.dart
```

## 📊 Resultados de Pruebas

### Resumen de Ejecución

| Tipo de Prueba | Casos | Resultado | Cobertura |
|----------------|-------|-----------|-----------|
| **Caja Negra** | 24 | ✅ PASS | Funcionalidad completa |
| **Caja Blanca** | 27 | ✅ PASS | >85% líneas de código |
| **Caja Gris** | 13 | ✅ PASS | Integración y rendimiento |
| **Widget Tests** | 2 | ✅ PASS | UI básica |
| **TOTAL** | **66** | ✅ **ALL PASS** | **Cobertura Completa** |

### Métricas de Rendimiento
- ⚡ **Carga inicial**: <100ms
- ⚡ **Agregar 1000 tareas**: ~30ms
- ⚡ **Búsqueda masiva**: ~1ms
- ⚡ **Persistencia**: <20ms
- 💾 **Memoria**: Optimizada para >1000 tareas

### Caminos de Código Probados
- ✅ Flujo principal de todas las funcionalidades
- ✅ Manejo de errores y casos edge
- ✅ Validaciones de entrada
- ✅ Operaciones de persistencia
- ✅ Estados internos y contadores
- ✅ Ordenamiento y filtrado

### Caminos No Probados
- ❌ Fallos de conectividad de red (no aplica - app offline)
- ❌ Permisos de sistema (no requeridos)
- ❌ Interrupciones del sistema operativo

## 🎯 Cobertura de Testing

### Particiones de Equivalencia
1. **Título de Tarea**:
   - Válido: 3-100 caracteres ✅
   - Inválido: vacío, solo espacios ✅
   - Límites: exactamente 3 y 100 caracteres ✅

2. **Descripción**:
   - Válida: hasta 500 caracteres ✅
   - Inválida: más de 500 caracteres ✅
   - Opcional: null o vacía ✅

3. **Prioridad**:
   - Alta, Media, Baja ✅
   - Valor por defecto ✅

4. **Estado**:
   - Completada/Pendiente ✅
   - Transiciones de estado ✅

### Valores Límite
- Título: 2, 3, 100, 101 caracteres
- Descripción: 499, 500, 501 caracteres
- Rendimiento: 1, 1000, 2000 tareas

## 🏗️ Arquitectura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada
├── models/
│   └── task.dart            # Modelo de datos Task
├── repositories/
│   └── task_repository.dart  # Capa de persistencia
├── services/
│   └── task_service.dart    # Lógica de negocio
└── screens/
    ├── task_list_screen.dart    # Pantalla principal
    └── add_edit_task_screen.dart # Pantalla de agregar/editar

test/
├── black_box_tests.dart     # Pruebas funcionales
├── white_box_tests.dart     # Pruebas estructurales
├── gray_box_tests.dart      # Pruebas de integración
└── widget_test.dart         # Pruebas de UI
```

### Patrones de Diseño Utilizados
- **Repository Pattern**: Separación de persistencia
- **Service Layer**: Lógica de negocio centralizada
- **Model-View-Controller**: Estructura clara de responsabilidades
- **Dependency Injection**: Testabilidad mejorada

## 📱 Capturas de Pantalla

### Pantalla Principal
- Lista de tareas con indicadores de prioridad
- Filtros por prioridad y estado
- Búsqueda en tiempo real
- Estadísticas de tareas

### Pantalla de Agregar/Editar
- Formulario con validaciones
- Selector de prioridad visual
- Campos opcionales y obligatorios

## 🔧 Configuración de Desarrollo

### Análisis de Código
El proyecto incluye `analysis_options.yaml` con reglas estrictas de linting.

### Dependencias de Desarrollo
```yaml
dev_dependencies:
  flutter_test: sdk
  flutter_lints: ^5.0.0
  mockito: ^5.4.4
  build_runner: ^2.4.9
```

## 🚧 Funcionalidades Futuras

- [ ] Sincronización en la nube
- [ ] Recordatorios y notificaciones
- [ ] Categorías personalizadas
- [ ] Temas oscuro/claro
- [ ] Exportar/Importar datos
- [ ] Colaboración multiusuario

## 📄 Licencia

Este proyecto está desarrollado con fines educativos y de demostración.

## 👨‍💻 Autor

Desarrollado como parte de un proyecto de testing exhaustivo en Flutter.

---

**Total de Líneas de Código**: ~1,500+  
**Total de Casos de Prueba**: 66  
**Cobertura de Testing**: >85%  
**Estado del Proyecto**: ✅ Completado y Totalmente Probado
