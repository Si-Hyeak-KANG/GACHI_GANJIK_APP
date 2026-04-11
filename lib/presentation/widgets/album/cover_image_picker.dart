import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// 앨범 생성/수정에서 공통으로 사용하는 커버 사진 선택 위젯
class CoverImagePicker extends StatelessWidget {
  final File? selectedImage;       // 새로 선택한 로컬 파일
  final String? existingImageUrl;  // 기존 네트워크 URL
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const CoverImagePicker({
    super.key,
    this.selectedImage,
    this.existingImageUrl,
    required this.onTap,
    this.onRemove,
  });

  bool get hasImage =>
      selectedImage != null || (existingImageUrl != null && existingImageUrl!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.mainLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasImage ? AppColors.main : AppColors.inactive,
                width: hasImage ? 2 : 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: _buildContent(),
            ),
          ),
        ),
        // 삭제 버튼
        if (hasImage && onRemove != null)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    // 1. 새로 선택한 로컬 파일
    if (selectedImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(selectedImage!, fit: BoxFit.cover),
          _editOverlay(),
        ],
      );
    }
    // 2. 기존 네트워크 URL
    if (existingImageUrl != null && existingImageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: existingImageUrl!,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => _placeholder(),
          ),
          _editOverlay(),
        ],
      );
    }
    // 3. 없음
    return _placeholder();
  }

  Widget _placeholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.inactive),
        SizedBox(height: 8),
        Text('커버 사진 (선택)',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _editOverlay() {
    return Container(
      color: Colors.black26,
      child: const Center(
        child: Icon(Icons.edit, color: Colors.white, size: 28),
      ),
    );
  }
}