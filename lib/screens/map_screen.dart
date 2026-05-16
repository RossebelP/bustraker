import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/stop_node.dart';
import '../services/bus_simulator.dart';
import '../widgets/bus_marker.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    required this.isDarkMode,
    required this.onToggleTheme,
    super.key,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const String _mapTilerKey = String.fromEnvironment('MAPTILER_KEY');

  late final BusSimulator _simulator;
  late final MapController _mapController;

  bool _mapReady = false;
  bool _followBus = true;

  @override
  void initState() {
    super.initState();
    _simulator = BusSimulator()..start();
    _mapController = MapController();
    _simulator.addListener(_centerOnBus);
  }

  @override
  void dispose() {
    _simulator
      ..removeListener(_centerOnBus)
      ..dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: AnimatedBuilder(
        animation: _simulator,
        builder: (context, _) {
          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _simulator.position,
                  initialZoom: 15.2,
                  minZoom: 13,
                  maxZoom: 18.5,
                  backgroundColor: theme.colorScheme.surface,
                  interactionOptions: const InteractionOptions(
                    flags:
                        InteractiveFlag.drag |
                        InteractiveFlag.flingAnimation |
                        InteractiveFlag.pinchMove |
                        InteractiveFlag.pinchZoom |
                        InteractiveFlag.doubleTapZoom |
                        InteractiveFlag.scrollWheelZoom,
                  ),
                  onMapReady: () {
                    _mapReady = true;
                    _centerOnBus();
                  },
                  onPositionChanged: (_, hasGesture) {
                    if (hasGesture && _followBus) {
                      setState(() => _followBus = false);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: _tileUrl,
                    userAgentPackageName: 'edu.trujillo.bus_tracker_trujillo',
                    maxNativeZoom: 19,
                    retinaMode: true,
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _closedRoute(_simulator.routePath),
                        color: const Color(0xFF0A84FF),
                        strokeWidth: 7,
                        borderColor: Colors.white.withValues(alpha: 0.55),
                        borderStrokeWidth: 2,
                      ),
                      if (_simulator.traveledPath.length > 1)
                        Polyline(
                          points: _simulator.traveledPath,
                          color: const Color(0xFF5AC8FA),
                          strokeWidth: 4,
                        ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      ..._buildStopMarkers(context, _simulator.stops),
                      Marker(
                        point: _simulator.position,
                        width: 58,
                        height: 58,
                        child: BusMarker(
                          bearing: _simulator.bearing,
                          isRunning: _simulator.isRunning,
                        ),
                      ),
                    ],
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        _mapTilerKey.isEmpty
                            ? 'OpenStreetMap contributors'
                            : 'OpenStreetMap / MapTiler',
                      ),
                    ],
                  ),
                ],
              ),
              _TopBar(
                followBus: _followBus,
                isDarkMode: widget.isDarkMode,
                onCenter: _enableFollowBus,
                onToggleTheme: widget.onToggleTheme,
              ),
              _BottomPanel(
                simulator: _simulator,
                onToggleSimulation: _simulator.toggle,
                onPreviousStop: _simulator.selectPreviousStop,
                onNextStop: _simulator.selectNextStop,
                onPreviousStation: _simulator.selectPreviousStation,
                onNextStation: _simulator.selectNextStation,
              ),
            ],
          );
        },
      ),
    );
  }

  String get _tileUrl {
    if (_mapTilerKey.isEmpty) {
      return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }

    final style = widget.isDarkMode ? 'dataviz-dark' : 'streets-v2';
    return 'https://api.maptiler.com/maps/$style/{z}/{x}/{y}.png?key=$_mapTilerKey';
  }

  List<LatLng> _closedRoute(List<LatLng> route) {
    if (route.length < 2) {
      return route;
    }

    return [...route, route.first];
  }

  List<Marker> _buildStopMarkers(BuildContext context, List<StopNode> stops) {
    final colorScheme = Theme.of(context).colorScheme;
    return stops.map((stop) {
      final isCurrent = _simulator.currentStop?.id == stop.id;
      return Marker(
        point: stop.point,
        width: isCurrent ? 42 : 34,
        height: isCurrent ? 42 : 34,
        alignment: Alignment.center,
        child: Tooltip(
          message: '${stop.id} - ${stop.name}',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            decoration: BoxDecoration(
              color: isCurrent
                  ? const Color(0xFFFFCC00)
                  : colorScheme.surface.withValues(alpha: 0.92),
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrent ? Colors.white : const Color(0xFF0A84FF),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: isCurrent ? Colors.black87 : const Color(0xFF0A84FF),
              size: isCurrent ? 24 : 20,
            ),
          ),
        ),
      );
    }).toList();
  }

  void _centerOnBus() {
    if (!_mapReady || !_followBus) {
      return;
    }

    _mapController.move(
      _simulator.position,
      _mapController.camera.zoom.clamp(14.8, 17.2).toDouble(),
      id: 'bus-follow',
    );
  }

  void _enableFollowBus() {
    setState(() => _followBus = true);
    _centerOnBus();
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.followBus,
    required this.isDarkMode,
    required this.onCenter,
    required this.onToggleTheme,
  });

  final bool followBus;
  final bool isDarkMode;
  final VoidCallback onCenter;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.directions_bus_filled_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Bus Tracker Trujillo',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        followBus ? 'Siguiendo unidad' : 'Mapa libre',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'Centrar bus',
                  child: IconButton.filledTonal(
                    onPressed: onCenter,
                    icon: Icon(
                      followBus
                          ? Icons.gps_fixed_rounded
                          : Icons.gps_not_fixed_rounded,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: isDarkMode ? 'Modo claro' : 'Modo oscuro',
                  child: IconButton(
                    onPressed: onToggleTheme,
                    icon: Icon(
                      isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.simulator,
    required this.onToggleSimulation,
    required this.onPreviousStop,
    required this.onNextStop,
    required this.onPreviousStation,
    required this.onNextStation,
  });

  final BusSimulator simulator;
  final VoidCallback onToggleSimulation;
  final VoidCallback onPreviousStop;
  final VoidCallback onNextStop;
  final VoidCallback onPreviousStation;
  final VoidCallback onNextStation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stop = simulator.currentStop;
    final station = simulator.currentStation;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            simulator.statusLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _StatusPill(isRunning: simulator.isRunning),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.speed_rounded,
                            label: 'Velocidad',
                            value:
                                '${simulator.speedKmh.toStringAsFixed(1)} km/h',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.route_rounded,
                            label: 'Recorrido',
                            value:
                                '${simulator.coveredKilometers.toStringAsFixed(2)} km',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.timeline_rounded,
                            label: 'Historial',
                            value: '${simulator.historyCount} pts',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _StopSummary(
                      title: 'Paradero actual',
                      value: stop?.name ?? 'Sin paradero',
                      detail: stop?.description ?? 'Esperando simulacion',
                    ),
                    const SizedBox(height: 8),
                    _NavigationStrip(
                      previousLabel: simulator.previousStop?.name ?? 'Inicio',
                      currentLabel: stop?.id ?? '--',
                      nextLabel: simulator.nextStop?.name ?? 'Fin',
                      onPrevious: onPreviousStop,
                      onNext: onNextStop,
                    ),
                    const SizedBox(height: 8),
                    _NavigationStrip(
                      previousLabel: simulator.previousStation?.name ?? '--',
                      currentLabel: station?.id ?? '--',
                      nextLabel: simulator.nextStation?.name ?? '--',
                      onPrevious: onPreviousStation,
                      onNext: onNextStation,
                      continuous: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: onToggleSimulation,
                            icon: Icon(
                              simulator.isRunning
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                            label: Text(
                              simulator.isRunning ? 'Detener' : 'Iniciar',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.72,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isRunning});

  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isRunning
            ? const Color(0xFF30D158).withValues(alpha: 0.18)
            : const Color(0xFFFF9F0A).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          isRunning ? 'Activo' : 'Pausado',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isRunning
                ? const Color(0xFF1F9D49)
                : const Color(0xFFB25D00),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StopSummary extends StatelessWidget {
  const _StopSummary({
    required this.title,
    required this.value,
    required this.detail,
  });

  final String title;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(
              Icons.departure_board_rounded,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavigationStrip extends StatelessWidget {
  const _NavigationStrip({
    required this.previousLabel,
    required this.currentLabel,
    required this.nextLabel,
    required this.onPrevious,
    required this.onNext,
    this.continuous = false,
  });

  final String previousLabel;
  final String currentLabel;
  final String nextLabel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool continuous;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.48,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          children: [
            Tooltip(
              message: continuous ? 'Anterior circular' : 'Paradero anterior',
              child: IconButton(
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
            ),
            Expanded(
              child: Text(
                previousLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: theme.textTheme.labelMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: continuous
                      ? const Color(0xFF64D2FF).withValues(alpha: 0.22)
                      : theme.colorScheme.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Text(
                    currentLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                nextLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium,
              ),
            ),
            Tooltip(
              message: continuous ? 'Siguiente circular' : 'Paradero siguiente',
              child: IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
