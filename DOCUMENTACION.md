# Documentacion del proyecto Bus Tracker Trujillo

Este documento explica para que sirve cada parte del proyecto, que hace y en que archivo esta implementada.

## 1. Objetivo general

`Bus Tracker Trujillo` es una aplicacion Flutter que simula el recorrido GPS de un bus urbano alrededor de la Avenida Espana, en Trujillo, Peru.

La app muestra:

- Un mapa interactivo.
- La ruta del bus dibujada como linea.
- El bus moviendose por coordenadas reales.
- Paraderos o puntos de control.
- Velocidad simulada.
- Distancia recorrida.
- Historial del trayecto.
- Controles para iniciar, detener, centrar el mapa y navegar entre paraderos.

La implementacion principal esta en:

- `lib/main.dart`
- `lib/screens/map_screen.dart`
- `lib/services/bus_simulator.dart`
- `lib/data/av_espana_route.dart`

## 2. Tecnologias y dependencias

Archivo: `pubspec.yaml`

### Flutter

Flutter es el framework usado para crear la interfaz de la aplicacion. Permite compilar la misma app para Android, iOS, web y escritorio.

Se implementa en todo el proyecto, especialmente en:

- `lib/main.dart`
- `lib/screens/map_screen.dart`
- `lib/widgets/bus_marker.dart`

### flutter_map

`flutter_map` permite mostrar mapas dentro de Flutter. En este proyecto se usa para renderizar OpenStreetMap o MapTiler.

Se implementa en:

- `lib/screens/map_screen.dart`

Componentes usados:

- `FlutterMap`: contenedor principal del mapa.
- `TileLayer`: capa de imagenes del mapa.
- `PolylineLayer`: capa para dibujar la ruta y el historial.
- `MarkerLayer`: capa para dibujar el bus y paraderos.
- `MapController`: controlador para mover o centrar el mapa.

### latlong2

`latlong2` se usa para representar coordenadas geograficas y calcular distancias o rumbos.

Se implementa en:

- `lib/models/route_node.dart`
- `lib/models/stop_node.dart`
- `lib/services/bus_simulator.dart`
- `lib/screens/map_screen.dart`

Clases usadas:

- `LatLng`: guarda latitud y longitud.
- `Distance`: calcula distancia entre coordenadas y direccion del movimiento.

## 3. Entrada principal de la app

Archivo: `lib/main.dart`

### Funcion `main`

Sirve para iniciar la aplicacion Flutter.

```dart
void main() {
  runApp(const BusTrackerApp());
}
```

Que hace:

- Llama a `runApp`.
- Carga el widget principal `BusTrackerApp`.

### Clase `BusTrackerApp`

Sirve como widget raiz de la aplicacion.

Que hace:

- Crea el estado de la app.
- Permite manejar el cambio entre modo claro y modo oscuro.

### Clase `_BusTrackerAppState`

Sirve para guardar el tema actual.

Variables importantes:

- `_themeMode`: guarda si la app esta en modo claro u oscuro.
- `_isDarkMode`: indica si actualmente esta activo el modo oscuro.

Metodos importantes:

- `_toggleTheme()`: cambia entre modo claro y modo oscuro.
- `_buildTheme()`: construye el tema visual de Flutter.

Donde se implementa:

- `lib/main.dart`

Donde se usa:

- Se pasa a `MapScreen` para que la pantalla del mapa pueda cambiar el tema.

## 4. Pantalla principal del mapa

Archivo: `lib/screens/map_screen.dart`

### Clase `MapScreen`

Es la pantalla principal de la app.

Sirve para:

- Mostrar el mapa.
- Mostrar la ruta.
- Mostrar el bus.
- Mostrar paraderos.
- Mostrar paneles de informacion.
- Controlar si el mapa sigue al bus.
- Cambiar tema claro/oscuro.

Recibe:

