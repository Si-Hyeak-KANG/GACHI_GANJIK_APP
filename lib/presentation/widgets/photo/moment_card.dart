import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_pages.dart';
import '../../../domain/entities/moment.dart';
import '../../../domain/entities/album.dart';
import '../common/smart_image.dart';

class MomentCard extends StatelessWidget {
  final Moment moment;
  final Album album;

  const MomentCard({
    super.key,
    required this.moment,
    required this.album,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      moment.date.replaceAll('-', '.'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${moment.contributors.join(", ")} 님이 남긴 순간',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mainLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${moment.photos.length}장',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.main,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 사진 그리드 (3열, 최대 6개)
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 2),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: 1,
              ),
              itemCount: moment.photos.length > 6 ? 6 : moment.photos.length,
              itemBuilder: (context, index) {
                final photo = moment.photos[index];
                final isLast = index == 5 && moment.photos.length > 6;
                final heroTag = 'photo_hero_${photo.id}';

                return GestureDetector(
                  onTap: () => Get.toNamed(
                    Routes.photoDetail,
                    arguments: {
                      'photos': moment.photos,
                      'initialIndex': index,
                      'album': album,
                    },
                  ),
                  child: Hero(
                    tag: heroTag,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: index == moment.photos.length - 3 ||
                            (moment.photos.length < 3 && index == 0)
                            ? const Radius.circular(18)
                            : Radius.zero,
                        bottomRight: index == moment.photos.length - 1 ||
                            (isLast && moment.photos.length == 6)
                            ? const Radius.circular(18)
                            : Radius.zero,
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          SmartImage(imageUrl: photo.imageUrl),
                          if (isLast)
                            Container(
                              color: Colors.black54,
                              child: Center(
                                child: Text(
                                  '+${moment.photos.length - 6}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}