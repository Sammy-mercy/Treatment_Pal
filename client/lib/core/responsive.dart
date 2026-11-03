import 'package:flutter/material.dart';

enum ScreenSize { compact, medium, expanded }

ScreenSize screenSizeFor(double width) => width >= 1280
    ? ScreenSize.expanded
    : width >= 768
        ? ScreenSize.medium
        : ScreenSize.compact;

extension ResponsiveContext on BuildContext {
  ScreenSize get screenSize => screenSizeFor(MediaQuery.sizeOf(this).width);
  bool get isCompact => screenSize == ScreenSize.compact;
  bool get isWide => screenSize != ScreenSize.compact;
}

double pageGutter(ScreenSize s) => switch (s) {
      ScreenSize.compact => 16,
      ScreenSize.medium => 24,
      ScreenSize.expanded => 32,
    };

class GridList extends StatelessWidget {
  const GridList({super.key, required this.children, this.minTileWidth = 340, this.spacing = 12, this.maxColumns = 3});
  final List<Widget> children;
  final double minTileWidth;
  final double spacing;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final cols = ((w + spacing) / (minTileWidth + spacing)).floor().clamp(1, maxColumns);
      final tile = (w - spacing * (cols - 1)) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [for (final ch in children) SizedBox(width: tile, child: ch)],
      );
    });
  }
}

class MainAside extends StatelessWidget {
  const MainAside({super.key, required this.main, required this.aside, this.breakpoint = 900, this.gap = 24});
  final Widget main;
  final Widget aside;
  final double breakpoint;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth >= breakpoint) {
        final asideW = (c.maxWidth * 0.34).clamp(320.0, 440.0);
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: main),
          SizedBox(width: gap),
          SizedBox(width: asideW, child: aside),
        ]);
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [main, SizedBox(height: gap), aside]);
    });
  }
}
