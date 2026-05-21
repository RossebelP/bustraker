# Bus Tracker Trujillo

Aplicacion Flutter universitaria que simula el recorrido GPS de un bus urbano alrededor de la Avenida Espana de Trujillo, Peru. Usa `flutter_map`, OpenStreetMap, soporte opcional de MapTiler y estructuras de datos enlazadas implementadas manualmente en Dart.

## Como ejecutar

```bash
flutter pub get
flutter run
```

Con MapTiler:

```bash
flutter run --dart-define=MAPTILER_KEY=TU_API_KEY
```

Sin clave de MapTiler la app usa teselas publicas de OpenStreetMap como respaldo, por eso compila y corre igual.

## Archivos principales

- `lib/main.dart`: configura `MaterialApp`, tema claro/oscuro y abre la pantalla del mapa.
- `lib/screens/map_screen.dart`: muestra el mapa, la ruta azul, los paraderos, el bus, el panel de estado, velocidad, recorrido y controles.
- `lib/services/bus_simulator.dart`: motor de simulacion GPS. Interpola coordenadas, calcula velocidad, distancia, direccion, estado y sincroniza paraderos.
- `lib/widgets/bus_marker.dart`: marcador visual personalizado del bus con rotacion segun rumbo.
- `lib/data/av_espana_route.dart`: coordenadas de ruta y paraderos base de Avenida Espana.
- `lib/models/route_node.dart`: modelo de punto geografico de la ruta.
- `lib/models/stop_node.dart`: modelo de paradero o punto de control.
- `lib/structures/simple_list.dart`: lista simple enlazada con nodos manuales.
- `lib/structures/double_list.dart`: lista doble enlazada con referencias `previous` y `next`.
- `lib/structures/circular_simple_list.dart`: lista circular simple para repetir la ruta.
- `lib/structures/circular_double_list.dart`: lista circular doble para estaciones navegables en ambos sentidos.
- `test/structures_test.dart`: pruebas de insercion, eliminacion, busqueda, recorrido y navegacion.

## Documentacion completa

La explicacion detallada de cada archivo, clase, metodo, estructura, imagen e implementacion esta en:

- `DOCUMENTACION.md`

## Uso real de las estructuras

| Estructura | Archivo | Uso en la app |
| --- | --- | --- |
| Lista Simple | `simple_list.dart` | Guarda el historial basico de posiciones recorridas. El mapa dibuja ese historial como recorrido en tiempo real. |
| Lista Doble | `double_list.dart` | Permite saber el paradero anterior y siguiente sin recorrer desde cero cada vez. Los botones del panel navegan entre paraderos. |
| Lista Circular Simple | `circular_simple_list.dart` | Almacena la ruta cerrada del bus. Cuando llega al ultimo punto, `siguiente` vuelve al primero y la vuelta se repite infinitamente. |
| Lista Circular Doble | `circular_double_list.dart` | Maneja estaciones o puntos de control en navegacion continua hacia adelante y hacia atras. |

Cada estructura implementa nodos propios y metodos `insertar`, `eliminar`, `recorrer`, `buscar`, `siguiente` y `anterior`. Las listas de Dart solo se usan para adaptar datos al renderizado de Flutter, no como estructura principal del sistema.

## Detalles de simulacion

- El bus se mueve por interpolacion entre coordenadas consecutivas.
- La posicion siempre se calcula sobre la polilinea dibujada, por lo que no sale de la ruta.
- La velocidad es simulada con variacion suave para verse realista.
- El mapa sigue automaticamente al bus y permite desactivar ese seguimiento al mover el mapa.
- El modo oscuro cambia la interfaz y, si hay clave MapTiler, tambien cambia el estilo del mapa.