- `isDarkMode`: indica si la app esta en modo oscuro.
- `onToggleTheme`: funcion para cambiar el tema.

### Clase `_MapScreenState`

Maneja el estado de la pantalla.

Variables importantes:

- `_simulator`: instancia de `BusSimulator`. Es el motor que calcula la posicion del bus.
- `_mapController`: permite mover el mapa desde codigo.
- `_mapReady`: indica si el mapa ya termino de cargar.
- `_followBus`: indica si el mapa debe seguir al bus automaticamente.

### Widget `FlutterMap`

Sirve para mostrar el mapa.

Se implementa en:

- `lib/screens/map_screen.dart`

Capas del mapa:

- `TileLayer`: carga las imagenes del mapa.
- `PolylineLayer`: dibuja la ruta completa y el trayecto recorrido.
- `MarkerLayer`: dibuja paraderos y bus.
- `RichAttributionWidget`: muestra atribucion de OpenStreetMap o MapTiler.

### Metodo `_tileUrl`

Sirve para decidir que proveedor de mapa usar.

Si no hay clave de MapTiler:

```dart
https://tile.openstreetmap.org/{z}/{x}/{y}.png
```

Si hay clave de MapTiler:

```dart
https://api.maptiler.com/maps/$style/{z}/{x}/{y}.png?key=$_mapTilerKey
```

Donde se implementa:

- `lib/screens/map_screen.dart`

Como se configura MapTiler:

```bash
flutter run --dart-define=MAPTILER_KEY=TU_API_KEY
```

### Metodo `_buildStopMarkers`

Sirve para crear los marcadores visuales de los paraderos.

Que hace:

- Recorre la lista de paraderos.
- Crea un `Marker` por cada paradero.
- Destaca con color amarillo el paradero actual.
- Muestra un `Tooltip` con id y nombre del paradero.

Donde se implementa:

- `lib/screens/map_screen.dart`

### Metodo `_centerOnBus`

Sirve para mover el mapa hacia la posicion actual del bus.

Que hace:

- Verifica que el mapa ya este listo.
- Verifica que el seguimiento automatico este activo.
- Usa `_mapController.move` para centrar el mapa.

Donde se implementa:

- `lib/screens/map_screen.dart`

### Metodo `_enableFollowBus`

Sirve para activar nuevamente el seguimiento automatico del bus.

Donde se implementa:

- `lib/screens/map_screen.dart`

## 5. Barra superior

Archivo: `lib/screens/map_screen.dart`

### Clase `_TopBar`

Es el panel superior de la pantalla.

Sirve para mostrar:

- Nombre de la aplicacion.
- Estado del mapa: `Siguiendo unidad` o `Mapa libre`.
- Boton para centrar el bus.
- Boton para cambiar modo claro/oscuro.

Donde se implementa:

- `lib/screens/map_screen.dart`

## 6. Panel inferior

Archivo: `lib/screens/map_screen.dart`

### Clase `_BottomPanel`

Es el panel inferior que muestra informacion del viaje.

Sirve para mostrar:

- Estado del bus.
- Velocidad.
- Kilometros recorridos.
- Cantidad de puntos en historial.
- Paradero actual.
- Navegacion de paraderos.
- Boton iniciar/detener simulacion.

Donde se implementa:

- `lib/screens/map_screen.dart`

Widgets auxiliares:

- `_MetricTile`: muestra una metrica con icono, valor y etiqueta.
- `_StatusPill`: muestra si el bus esta activo o pausado.
- `_StopSummary`: muestra paradero actual y descripcion.
- `_NavigationStrip`: muestra anterior, actual y siguiente.

## 7. Marcador del bus

Archivo: `lib/widgets/bus_marker.dart`

### Clase `BusMarker`

Sirve para dibujar el bus en el mapa.

Que hace:

- Dibuja un circulo con color principal.
- Muestra un icono de bus.
- Rota el marcador segun el rumbo del bus.
- Muestra un punto verde si esta en marcha.
- Muestra un punto naranja si esta detenido.

