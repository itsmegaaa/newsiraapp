/// Defines breakpoint values for responsive layout. The mobile
/// breakpoint is set according to the UI brief: screens narrower than
/// this value use the mobile layout with a drawer and AppBar, while
/// wider screens display a fixed sidebar.
class AppBreakpoints {
  AppBreakpoints._();

  /// The width threshold below which the UI switches to its mobile
  /// variant. When the available width is less than this value,
  /// layouts should collapse into a single column and show a drawer.
  static const double mobile = 768.0;
}