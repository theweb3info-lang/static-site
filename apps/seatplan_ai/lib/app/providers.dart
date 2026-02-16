import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/guests/model/guest.dart';
import '../features/constraints/model/constraint.dart';
import '../features/settings/model/table_settings.dart';
import '../features/seating/model/seating_plan.dart';
import '../features/seating/service/optimizer.dart';

// Guest list
class GuestListNotifier extends Notifier<List<Guest>> {
  @override
  List<Guest> build() => [];

  void add(Guest guest) => state = [...state, guest];

  void remove(String id) => state = state.where((g) => g.id != id).toList();

  void update(Guest guest) =>
      state = state.map((g) => g.id == guest.id ? guest : g).toList();
}

final guestListProvider =
    NotifierProvider<GuestListNotifier, List<Guest>>(GuestListNotifier.new);

// Constraints
class ConstraintListNotifier extends Notifier<List<SeatConstraint>> {
  @override
  List<SeatConstraint> build() => [];

  void add(SeatConstraint c) => state = [...state, c];

  void remove(String id) => state = state.where((c) => c.id != id).toList();
}

final constraintListProvider =
    NotifierProvider<ConstraintListNotifier, List<SeatConstraint>>(
        ConstraintListNotifier.new);

// Table settings
class TableSettingsNotifier extends Notifier<TableSettings> {
  @override
  TableSettings build() => const TableSettings();

  void update(TableSettings s) => state = s;
}

final tableSettingsProvider =
    NotifierProvider<TableSettingsNotifier, TableSettings>(
        TableSettingsNotifier.new);

// Seating plan
class SeatingPlanNotifier extends Notifier<SeatingPlan?> {
  @override
  SeatingPlan? build() => null;
  void set(SeatingPlan? plan) => state = plan;
}

final seatingPlanProvider = NotifierProvider<SeatingPlanNotifier, SeatingPlan?>(SeatingPlanNotifier.new);

// Optimize action
final optimizeProvider = Provider<SeatingPlan Function()>((ref) {
  return () {
    final guests = ref.read(guestListProvider);
    final constraints = ref.read(constraintListProvider);
    final settings = ref.read(tableSettingsProvider);

    final optimizer = SeatingOptimizer(
      guests: guests,
      constraints: constraints,
      settings: settings,
    );

    final plan = optimizer.optimize();
    ref.read(seatingPlanProvider.notifier).set(plan);
    return plan;
  };
});
