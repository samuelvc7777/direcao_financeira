import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../domain/entities/tracked_route_point_entity.dart';
import '../shift_route_controller.dart';

class ShiftRouteContent extends GetView<ShiftRouteController> {
  const ShiftRouteContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value != null) {
        return _ShiftRouteState(
          icon: Icons.map_outlined,
          title: controller.errorMessage.value!,
          actionLabel: 'Tentar novamente',
          onPressed: controller.loadRoute,
        );
      }

      final route = controller.route.value;
      if (route == null || !route.hasPoints) {
        return const _ShiftRouteState(
          icon: Icons.route_outlined,
          title: 'Nenhum ponto de rota foi registrado para este turno.',
        );
      }

      final polylinePoints = route.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
      final center = _calculateCenter(route.points);
      final shift = controller.shift.value;

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          Responsive.hp(context, 4.0).clamp(12.0, 20.0),
          16,
          Responsive.hp(context, 4.0).clamp(12.0, 20.0),
          32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.midnight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shift?.date ?? 'Turno',
                    style: context.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _MetricChip(
                        icon: Icons.route_rounded,
                        label:
                            '${route.totalDistanceKm.toStringAsFixed(1)} km rastreados',
                      ),
                      _MetricChip(
                        icon: Icons.pin_drop_outlined,
                        label: '${route.pointCount} pontos',
                      ),
                      _MetricChip(
                        icon: Icons.access_time_rounded,
                        label:
                            '${_formatTime(route.startedAt)} - ${_formatTime(route.endedAt)}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              height: 360,
              decoration: BoxDecoration(
                color: AppColors.midnight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 14,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'com.example.direcao_financeira_mobile',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: polylinePoints,
                        strokeWidth: 5,
                        color: AppColors.electricCyan,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: polylinePoints.first,
                        width: 42,
                        height: 42,
                        child: const _RouteMarker(
                          color: AppColors.emerald,
                          icon: Icons.play_arrow_rounded,
                        ),
                      ),
                      Marker(
                        point: polylinePoints.last,
                        width: 42,
                        height: 42,
                        child: const _RouteMarker(
                          color: AppColors.rose,
                          icon: Icons.stop_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  LatLng _calculateCenter(List<TrackedRoutePointEntity> points) {
    final latitude =
        points.fold<double>(0, (sum, point) => sum + point.latitude) /
        points.length;
    final longitude =
        points.fold<double>(0, (sum, point) => sum + point.longitude) /
        points.length;
    return LatLng(latitude, longitude);
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.electricCyan, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteMarker extends StatelessWidget {
  const _RouteMarker({
    required this.color,
    required this.icon,
  });

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

class _ShiftRouteState extends StatelessWidget {
  const _ShiftRouteState({
    required this.icon,
    required this.title,
    this.actionLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (actionLabel != null && onPressed != null) ...[
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: onPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
