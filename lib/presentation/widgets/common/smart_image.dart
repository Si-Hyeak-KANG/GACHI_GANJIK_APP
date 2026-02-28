import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// imageUrl이 로컬 파일 경로(/var/..., /data/...)면 Image.file()
/// http/https URL이면 CachedNetworkImage 사용
class SmartImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SmartImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  bool get _isLocalPath =>
      imageUrl.startsWith('/') || imageUrl.startsWith('file://');

  @override
  Widget build(BuildContext context) {
    if (_isLocalPath) {
      return Image.file(
        File(imageUrl.replaceFirst('file://', '')),
        fit: fit,
        errorBuilder: (_, __, ___) =>
        errorWidget ?? _defaultError,
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      placeholder: (_, __) =>
      placeholder ?? _defaultPlaceholder,
      errorWidget: (_, __, ___) =>
      errorWidget ?? _defaultError,
    );
  }

  Widget get _defaultPlaceholder => Container(
    color: AppColors.cardBg,
    child: const Center(
      child: CircularProgressIndicator(
        color: AppColors.main,
        strokeWidth: 2,
      ),
    ),
  );

  Widget get _defaultError => Container(
    color: AppColors.cardBg,
    child: const Icon(
      Icons.broken_image_outlined,
      color: AppColors.inactive,
      size: 28,
    ),
  );
}