Propiedades:

- `bearing`: direccion del bus en grados.
- `isRunning`: indica si la simulacion esta activa.

Donde se implementa:

- `lib/widgets/bus_marker.dart`

Donde se usa:

- `lib/screens/map_screen.dart`, dentro de `MarkerLayer`.

## 8. Motor de simulacion

Archivo: `lib/services/bus_simulator.dart`

### Clase `BusSimulator`

Es el motor principal de la app.

Sirve para:

- Guardar la ruta.
- Mover el bus.
- Calcular velocidad.
- Calcular distancia recorrida.
- Calcular rumbo.
- Guardar historial.
- Detectar paradero cercano.
- Notificar a la interfaz cuando cambia la posicion.

Extiende:

```dart
ChangeNotifier
```

Esto permite que la interfaz escuche cambios usando `AnimatedBuilder`.

### Constructor `BusSimulator()`

Que hace:

- Inserta todos los puntos de `avEspanaRoute` en una lista circular simple.
- Inserta todos los paraderos de `avEspanaStops` en una lista doble.
- Inserta los mismos paraderos en una lista circular doble.
- Define el punto inicial del bus.
- Define el siguiente punto de ruta.
- Guarda el primer punto del historial.

### Estructuras usadas dentro del simulador

```dart
final CircularSimpleList<RouteNode> routeLoop;
final DoubleLinkedList<StopNode> stopNavigation;
final CircularDoubleList<StopNode> stationLoop;
SimpleLinkedList<RouteNode> history;
```

Uso de cada una:

- `routeLoop`: guarda la ruta completa como ciclo infinito.
- `stopNavigation`: permite moverse entre paraderos anterior y siguiente.
- `stationLoop`: permite navegar paraderos en forma circular hacia ambos lados.
- `history`: guarda los puntos ya recorridos por el bus.

### Getters publicos

Sirven para que la pantalla pueda leer datos del simulador sin modificar directamente sus variables internas.

- `isRunning`: indica si el timer esta activo.
- `position`: posicion actual del bus.
- `speedKmh`: velocidad actual.
- `coveredKilometers`: distancia recorrida en kilometros.
- `bearing`: rumbo del bus.
- `historyCount`: cantidad de puntos del historial.
- `elapsed`: tiempo simulado transcurrido.
- `currentStop`: paradero actual.
- `currentStation`: estacion actual circular.
- `nextStop`: paradero siguiente.
- `previousStop`: paradero anterior.
- `nextStation`: siguiente estacion circular.
- `previousStation`: estacion anterior circular.
- `statusLabel`: texto de estado mostrado en el panel.
- `routePath`: ruta completa convertida a `List<LatLng>` para dibujarla.
- `traveledPath`: historial convertido a `List<LatLng>` para dibujarlo.
- `stops`: paraderos convertidos a lista normal para crear marcadores.

### Metodo `start`

Sirve para iniciar la simulacion.

Que hace:

- Crea un `Timer.periodic`.
- Cada 60 milisegundos llama a `_advance`.
- Notifica a la interfaz con `notifyListeners`.

### Metodo `stop`

Sirve para detener la simulacion.

Que hace:

- Cancela el timer.
- Pone la velocidad en cero.
- Notifica cambios.

### Metodo `toggle`

Sirve para alternar entre iniciar y detener.

Si esta corriendo:

- Llama a `stop()`.

Si esta detenido:

- Llama a `start()`.

### Metodo `reset`

Sirve para volver al inicio de la ruta.

Que hace:

- Detiene el bus.
- Reinicia ruta, paraderos, velocidad, distancia, tiempo e historial.

Actualmente esta implementado pero no tiene boton visible en la interfaz.

### Metodos de navegacion manual

Sirven para cambiar el paradero mostrado en el panel.

