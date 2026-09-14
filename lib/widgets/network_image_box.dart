import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class NetworkImageBox extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const NetworkImageBox({super.key, required this.url, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder();
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (context, _) => _placeholder(loading: true),
      errorWidget: (context, _, __) => _placeholder(),
    );
  }

  Widget _placeholder({bool loading = false}) {
    return Container(
      color: AppColors.outline.withValues(alpha: 0.5),
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            )
          : const Icon(Icons.landscape_outlined, color: AppColors.textSecondary, size: 32),
    );
  }
}
