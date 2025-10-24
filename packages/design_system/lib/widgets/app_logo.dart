import 'package:flutter/material.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

/// A small widget that displays the app logo from an image asset.
///
/// By default it tries to load the asset at
/// `packages/app_images/assets/images/logo.png`. You can override the
/// [assetPath] to point to a different image.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
  this.assetPath = 'assets/images/logo-listfy.svg',
    this.packageName,
    this.size = 96,
    this.semanticLabel,
  });
  final String assetPath;
  /// Optional explicit package name to load the asset from.
  final String? packageName;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    // Normalize package-style paths like 'packages/app_images/assets/...'
    String finalAsset = assetPath;
    String? pkg = packageName;
    const packagesPrefix = 'packages/';
    if (finalAsset.startsWith(packagesPrefix)) {
      final rest = finalAsset.substring(packagesPrefix.length);
      final parts = rest.split('/');
      if (parts.length >= 2) {
        pkg = parts.first;
        finalAsset = parts.sublist(1).join('/');
      }
    }

    if (finalAsset.toLowerCase().endsWith('.svg')) {
      // Try to load the SVG via the asset bundle. We use a FutureBuilder
      // so we can fallback gracefully if the asset isn't available at the
      // expected key (this was causing a runtime crash previously).
      return FutureBuilder<Uint8List>(
        future: _loadAssetBytes(finalAsset, pkg),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SvgPicture.memory(
              snapshot.data!,
              width: size,
              height: size,
              semanticsLabel: semanticLabel,
              fit: BoxFit.contain,
            );
          }

          // While loading or on error, show a stable placeholder.
          return SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Icon(
                Icons.menu_book_rounded,
                size: size * 0.8,
                color: AppColors.primary,
              ),
            ),
          );
        },
      );
    }

    return Image.asset(
      finalAsset,
      package: pkg,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(
              Icons.menu_book_rounded,
              size: size * 0.8,
              color: AppColors.primary,
            ),
          ),
        );
      },
      semanticLabel: semanticLabel,
      fit: BoxFit.contain,
    );
  }

  // Loads raw bytes for an asset key. For package assets the key must be
  // 'packages/<package>/<assetPath>'. This helper throws if asset not
  // found, which is handled by the FutureBuilder above.
  static Future<Uint8List> _loadAssetBytes(String asset, String? pkg) async {
    final key = (pkg != null) ? 'packages/$pkg/$asset' : asset;
    final data = await rootBundle.load(key);
    return data.buffer.asUint8List();
  }
}
