import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/theme/app_theme.dart';
import '../../capsule/service/capsule_provider.dart';
import '../../capsule/widgets/capsule_card.dart';
import '../../capsule/view/create_capsule_page.dart';
import '../../capsule/view/capsule_detail_page.dart';
import '../../capsule/model/capsule.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final capsulesAsync = ref.watch(capsuleListProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '时间胶囊',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 4),
                  const Text(
                    '写给未来自己的信 ✉️',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(3),
                dividerColor: Colors.transparent,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textTertiary,
                labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: '🔒 锁定中'),
                  Tab(text: '✨ 已解锁'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: capsulesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => Center(
                  child: Text('加载失败: $e', style: const TextStyle(color: AppColors.error)),
                ),
                data: (capsules) {
                  final locked = capsules.where((c) => !c.isUnlocked).toList();
                  final unlocked = capsules.where((c) => c.isUnlocked).toList();
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(locked, isEmpty: '还没有时间胶囊\n写一封信给未来的自己吧 ✍️'),
                      _buildList(unlocked, isEmpty: '还没有解锁的胶囊\n耐心等待吧 ⏳'),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateCapsulePage()),
          );
        },
        icon: const Icon(Icons.edit_rounded),
        label: const Text('写封信'),
      ),
    );
  }

  Widget _buildList(List<Capsule> capsules, {required String isEmpty}) {
    if (capsules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📮', style: TextStyle(fontSize: 48))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 1500.ms,
                ),
            const SizedBox(height: 16),
            Text(
              isEmpty,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textTertiary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(capsuleListProvider.notifier).loadCapsules(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 100),
        itemCount: capsules.length,
        itemBuilder: (_, i) => Dismissible(
          key: Key(capsules[i].id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('删除时间胶囊？'),
                content: const Text('这封信将永远消失，确定要删除吗？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('删除', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) {
            ref.read(capsuleListProvider.notifier).deleteCapsule(capsules[i].id);
          },
          child: CapsuleCard(
            capsule: capsules[i],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CapsuleDetailPage(capsule: capsules[i]),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
