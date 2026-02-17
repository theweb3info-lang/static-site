import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get/get.dart';

import '../controllers/naming_controller.dart';
import '../../../shared/themes/app_theme.dart';

class NamingInputPage extends StatelessWidget {
  const NamingInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NamingController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('输入信息'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepIndicator(controller.currentStep.value),
                SizedBox(height: AppSpacing.lg),
                
                if (controller.currentStep.value == 1) ...[
                  _buildInputForm(controller),
                ] else if (controller.currentStep.value == 2) ...[
                  _buildBaziResult(controller),
                ] else if (controller.currentStep.value == 3) ...[
                  _buildNameResults(controller),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    return Row(
      children: [
        _buildStepItem(1, '输入信息', currentStep >= 1),
        Expanded(
          child: Container(
            height: 2,
            color: currentStep >= 2 ? AppTheme.primaryColor : Colors.grey[300],
          ),
        ),
        _buildStepItem(2, '八字分析', currentStep >= 2),
        Expanded(
          child: Container(
            height: 2,
            color: currentStep >= 3 ? AppTheme.primaryColor : Colors.grey[300],
          ),
        ),
        _buildStepItem(3, '名字推荐', currentStep >= 3),
      ],
    );
  }

  Widget _buildStepItem(int step, String title, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: isActive ? AppTheme.primaryColor : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildInputForm(NamingController controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '宝宝基本信息',
              style: Get.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            
            // 姓氏输入
            TextFormField(
              onChanged: (value) => controller.surname.value = value,
              decoration: const InputDecoration(
                labelText: '姓氏 *',
                hintText: '请输入宝宝姓氏',
                prefixIcon: Icon(Icons.person_outline),
              ),
              maxLength: 2,
            ),
            
            SizedBox(height: AppSpacing.md),
            
            // 性别选择
            Text('性别 *', style: Get.textTheme.titleMedium),
            SizedBox(height: AppSpacing.sm),
            Obx(() => Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.gender.value = '男',
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: controller.gender.value == '男'
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : Colors.grey[100],
                        border: Border.all(
                          color: controller.gender.value == '男'
                              ? AppTheme.primaryColor
                              : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.male,
                            color: controller.gender.value == '男'
                                ? AppTheme.primaryColor
                                : Colors.grey[600],
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            '男孩',
                            style: TextStyle(
                              color: controller.gender.value == '男'
                                  ? AppTheme.primaryColor
                                  : Colors.grey[600],
                              fontWeight: controller.gender.value == '男'
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.gender.value = '女',
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: controller.gender.value == '女'
                            ? Colors.pink.withOpacity(0.1)
                            : Colors.grey[100],
                        border: Border.all(
                          color: controller.gender.value == '女'
                              ? Colors.pink
                              : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.female,
                            color: controller.gender.value == '女'
                                ? Colors.pink
                                : Colors.grey[600],
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            '女孩',
                            style: TextStyle(
                              color: controller.gender.value == '女'
                                  ? Colors.pink
                                  : Colors.grey[600],
                              fontWeight: controller.gender.value == '女'
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
            
            SizedBox(height: AppSpacing.lg),
            
            // 出生日期
            Text('出生日期 *', style: Get.textTheme.titleMedium),
            SizedBox(height: AppSpacing.sm),
            Obx(() => GestureDetector(
              onTap: () {
                DatePicker.showDatePicker(
                  Get.context!,
                  showTitleActions: true,
                  minTime: DateTime(1900, 1, 1),
                  maxTime: DateTime.now(),
                  currentTime: controller.birthDate.value,
                  locale: LocaleType.zh,
                  onConfirm: (date) {
                    controller.birthDate.value = date;
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      '${controller.birthDate.value.year}年${controller.birthDate.value.month}月${controller.birthDate.value.day}日',
                      style: Get.textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            )),
            
            SizedBox(height: AppSpacing.lg),
            
            // 出生时辰
            Text('出生时辰 *', style: Get.textTheme.titleMedium),
            SizedBox(height: AppSpacing.sm),
            Obx(() => DropdownButtonFormField<int>(
              value: controller.birthHour.value,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.access_time),
              ),
              items: controller.hourOptions.map((option) {
                return DropdownMenuItem<int>(
                  value: option['value'],
                  child: Text(option['text']),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.birthHour.value = value;
                }
              },
            )),
            
            SizedBox(height: AppSpacing.xl),
            
            // 开始分析按钮
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.calculateBazi(),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('开始八字分析'),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBaziResult(NamingController controller) {
    if (controller.baziAnalysis.value == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final bazi = controller.baziAnalysis.value!;
    
    return Column(
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '八字分析结果',
                  style: Get.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                
                // 八字排盘
                Text('生辰八字', style: Get.textTheme.titleMedium),
                SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: bazi.bazi.pillars.map((pillar) {
                    return Column(
                      children: [
                        Text(pillar.tiangan, style: Get.textTheme.headlineSmall),
                        Text(pillar.dizhi, style: Get.textTheme.headlineSmall),
                        Text(pillar.label, style: Get.textTheme.bodySmall),
                      ],
                    );
                  }).toList(),
                ),
                
                SizedBox(height: AppSpacing.lg),
                
                // 五行分布
                Text('五行分布', style: Get.textTheme.titleMedium),
                SizedBox(height: AppSpacing.sm),
                ...bazi.wuxingScores.entries.map((entry) {
                  final percentage = entry.value / bazi.wuxingScores.values.reduce((a, b) => a + b);
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      children: [
                        SizedBox(width: 30, child: Text(entry.key)),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getWuxingColor(entry.key),
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text('${(percentage * 100).toInt()}%'),
                      ],
                    ),
                  );
                }),
                
                SizedBox(height: AppSpacing.lg),
                
                // 用神忌神
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text('用神', style: Get.textTheme.titleSmall),
                                Text(
                                  bazi.yongshen,
                                  style: Get.textTheme.headlineSmall?.copyWith(
                                    color: AppTheme.successColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text('忌神', style: Get.textTheme.titleSmall),
                                Text(
                                  bazi.jishen,
                                  style: Get.textTheme.headlineSmall?.copyWith(
                                    color: AppTheme.errorColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        '建议补${bazi.yongshen}，避${bazi.jishen}',
                        style: Get.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: AppSpacing.lg),
        
        // 继续按钮
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: () => controller.generateFreeNames(),
            child: const Text('生成推荐名字'),
          ),
        ),
      ],
    );
  }

  Widget _buildNameResults(NamingController controller) {
    return Column(
      children: [
        Text(
          '名字推荐',
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        
        if (controller.nameResults.isEmpty)
          const Center(child: CircularProgressIndicator())
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.nameResults.length,
            itemBuilder: (context, index) {
              final name = controller.nameResults[index];
              return Card(
                margin: EdgeInsets.only(bottom: AppSpacing.md),
                child: ListTile(
                  title: Text(
                    name.name,
                    style: Get.textTheme.titleLarge,
                  ),
                  subtitle: Text('综合评分：${name.scores.total.toInt()}分'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => controller.toggleFavorite(name),
                        icon: Icon(
                          controller.isFavorite(name) 
                              ? Icons.favorite 
                              : Icons.favorite_border,
                          color: controller.isFavorite(name) 
                              ? Colors.red 
                              : null,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                  onTap: () {
                    // TODO: 跳转到名字详情页
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Color _getWuxingColor(String wuxing) {
    switch (wuxing) {
      case '木':
        return Colors.green;
      case '火':
        return Colors.red;
      case '土':
        return Colors.brown;
      case '金':
        return Colors.orange;
      case '水':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}