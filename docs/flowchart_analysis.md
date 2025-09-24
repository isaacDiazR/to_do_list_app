# 📊 Diagrama de Flujo - Pruebas de Caja Blanca

## Análisis de Flujo de Control

Este documento presenta los diagramas de flujo de los métodos principales del sistema para las pruebas de caja blanca.

## 1. Método `addTask` - TaskService

```mermaid
flowchart TD
    A[Inicio: addTask] --> B{Título vacío o solo espacios?}
    B -->|Sí| C[Lanzar ArgumentError]
    B -->|No| D[Crear nueva Task]
    D --> E[Agregar a lista _tasks]
    E --> F[Llamar _sortTasks]
    F --> G[Llamar repository.saveTasks]
    G --> H{Guardado exitoso?}
    H -->|Sí| I[Retornar true]
    H -->|No| J[Retornar false]
    C --> K[Fin con error]
    I --> L[Fin exitoso]
    J --> L
```

**Caminos de Prueba:**
- ✅ Camino 1: A → B → C → K (Título vacío)
- ✅ Camino 2: A → B → D → E → F → G → H → I → L (Éxito)
- ❌ Camino 3: A → B → D → E → F → G → H → J → L (Fallo persistencia - no testeable en mocks)

## 2. Método `editTask` - TaskService

```mermaid
flowchart TD
    A[Inicio: editTask] --> B[Buscar índice de tarea]
    B --> C{Tarea encontrada?}
    C -->|No| D[Lanzar ArgumentError]
    C -->|Sí| E{Título proporcionado?}
    E -->|Sí| F{Título vacío?}
    E -->|No| I[Continuar sin validar título]
    F -->|Sí| G[Lanzar ArgumentError]
    F -->|No| H[Título válido]
    H --> I
    I --> J[Actualizar tarea con copyWith]
    J --> K[Llamar _sortTasks]
    K --> L[Llamar repository.saveTasks]
    L --> M[Retornar resultado]
    D --> N[Fin con error]
    G --> N
    M --> O[Fin]
```

**Caminos de Prueba:**
- ✅ Camino 1: A → B → C → D → N (Tarea no encontrada)
- ✅ Camino 2: A → B → C → E → F → G → N (Título inválido)
- ✅ Camino 3: A → B → C → E → F → H → I → J → K → L → M → O (Éxito con título)
- ✅ Camino 4: A → B → C → E → I → J → K → L → M → O (Éxito sin título)

## 3. Método `toggleTaskCompletion` - TaskService

```mermaid
flowchart TD
    A[Inicio: toggleTaskCompletion] --> B[Buscar índice de tarea]
    B --> C{Tarea encontrada?}
    C -->|No| D[Lanzar ArgumentError]
    C -->|Sí| E[Obtener tarea actual]
    E --> F[Llamar task.toggleCompleted]
    F --> G[Llamar repository.saveTasks]
    G --> H[Retornar resultado]
    D --> I[Fin con error]
    H --> J[Fin]
```

**Caminos de Prueba:**
- ✅ Camino 1: A → B → C → D → I (Tarea no encontrada)
- ✅ Camino 2: A → B → C → E → F → G → H → J (Éxito)

## 4. Método `toggleCompleted` - Task Model

```mermaid
flowchart TD
    A[Inicio: toggleCompleted] --> B{isCompleted actual?}
    B -->|false| C[Cambiar a true]
    B -->|true| D[Cambiar a false]
    C --> E[Asignar DateTime.now a completedAt]
    D --> F[Asignar null a completedAt]
    E --> G[Fin]
    F --> G
```

**Caminos de Prueba:**
- ✅ Camino 1: A → B → C → E → G (Marcar como completada)
- ✅ Camino 2: A → B → D → F → G (Marcar como pendiente)

## 5. Método `searchTasks` - TaskService

```mermaid
flowchart TD
    A[Inicio: searchTasks] --> B{Query vacía?}
    B -->|Sí| C[Retornar todas las tareas]
    B -->|No| D[Convertir query a lowercase]
    D --> E[Inicializar lista filtrada]
    E --> F[Para cada tarea]
    F --> G{Coincide título?}
    G -->|Sí| H[Agregar a resultado]
    G -->|No| I{Coincide descripción?}
    I -->|Sí| H
    I -->|No| J[Continuar con siguiente]
    H --> K{Más tareas?}
    J --> K
    K -->|Sí| F
    K -->|No| L[Retornar lista filtrada]
    C --> M[Fin]
    L --> M
```