- `selectNextStop()`
- `selectPreviousStop()`
- `selectNextStation()`
- `selectPreviousStation()`

Donde se usan:

- `lib/screens/map_screen.dart`, en `_BottomPanel` y `_NavigationStrip`.

### Metodo `_advance`

Es el paso principal de la simulacion.

Que hace cada tick:

- Calcula cuanto tiempo paso desde el tick anterior.
- Aumenta el tiempo acumulado.
- Calcula una velocidad simulada.
- Calcula cuantos metros debe avanzar.
- Llama a `_move`.
- Guarda historial.
- Sincroniza el paradero cercano.
- Notifica a la interfaz.

### Metodo `_move`

Sirve para mover el bus sobre la ruta.

Que hace:

- Calcula la distancia del segmento actual.
- Avanza dentro del segmento segun los metros recorridos.
- Si llega al final del segmento, pasa al siguiente nodo.
- Como la ruta esta en lista circular, al terminar vuelve al inicio.
- Calcula la nueva posicion interpolada.
- Calcula el rumbo del bus.
- Suma metros al total recorrido.

### Metodo `_interpolate`

Sirve para obtener un punto intermedio entre dos coordenadas.

Ejemplo:

- Si `progress` es `0`, devuelve el punto inicial.
- Si `progress` es `1`, devuelve el punto final.
- Si `progress` es `0.5`, devuelve un punto a la mitad.

### Metodo `_normalizeBearing`

Sirve para convertir el rumbo a un valor entre `0` y `360`.

### Metodo `_appendHistory`

Sirve para guardar puntos recorridos.

Que hace:

- Agrega la posicion actual al historial.
- Evita guardar puntos demasiado cercanos.
- Limita el historial a 800 puntos.

Donde se usa:

- Para dibujar la linea celeste de recorrido en `PolylineLayer`.

### Metodo `_syncNearestNodes`

Sirve para detectar el paradero mas cercano al bus.

Que hace:

- Recorre la lista de paraderos.
- Calcula distancia entre bus y paradero.
- Si el paradero mas cercano esta a menos de 140 metros, lo marca como actual.
- Hace lo mismo con la lista circular doble de estaciones.

## 9. Datos de ruta y paraderos

Archivo: `lib/data/av_espana_route.dart`

### Constante `avEspanaRoute`

Es una lista de puntos `RouteNode`.

Sirve para definir el camino por donde se mueve el bus.

Cada punto contiene:

- `lat`: latitud.
- `lng`: longitud.
- `label`: texto opcional para identificar una zona.

Donde se usa:

- `lib/services/bus_simulator.dart`

### Constante `avEspanaStops`

Es una lista de paraderos `StopNode`.

Sirve para definir puntos importantes de la ruta.

Cada paradero contiene:

- `id`: codigo del paradero.
- `name`: nombre visible.
- `description`: descripcion mostrada en el panel.
- `lat`: latitud.
- `lng`: longitud.

Donde se usa:

- `lib/services/bus_simulator.dart`
- `lib/screens/map_screen.dart`

## 10. Modelos

### `RouteNode`

Archivo: `lib/models/route_node.dart`

Representa un punto geografico de la ruta.

Propiedades:

- `lat`: latitud.
- `lng`: longitud.
- `label`: etiqueta opcional.

Getter:

- `point`: convierte `lat` y `lng` a `LatLng`.

Metodo:

- `copyWith`: crea una copia cambiando solo algunos campos.
- `toString`: devuelve texto util para depuracion.

Se usa en:

- `lib/data/av_espana_route.dart`
- `lib/services/bus_simulator.dart`

### `StopNode`

Archivo: `lib/models/stop_node.dart`

Representa un paradero o punto de control.

Propiedades:

- `id`: identificador, por ejemplo `P01`.
- `name`: nombre del paradero.
- `description`: descripcion del paradero.
- `lat`: latitud.
- `lng`: longitud.

