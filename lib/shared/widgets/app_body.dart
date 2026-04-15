import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';

class AppBody extends StatelessWidget {
  const AppBody({super.key, required this.slivers, this.bottomPadding = 120});

  final List<Widget> slivers;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppSpacing.tabletBreakpoint,
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            ...slivers,
            SliverToBoxAdapter(
              key: const ValueKey('app_body_bottom_padding'),
              child: SizedBox(height: bottomPadding),
            ),
          ],
        ),
      ),
    );
  }
}
