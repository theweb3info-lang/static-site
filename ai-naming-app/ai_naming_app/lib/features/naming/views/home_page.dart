import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/naming_controller.dart';
import '../../../shared/themes/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NamingController>(
      init: NamingController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'AI智能取名',
              style: context.textTheme.headlineMedium,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () => _showInfoDialog(context),
                icon: const Icon(Icons.info_outline),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                _buildWelcomeCard(),
                SizedBox(height: AppSpacing.lg),
                _buildFeatureCards(),
                SizedBox(height: AppSpacing.lg),
                _buildStartButton(controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '专业AI取名',
                        style: Get.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '结合八字五行，传承文化智慧',
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                '让每个宝宝都能拥有寓意深刻、五行平衡的好名字。基于传统文化与现代AI技术的完美结合。',
                style: Get.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCards() {
    final features = [
      FeatureItem(
        icon: Icons.psychology,
        title: '八字分析',
        description: '精准计算生辰八字，分析五行强弱',
        color: AppTheme.primaryColor,
      ),
      FeatureItem(
        icon: Icons.auto_graph,
        title: '智能生成',
        description: 'AI结合传统文化，生成优质好名',
        color: AppTheme.successColor,
      ),
      FeatureItem(
        icon: Icons.star_rate,
        title: '专业评分',
        description: '多维度评分体系，科学选择好名',
        color: AppTheme.warningColor,
      ),
      FeatureItem(
        icon: Icons.library_books,
        title: '文化典故',
        description: '诗经楚辞典故，增添文化底蕴',
        color: AppTheme.infoColor,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return Card(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: feature.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Icon(
                    feature.icon,
                    color: feature.color,
                    size: 24,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  feature.title,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  feature.description,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStartButton(NamingController controller) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: () => controller.startNaming(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rocket_launch),
            SizedBox(width: AppSpacing.sm),
            Text('开始取名'),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于AI取名'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '本应用结合传统姓名学与现代AI技术：',
              style: Get.textTheme.bodyMedium,
            ),
            SizedBox(height: AppSpacing.sm),
            const Text('• 精准八字计算，真太阳时校正'),
            const Text('• 五行平衡分析，用神忌神推算'),
            const Text('• 三才五格评分，数理吉凶判断'),
            const Text('• AI智能生成，诗词典故融合'),
            SizedBox(height: AppSpacing.sm),
            Text(
              '让取名既有文化传承，又符合现代审美。',
              style: Get.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('了解了'),
          ),
        ],
      ),
    );
  }
}

class FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}