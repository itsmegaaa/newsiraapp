/// Defines radii for rounded corners. Using these constants
/// ensures that components feel like they belong to the same family.
class AppRadius {
  AppRadius._();

  /// Very large radius for hero elements and special surfaces.
  static const double cardXL = 32.0;

  /// Large radius for primary cards and glass surfaces.
  static const double cardL = 24.0;

  /// Medium radius for secondary cards and panels.
  static const double cardM = 16.0;

  /// Small radius for chips and list items.
  static const double cardS = 12.0;

  /// Radius for pills and status badges. Use on containers
  /// with fully rounded corners (capsule shape).
  static const double pill = 32.0;

  /// Radius for typical buttons.
  static const double button = 12.0;
}