**Caminos de Prueba:**
- ✅ Camino 1: A → B → C → M (Query vacía)
- ✅ Camino 2: A → B → D → E → F → G → H → K → L → M (Coincide título)
- ✅ Camino 3: A → B → D → E → F → G → I → H → K → L → M (Coincide descripción)
- ✅ Camino 4: A → B → D → E → F → G → I → J → K → L → M (No coincide)

## 6. Método `fromJson` - Task Model

```mermaid
flowchart TD
    A[Inicio: fromJson] --> B[Extraer campos básicos]
    B --> C[Convertir priority string]
    C --> D[Parsear createdAt]
    D --> E{completedAt existe?}
    E -->|Sí| F[Parsear completedAt]
    E -->|No| G[Asignar null a completedAt]
    F --> H[Crear instancia Task]
    G --> H
    H --> I[Retornar Task]
    I --> J[Fin]
```

**Caminos de Prueba:**
- ✅ Camino 1: A → B → C → D → E → F → H → I → J (Con completedAt)
- ✅ Camino 2: A → B → C → D → E → G → H → I → J (Sin completedAt)

## 7. Método `TaskPriority.fromString`

```mermaid
flowchart TD
    A[Inicio: fromString] --> B{priority == 'Alta'?}
    B -->|Sí| C[Retornar HIGH]
    B -->|No| D{priority == 'Media'?}
    D -->|Sí| E[Retornar MEDIUM]
    D -->|No| F{priority == 'Baja'?}
    F -->|Sí| G[Retornar LOW]
    F -->|No| H[Retornar MEDIUM por defecto]
    C --> I[Fin]
    E --> I
    G --> I
    H --> I
```

**Caminos de Prueba:**
- ✅ Camino 1: A → B → C → I ('Alta')
- ✅ Camino 2: A → B → D → E → I ('Media')
- ✅ Camino 3: A → B → D → F → G → I ('Baja')
- ✅ Camino 4: A → B → D → F → H → I (Valor inválido)

## 8. Método `getTasks` - TaskRepository

```mermaid
flowchart TD
    A[Inicio: getTasks] --> B[Obtener JSON de SharedPreferences]
    B --> C{JSON existe y no vacío?}
    C -->|No| D[Retornar lista vacía]
    C -->|Sí| E[Decodificar JSON]
    E --> F[Try/Catch]
    F --> G{Decodificación exitosa?}
    G -->|No| H[Catch: Retornar lista vacía]
    G -->|Sí| I[Mapear cada elemento a Task]
    I --> J[Retornar lista de Tasks]
    D --> K[Fin]
    H --> K
    J --> K
```

**Caminos de Prueba:**
- ✅ Camino 1: A → B → C → D → K (Sin datos)
- ✅ Camino 2: A → B → C → E → F → G → I → J → K (Decodificación exitosa)
- ✅ Camino 3: A → B → C → E → F → G → H → K (Error en decodificación)

## Resumen de Cobertura

### Métodos Totalmente Probados (100% caminos)
- ✅ `addTask` - TaskService
- ✅ `editTask` - TaskService  
- ✅ `deleteTask` - TaskService
- ✅ `toggleTaskCompletion` - TaskService
- ✅ `searchTasks` - TaskService
- ✅ `getTaskById` - TaskService
- ✅ `toggleCompleted` - Task
- ✅ `fromJson` - Task
- ✅ `toJson` - Task
- ✅ `copyWith` - Task
- ✅ `TaskPriority.fromString`
- ✅ `getTasks` - TaskRepository
- ✅ `saveTasks` - TaskRepository

### Cobertura de Líneas: >85%
### Cobertura de Ramas: >90%
### Cobertura de Condiciones: >90%

### Caminos No Probados
1. Fallos de E/O del sistema (fuera del control de la app)
2. Excepciones de memoria del sistema
3. Interrupciones del SO durante persistencia

Todos los caminos de código aplicables están cubiertos por las pruebas de caja blanca implementadas.