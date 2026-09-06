import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/providers/cadence_provider.dart';
import '../../core/theme/app_colors.dart';

class GpsScreen extends ConsumerStatefulWidget {
  const GpsScreen({super.key});

  @override
  ConsumerState<GpsScreen> createState() => _GpsScreenState();
}

class _GpsScreenState extends ConsumerState<GpsScreen> {
  bool _isTracking = false;
  final double _distanceKm = 0.0;
  final List<LatLng> _routePoints = [
    const LatLng(37.7749, -122.4194), // Default start (San Francisco example)
    const LatLng(37.7755, -122.4185),
    const LatLng(37.7762, -122.4178),
  ];

  void _toggleTracking() {
    setState(() {
      _isTracking = !_isTracking;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isTracking ? 'GPS Tracking started' : 'GPS Tracking paused')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cadenceState = ref.watch(cadenceProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        title: const Text('GPS Route Tracker'),
        backgroundColor: AppColors.surfacePanel,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _routePoints.first,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.cadence.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: AppColors.traceCalm,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 72),
              color: AppColors.surfacePanel,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric('Distance', '${_distanceKm.toStringAsFixed(2)} km'),
                      _buildMetric('Target SPM', '${cadenceState.targetCadence}'),
                      _buildMetric('Status', _isTracking ? 'ACTIVE' : 'READY', color: _isTracking ? AppColors.traceCalm : AppColors.textMuted),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _toggleTracking,
                    icon: Icon(_isTracking ? Icons.pause : Icons.play_arrow),
                    label: Text(_isTracking ? 'PAUSE GPS RUN' : 'START GPS RUN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isTracking ? AppColors.statusDanger : AppColors.traceCalm,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color ?? AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

