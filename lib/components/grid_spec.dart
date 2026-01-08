class GridSpec {
  final int columns;
  final double cardWidth;
  const GridSpec(this.columns, this.cardWidth);
}

GridSpec gridSpecByScreen({
  required bool isMobile,
  required bool isTablet,
  required double contentWidth, // from LayoutBuilder constraints
  required double spacing,
}) {
  final cols = isMobile ? 1 : (isTablet ? 2 : 3); // ✅ force 1/2/3
  final totalSpacing = spacing * (cols - 1);
  final inner = (contentWidth - totalSpacing) / cols;
  final cardW = inner.clamp(280.0, 480.0); // keep nice readable cards
  return GridSpec(cols, cardW);
}

// GridSpec gridSpec(SectionConfig cfg) {
//   final w = cfg.maxWidth - (cfg.gap * 2); // rough content width inside padding
//   final cols = cfg.isMobile ? 1 : (cfg.isTablet ? 2 : 3);
//   final totalSpacing = cfg.gap * (cols - 1);
//   final cw = ((w - totalSpacing) / cols).clamp(280, 480);
//   return GridSpec(cols, cw.toDouble());
// }
