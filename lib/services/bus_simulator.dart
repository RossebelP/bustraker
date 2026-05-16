import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../data/av_espana_route.dart';
import '../models/route_node.dart';
import '../models/stop_node.dart';
import '../structures/circular_double_list.dart';
import '../structures/circular_simple_list.dart';
import '../structures/double_list.dart';
import '../structures/simple_list.dart';

class BusSimulator extends ChangeNotifier {
  BusSimulator() {
    for (final point in avEspanaRoute) {
      routeLoop.insertar(point);
    }

    for (final stop in avEspanaStops) {
      stopNavigation.insertar(stop);
      stationLoop.insertar(stop);
    }

    _currentRouteNode = routeLoop.head!;
    _nextRouteNode = routeLoop.siguienteNodo(_currentRouteNode)!;
    _currentStopNode = stopNavigation.head;
    _currentStationNode = stationLoop.head;
    _position = _currentRouteNode.value.point;
    _previousPosition = _position;
    _appendHistory(force: true);
  }

  static const _tick = Duration(milliseconds: 60);
  static const _maxHistory = 800;

  final Distance _distance = const Distance(roundResult: false);

  final CircularSimpleList<RouteNode> routeLoop =
      CircularSimpleList<RouteNode>();
  final DoubleLinkedList<StopNode> stopNavigation =
      DoubleLinkedList<StopNode>();
  final CircularDoubleList<StopNode> stationLoop =
      CircularDoubleList<StopNode>();
  SimpleLinkedList<RouteNode> history = SimpleLinkedList<RouteNode>();

  late CircularSimpleNode<RouteNode> _currentRouteNode;
  late CircularSimpleNode<RouteNode> _nextRouteNode;
  DoubleListNode<StopNode>? _currentStopNode;
  CircularDoubleNode<StopNode>? _currentStationNode;

  Timer? _timer;
  DateTime? _lastTick;
  Duration _elapsed = Duration.zero;
  LatLng _position = const LatLng(-8.1030686, -79.0344980);
  LatLng _previousPosition = const LatLng(-8.1030686, -79.0344980);
  LatLng? _lastHistoryPoint;
  double _segmentProgress = 0;
  double _speedKmh = 0;
  double _coveredMeters = 0;
  double _bearing = 90;

  bool get isRunning => _timer?.isActive ?? false;
  LatLng get position => _position;
  double get speedKmh => _speedKmh;
  double get coveredKilometers => _coveredMeters / 1000;
  double get bearing => _bearing;
  int get historyCount => history.length;
  Duration get elapsed => _elapsed;
  StopNode? get currentStop => _currentStopNode?.value;
  StopNode? get currentStation => _currentStationNode?.value;

  StopNode? get nextStop {
    return stopNavigation.siguienteNodo(_currentStopNode)?.value;
  }

  StopNode? get previousStop {
    return stopNavigation.anteriorNodo(_currentStopNode)?.value;
  }

  StopNode? get nextStation {
    return stationLoop.siguienteNodo(_currentStationNode)?.value;
  }

  StopNode? get previousStation {
    return stationLoop.anteriorNodo(_currentStationNode)?.value;
  }

  String get statusLabel {
    if (!isRunning) {
      return 'Detenido';
    }

    final stop = currentStop;
    if (stop != null && _distance(_position, stop.point) < 75) {
      return 'Llegando a ${stop.name}';
    }

    return 'En ruta';
  }

  List<LatLng> get routePath {
    return routeLoop.toDartList().map((point) => point.point).toList();
  }

  List<LatLng> get traveledPath {
    return history.toDartList().map((point) => point.point).toList();
  }

  List<StopNode> get stops => stopNavigation.toDartList();

  void start() {
    if (isRunning) {
      return;
    }

    _lastTick = DateTime.now();
    _timer = Timer.periodic(_tick, _advance);
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _speedKmh = 0;
    notifyListeners();
  }

  void toggle() {
    isRunning ? stop() : start();
  }

  void reset() {
    stop();
    _currentRouteNode = routeLoop.head!;
    _nextRouteNode = routeLoop.siguienteNodo(_currentRouteNode)!;
    _currentStopNode = stopNavigation.head;
    _currentStationNode = stationLoop.head;
    _segmentProgress = 0;
    _speedKmh = 0;
    _coveredMeters = 0;
    _elapsed = Duration.zero;
    _position = _currentRouteNode.value.point;
    _previousPosition = _position;
    _lastHistoryPoint = null;
    history = SimpleLinkedList<RouteNode>();
    _appendHistory(force: true);
    notifyListeners();
  }

