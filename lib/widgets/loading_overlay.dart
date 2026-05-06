import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../providers/loader_provider.dart';
import '../theme/app_theme.dart';

class GlobalLoadingOverlay extends StatelessWidget {
  final Widget child;

  const GlobalLoadingOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Consumer<LoaderProvider>(
          builder: (context, loader, child) {
            if (!loader.isLoading) return const SizedBox.shrink();
            return Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: SpinKitFadingCircle(
                  color: AppTheme.primaryColor,
                  size: 50.0,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