Getter:

- `point`: convierte `lat` y `lng` a `LatLng`.

Se usa en:

- `lib/data/av_espana_route.dart`
- `lib/services/bus_simulator.dart`
- `lib/screens/map_screen.dart`

## 11. Estructuras de datos

Las estructuras estan implementadas manualmente para demostrar listas enlazadas. No dependen de `List` de Dart para su funcionamiento interno.

### Explicacion simple de nodos

Una estructura enlazada funciona con nodos.

Un nodo es como una caja que guarda un valor y una referencia hacia otro nodo.

Ejemplo de nodo simple:

```txt
[ valor | siguiente ]
```

Ejemplo de tres nodos conectados:

```txt
10 -> 20 -> 30 -> null
```

Esto significa:

- El nodo `10` apunta al nodo `20`.
- El nodo `20` apunta al nodo `30`.
- El nodo `30` no apunta a nadie, por eso termina en `null`.

En este proyecto las estructuras no estan puestas al azar. Cada una representa una necesidad diferente de la simulacion del bus.

Resumen rapido:

| Estructura | Puede ir adelante | Puede ir atras | Vuelve al inicio | Uso en la app |
| --- | --- | --- | --- | --- |
| Lista simple | Si | No directo | No | Historial del recorrido |
| Lista doble | Si | Si | No | Paraderos anterior y siguiente |
| Lista circular simple | Si | No directo | Si | Ruta infinita del bus |
| Lista circular doble | Si | Si | Si | Estaciones/paraderos en ciclo |

### Lista simple enlazada

Archivo: `lib/structures/simple_list.dart`

Clases:

- `SimpleListNode<T>`
- `SimpleLinkedList<T>`

Sirve para guardar elementos en una sola direccion.

Representacion:

```txt
punto1 -> punto2 -> punto3 -> null
```

En este proyecto se usa para:

- Guardar el historial de posiciones recorridas por el bus.

Implementacion en la app:

- `BusSimulator.history`

Metodos principales:

- `insertar`: agrega al final.
- `insertarInicio`: agrega al inicio.
- `eliminar`: elimina el primer elemento que cumpla una condicion.
- `eliminarPrimero`: elimina el primer nodo.
- `buscar`: busca un valor.
- `buscarNodo`: busca un nodo completo.
- `recorrer`: visita todos los valores.
- `siguiente`: obtiene el valor siguiente.
- `anterior`: obtiene el valor anterior recorriendo desde el inicio.
- `toDartList`: convierte a lista normal para que Flutter pueda dibujar.

### Lista doble enlazada

Archivo: `lib/structures/double_list.dart`

Clases:

- `DoubleListNode<T>`
- `DoubleLinkedList<T>`

Sirve para navegar hacia adelante y hacia atras.

Representacion:

```txt
null <- P01 <-> P02 <-> P03 -> null
```

Cada nodo tiene dos referencias:

- `previous`: nodo anterior.
- `next`: nodo siguiente.

En este proyecto se usa para:

- Navegar paraderos anteriores y siguientes.

Implementacion en la app:

- `BusSimulator.stopNavigation`

Metodos principales:

- `insertar`: agrega al final.
- `eliminar`: elimina un nodo y reconecta anterior/siguiente.
- `buscar`: busca un valor.
- `buscarNodo`: busca un nodo.
- `recorrer`: recorre de inicio a fin.
- `siguiente`: obtiene valor siguiente.
- `anterior`: obtiene valor anterior.
- `siguienteNodo`: obtiene nodo siguiente.
- `anteriorNodo`: obtiene nodo anterior.
- `toDartList`: convierte a lista normal.

### Lista circular simple

Archivo: `lib/structures/circular_simple_list.dart`

Clases:

- `CircularSimpleNode<T>`
- `CircularSimpleList<T>`

Sirve para que el ultimo nodo apunte otra vez al primero.

Representacion:

