class GpsConstants {
  /// Maximum acceptable GPS accuracy in meters. Fixes with worse accuracy are discarded.
  static const double maxAcceptableAccuracyM = 20.0;

  /// Minimum distance in meters between accepted points to filter out stationary jitter.
  static const double minDistanceFilterM = 2.0;

  /// Default map initial zoom.
  static const double defaultMapZoom = 15.0;

  /// Default simulation speed multiplier for synthetic tracks.
  static const double defaultSimulationSpeedMultiplier = 1.0;
}
