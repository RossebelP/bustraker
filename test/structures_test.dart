import 'package:bus_tracker_trujillo/data/av_espana_route.dart';
import 'package:bus_tracker_trujillo/services/bus_simulator.dart';
import 'package:bus_tracker_trujillo/structures/circular_double_list.dart';
import 'package:bus_tracker_trujillo/structures/circular_simple_list.dart';
import 'package:bus_tracker_trujillo/structures/double_list.dart';
import 'package:bus_tracker_trujillo/structures/simple_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  test('SimpleLinkedList stores a one-way history', () {
    final history = SimpleLinkedList<int>();

    history.insertar(10);
    history.insertar(20);
    history.insertar(30);

    expect(history.toDartList(), [10, 20, 30]);
    expect(history.buscar((value) => value == 20), 20);
    expect(history.siguiente(20), 30);
    expect(history.anterior(20), 10);

    history.eliminar((value) => value == 20);

    expect(history.toDartList(), [10, 30]);
  });

  test('DoubleLinkedList navigates previous and next stops', () {
    final stops = DoubleLinkedList<String>();

    final first = stops.insertar('Ovalo Larco');
    final second = stops.insertar('El Recreo');
    stops.insertar('Mercado Central');

    expect(stops.siguienteNodo(first), second);
    expect(stops.anteriorNodo(second), first);
    expect(stops.siguiente('El Recreo'), 'Mercado Central');
    expect(stops.anterior('El Recreo'), 'Ovalo Larco');
  });

  test('CircularSimpleList repeats route points infinitely', () {
    final route = CircularSimpleList<String>();

    final a = route.insertar('A');
    final b = route.insertar('B');
    final c = route.insertar('C');

    expect(route.siguienteNodo(a), b);
    expect(route.siguienteNodo(b), c);
    expect(route.siguienteNodo(c), a);
    expect(route.siguiente('C'), 'A');
  });

  test('CircularDoubleList navigates stations in both directions', () {
    final stations = CircularDoubleList<String>();

    final north = stations.insertar('Norte');
    final east = stations.insertar('Este');
    final south = stations.insertar('Sur');

    expect(stations.siguienteNodo(south), north);
    expect(stations.anteriorNodo(north), south);
    expect(stations.anteriorNodo(east), north);
  });

  test('BusSimulator wires every manual structure to the route domain', () {
    final simulator = BusSimulator();

    expect(simulator.routeLoop.length, greaterThan(10));
    expect(simulator.stopNavigation.length, greaterThan(3));
    expect(simulator.stationLoop.length, simulator.stopNavigation.length);
    expect(simulator.history.length, 1);
    expect(simulator.currentStop?.name, 'Zona Este');
    expect(simulator.nextStop?.name, isNotNull);
    expect(simulator.previousStation?.name, isNotNull);

    simulator.dispose();
  });

  test('Av Espana route avoids off-road shortcut jumps', () {
    const distance = Distance(roundResult: false);
    var longestSegment = 0.0;

    for (var i = 0; i < avEspanaRoute.length; i++) {
      final current = avEspanaRoute[i].point;
      final next = avEspanaRoute[(i + 1) % avEspanaRoute.length].point;
      final meters = distance(current, next);
      if (meters > longestSegment) {
        longestSegment = meters;
      }
    }

    expect(longestSegment, lessThan(250));
  });
}