```txt
punto1 -> punto2 -> punto3
   ^                 |
   |_________________|
```

En este proyecto se usa para:

- Guardar la ruta completa del bus como un circuito infinito.

Implementacion en la app:

- `BusSimulator.routeLoop`

Por que se usa:

- Cuando el bus llega al ultimo punto de la ruta, puede continuar automaticamente desde el primer punto.

Metodos principales:

- `insertar`: agrega nodo al circuito.
- `eliminar`: elimina nodo del circuito.
- `buscar`: busca valor.
- `buscarNodo`: busca nodo.
- `recorrer`: recorre una vuelta completa.
- `siguiente`: obtiene valor siguiente.
- `anterior`: obtiene valor anterior.
- `siguienteNodo`: obtiene nodo siguiente.
- `anteriorNodo`: obtiene nodo anterior.
- `toDartList`: convierte una vuelta a lista normal.

### Lista circular doble

Archivo: `lib/structures/circular_double_list.dart`

Clases:

- `CircularDoubleNode<T>`
- `CircularDoubleList<T>`

Sirve para navegar en circulo hacia adelante y hacia atras.

Representacion:

```txt
P01 <-> P02 <-> P03
 ^              |
 |______________|
```

En este proyecto se usa para:

- Navegar estaciones/paraderos de forma continua.

Implementacion en la app:

- `BusSimulator.stationLoop`

Por que se usa:

- Si estas en el ultimo paradero y presionas siguiente, vuelve al primero.
- Si estas en el primero y presionas anterior, vuelve al ultimo.

Metodos principales:

- `insertar`: agrega nodo al circuito doble.
- `eliminar`: elimina nodo y reconecta anterior/siguiente.
- `buscar`: busca valor.
- `buscarNodo`: busca nodo.
- `recorrer`: recorre una vuelta completa.
- `siguiente`: obtiene valor siguiente.
- `anterior`: obtiene valor anterior.
- `siguienteNodo`: obtiene nodo siguiente.
- `anteriorNodo`: obtiene nodo anterior.
- `toDartList`: convierte una vuelta a lista normal.

### Como se conectan con el simulador

Archivo: `lib/services/bus_simulator.dart`

El simulador crea una estructura para cada necesidad:

```dart
final CircularSimpleList<RouteNode> routeLoop =
    CircularSimpleList<RouteNode>();

final DoubleLinkedList<StopNode> stopNavigation =
    DoubleLinkedList<StopNode>();

final CircularDoubleList<StopNode> stationLoop =
    CircularDoubleList<StopNode>();

SimpleLinkedList<RouteNode> history =
    SimpleLinkedList<RouteNode>();
```

Significado:

- `routeLoop`: camino por donde se mueve el bus.
- `stopNavigation`: paraderos con anterior y siguiente.
- `stationLoop`: paraderos circulares hacia ambos lados.
- `history`: puntos ya recorridos por el bus.

La idea principal es:

```txt
Ruta del bus = circular simple
Porque el bus da vueltas infinitas.

Paraderos = doble
Porque se necesita consultar anterior y siguiente.

Estaciones circulares = circular doble
Porque se puede avanzar o retroceder sin fin.

Historial = simple
Porque solo se van guardando puntos recorridos en orden.
```

## 12. Flujo de funcionamiento

Flujo principal:

1. `main.dart` inicia `BusTrackerApp`.
2. `BusTrackerApp` abre `MapScreen`.
3. `MapScreen` crea un `BusSimulator`.
4. `BusSimulator` carga la ruta y paraderos desde `av_espana_route.dart`.
5. `BusSimulator.start()` inicia un timer.
6. Cada tick del timer mueve el bus.
7. El simulador llama a `notifyListeners()`.
8. `AnimatedBuilder` reconstruye el mapa.
9. `FlutterMap` actualiza bus, ruta, historial y panel.

## 13. Imagenes e iconos

