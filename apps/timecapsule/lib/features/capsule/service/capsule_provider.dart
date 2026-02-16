import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../model/capsule.dart';
import 'database_service.dart';
import 'notification_service.dart';

final capsuleListProvider =
    StateNotifierProvider<CapsuleListNotifier, AsyncValue<List<Capsule>>>((ref) {
  return CapsuleListNotifier();
});

// Derived providers
final lockedCapsulesProvider = Provider<List<Capsule>>((ref) {
  final capsules = ref.watch(capsuleListProvider);
  return capsules.maybeWhen(
    data: (list) => list.where((c) => !c.isUnlocked).toList(),
    orElse: () => [],
  );
});

final unlockedCapsulesProvider = Provider<List<Capsule>>((ref) {
  final capsules = ref.watch(capsuleListProvider);
  return capsules.maybeWhen(
    data: (list) => list.where((c) => c.isUnlocked).toList(),
    orElse: () => [],
  );
});

class CapsuleListNotifier extends StateNotifier<AsyncValue<List<Capsule>>> {
  CapsuleListNotifier() : super(const AsyncValue.loading()) {
    loadCapsules();
  }

  Future<void> loadCapsules() async {
    try {
      final capsules = await DatabaseService.getAllCapsules();
      state = AsyncValue.data(capsules);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createCapsule({
    required String title,
    required String content,
    required DateTime unlockAt,
    String? mood,
  }) async {
    final capsule = Capsule(
      id: const Uuid().v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      unlockAt: unlockAt,
      mood: mood,
    );
    await DatabaseService.insertCapsule(capsule);
    await NotificationService.scheduleUnlockNotification(
      capsuleId: capsule.id,
      title: capsule.title,
      unlockAt: capsule.unlockAt,
    );
    await loadCapsules();
  }

  Future<void> openCapsule(String id) async {
    final capsules = state.valueOrNull ?? [];
    final capsule = capsules.firstWhere((c) => c.id == id);
    final updated = capsule.copyWith(isOpened: true);
    await DatabaseService.updateCapsule(updated);
    await loadCapsules();
  }

  Future<void> deleteCapsule(String id) async {
    await NotificationService.cancelNotification(id);
    await DatabaseService.deleteCapsule(id);
    await loadCapsules();
  }
}