  void selectNextStop() {
    _currentStopNode =
        stopNavigation.siguienteNodo(_currentStopNode) ?? _currentStopNode;
    notifyListeners();
  }

  void selectPreviousStop() {
    _currentStopNode =
        stopNavigation.anteriorNodo(_currentStopNode) ?? _currentStopNode;
    notifyListeners();
  }

  void selectNextStation() {
    _currentStationNode = stationLoop.siguienteNodo(_currentStationNode);
    notifyListeners();
  }

  void selectPreviousStation() {
    _currentStationNode = stationLoop.anteriorNodo(_currentStationNode);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _advance(Timer timer) {
    final now = DateTime.now();
    final lastTick = _lastTick ?? now;
    final delta = now.difference(lastTick);
    _lastTick = now;
    _elapsed += delta;

    final wave = math.sin(_elapsed.inMilliseconds / 2200);
    _speedKmh = (27 + wave * 5).clamp(18, 36).toDouble();

    final meters = (_speedKmh / 3.6) * (delta.inMilliseconds / 1000);
    _move(meters);
    _appendHistory();
    _syncNearestNodes();
    notifyListeners();
  }

  void _move(double meters) {
    if (meters <= 0) {
      return;
    }

    var remaining = meters;
    while (remaining > 0) {
      final start = _currentRouteNode.value.point;
      final end = _nextRouteNode.value.point;
      final segmentMeters = math.max(_distance(start, end), 1);
      final segmentRemaining = segmentMeters * (1 - _segmentProgress);

      if (remaining < segmentRemaining) {
        _segmentProgress += remaining / segmentMeters;
        remaining = 0;
      } else {
        remaining -= segmentRemaining;
        _currentRouteNode = _nextRouteNode;
        _nextRouteNode = routeLoop.siguienteNodo(_currentRouteNode)!;
        _segmentProgress = 0;
      }
    }

    _previousPosition = _position;
    _position = _interpolate(
      _currentRouteNode.value.point,
      _nextRouteNode.value.point,
      _segmentProgress,
    );

    if (_distance(_previousPosition, _position) > 0.2) {
      _bearing = _normalizeBearing(
        _distance.bearing(_previousPosition, _position),
      );
    }

    _coveredMeters += meters;
  }

  LatLng _interpolate(LatLng start, LatLng end, double progress) {
    final t = progress.clamp(0, 1).toDouble();
    return LatLng(
      start.latitude + (end.latitude - start.latitude) * t,
      start.longitude + (end.longitude - start.longitude) * t,
    );
  }

  double _normalizeBearing(double bearing) {
    final normalized = bearing % 360;
    return normalized < 0 ? normalized + 360 : normalized;
  }

  void _appendHistory({bool force = false}) {
    if (!force &&
        _lastHistoryPoint != null &&
        _distance(_lastHistoryPoint!, _position) < 4) {
      return;
    }

    history.insertar(
      RouteNode(
        lat: _position.latitude,
        lng: _position.longitude,
        label: 'Historial ${history.length + 1}',
      ),
    );
    _lastHistoryPoint = _position;

    while (history.length > _maxHistory) {
      history.eliminarPrimero();
    }
  }

  void _syncNearestNodes() {
    var bestStopDistance = double.infinity;
    DoubleListNode<StopNode>? nearestStop;
    var stopNode = stopNavigation.head;
    while (stopNode != null) {
      final distance = _distance(_position, stopNode.value.point);
      if (distance < bestStopDistance) {
        bestStopDistance = distance;
        nearestStop = stopNode;
      }
      stopNode = stopNode.next;
    }

    if (nearestStop != null && bestStopDistance < 140) {
      _currentStopNode = nearestStop;
    }

    var bestStationDistance = double.infinity;
    CircularDoubleNode<StopNode>? nearestStation;
    var stationNode = stationLoop.head;
    for (var i = 0; i < stationLoop.length; i++) {
      final node = stationNode;
      if (node == null) {
        break;
      }

      final distance = _distance(_position, node.value.point);
      if (distance < bestStationDistance) {
        bestStationDistance = distance;
        nearestStation = node;
      }
      stationNode = node.next;
    }

    if (nearestStation != null && bestStationDistance < 140) {
      _currentStationNode = nearestStation;
    }
  }
}