### Iconos web

Carpeta:

- `web/icons/`

Archivos:

- `Icon-192.png`
- `Icon-512.png`
- `Icon-maskable-192.png`
- `Icon-maskable-512.png`

Sirven para:

- Icono de la app cuando se ejecuta como web app o PWA.

Donde se declaran:

- `web/manifest.json`
- `web/index.html`

### Favicon web

Archivo:

- `web/favicon.png`

Sirve para:

- Icono pequeno de la pestana del navegador.

Donde se declara:

- `web/index.html`

### Iconos Android

Carpetas:

- `android/app/src/main/res/mipmap-mdpi/`
- `android/app/src/main/res/mipmap-hdpi/`
- `android/app/src/main/res/mipmap-xhdpi/`
- `android/app/src/main/res/mipmap-xxhdpi/`
- `android/app/src/main/res/mipmap-xxxhdpi/`

Archivo usado:

- `ic_launcher.png`

Sirve para:

- Icono de la app instalada en Android.

Donde se declara:

- `android/app/src/main/AndroidManifest.xml`

Linea importante:

```xml
android:icon="@mipmap/ic_launcher"
```

### Iconos iOS

Carpeta:

- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

Sirven para:

- Icono de la app instalada en iPhone/iPad.

### Nota sobre imagenes internas

Actualmente la app no muestra imagenes internas con `Image.asset`.

Tambien en `pubspec.yaml` no hay seccion `assets:` activa.

Eso significa:

- Si agregas una imagen para usar dentro de la interfaz, no basta con ponerla en una carpeta.
- Debes declararla en `pubspec.yaml`.
- Luego debes llamarla desde Dart con `Image.asset` o `AssetImage`.

Ejemplo:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

Ejemplo en Dart:

```dart
Image.asset('assets/images/mi_imagen.png')
```

## 14. Archivos Android

### `android/app/src/main/AndroidManifest.xml`

Sirve para declarar configuracion nativa de Android.

En este proyecto define:

- Nombre de actividad principal.
- Icono de la app.
- Tema inicial.
- Configuracion de Flutter.

### `android/app/src/main/kotlin/.../MainActivity.kt`

Sirve como entrada nativa de Android.

Flutter la usa para iniciar la aplicacion.

Normalmente no se modifica salvo que necesites permisos nativos, canales de plataforma o configuracion especifica de Android.

### `android/app/src/main/res/drawable/launch_background.xml`

Sirve para definir el fondo inicial mientras la app carga.

## 15. Archivos web

### `web/index.html`

Sirve como archivo HTML base cuando la app corre en navegador.

Define:

- Favicon.
- Apple touch icon.
- Manifest web.
- Script de carga de Flutter.

### `web/manifest.json`

Sirve para configurar la app web instalable.

Define:

- Nombre de la app.
- Nombre corto.
- Iconos.
- Color de tema.
- Modo de visualizacion.

## 16. Pruebas

Archivo: `test/structures_test.dart`

Sirve para verificar que las estructuras y el simulador funcionen correctamente.

Pruebas incluidas:

- `SimpleLinkedList stores a one-way history`: valida lista simple.
- `DoubleLinkedList navigates previous and next stops`: valida lista doble.
- `CircularSimpleList repeats route points infinitely`: valida lista circular simple.
- `CircularDoubleList navigates stations in both directions`: valida lista circular doble.
- `BusSimulator wires every manual structure to the route domain`: valida que el simulador conecte ruta, paraderos e historial.
- `Av Espana route avoids off-road shortcut jumps`: valida que la ruta no tenga saltos demasiado largos.

Comando para ejecutar pruebas:

```bash
flutter test
```

## 17. Comandos utiles

Instalar dependencias:

```bash
flutter pub get
```

Ejecutar app:

```bash
flutter run
```

Ejecutar app con MapTiler:

```bash
flutter run --dart-define=MAPTILER_KEY=TU_API_KEY
```

Analizar codigo:

```bash
flutter analyze
```

Ejecutar pruebas:

```bash
flutter test
```

Crear APK debug:

```bash
flutter build apk --debug
```

Limpiar cache de compilacion:

```bash
flutter clean
```

## 18. Donde modificar cosas comunes

### Cambiar nombre visible de la app en la interfaz

Archivo:

- `lib/screens/map_screen.dart`

Buscar texto:

```dart
Bus Tracker Trujillo
```

### Cambiar color principal

Archivo:

- `lib/main.dart`

Buscar:

```dart
seedColor
```

### Cambiar ruta del bus

Archivo:

- `lib/data/av_espana_route.dart`

Modificar:

- `avEspanaRoute`

### Cambiar paraderos

Archivo:

- `lib/data/av_espana_route.dart`

Modificar:

- `avEspanaStops`

### Cambiar velocidad simulada

Archivo:

- `lib/services/bus_simulator.dart`

Buscar:

```dart
_speedKmh = (27 + wave * 5).clamp(18, 36).toDouble();
```

### Cambiar frecuencia de actualizacion

Archivo:

- `lib/services/bus_simulator.dart`

Buscar:

```dart
static const _tick = Duration(milliseconds: 60);
```

### Cambiar cantidad maxima de historial

Archivo:

- `lib/services/bus_simulator.dart`

Buscar:

```dart
static const _maxHistory = 800;
```

### Cambiar icono de bus

Archivo:

- `lib/widgets/bus_marker.dart`

Buscar:

```dart
Icons.directions_bus_filled_rounded
```

### Cambiar icono de la app Android

Archivos:

- `android/app/src/main/res/mipmap-*/ic_launcher.png`

### Cambiar iconos web

Archivos:

- `web/icons/*.png`
- `web/favicon.png`

## 19. Resumen de responsabilidades por archivo

| Archivo | Para que sirve | Donde se usa |
| --- | --- | --- |
| `lib/main.dart` | Inicia la app, configura temas y abre `MapScreen`. | Entrada principal de Flutter. |
| `lib/screens/map_screen.dart` | Pantalla principal, mapa, ruta, paraderos, paneles y controles. | Cargado desde `main.dart`. |
| `lib/widgets/bus_marker.dart` | Dibuja el marcador visual del bus. | `MapScreen`, dentro de `MarkerLayer`. |
| `lib/services/bus_simulator.dart` | Motor de simulacion GPS. | `MapScreen`. |
| `lib/data/av_espana_route.dart` | Coordenadas de ruta y paraderos. | `BusSimulator`. |
| `lib/models/route_node.dart` | Modelo de punto de ruta. | Datos, simulador e historial. |
| `lib/models/stop_node.dart` | Modelo de paradero. | Datos, simulador y mapa. |
| `lib/structures/simple_list.dart` | Lista simple enlazada. | Historial de posiciones. |
| `lib/structures/double_list.dart` | Lista doble enlazada. | Navegacion de paraderos. |
| `lib/structures/circular_simple_list.dart` | Lista circular simple. | Ruta infinita del bus. |
| `lib/structures/circular_double_list.dart` | Lista circular doble. | Navegacion circular de estaciones. |
| `test/structures_test.dart` | Pruebas automaticas. | Validacion del proyecto. |
| `pubspec.yaml` | Dependencias y configuracion Flutter. | Flutter CLI. |
| `android/app/src/main/AndroidManifest.xml` | Configuracion Android. | Build Android. |
| `web/index.html` | Entrada web. | Build web. |
| `web/manifest.json` | Configuracion de app web instalable. | Build web/PWA. |


ICONOS|https://fonts.google.com/?selected=Material+Symbols+Outlined:bus_map_pin:FILL@0;wght@400;GRAD@0;opsz@24&icon.size=24&icon.color=%23e3e3e3&icon.platform=android
