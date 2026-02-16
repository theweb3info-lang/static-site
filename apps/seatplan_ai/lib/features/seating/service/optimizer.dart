import 'dart:math';
import '../model/seating_plan.dart';
import '../../guests/model/guest.dart';
import '../../constraints/model/constraint.dart';
import '../../settings/model/table_settings.dart';

/// Seating optimizer using simulated annealing + constraint satisfaction
class SeatingOptimizer {
  final List<Guest> guests;
  final List<SeatConstraint> constraints;
  final TableSettings settings;
  final Random _random = Random();

  SeatingOptimizer({
    required this.guests,
    required this.constraints,
    required this.settings,
  });

  /// Run optimization and return best plan
  SeatingPlan optimize() {
    if (guests.isEmpty) {
      return SeatingPlan(tables: {for (int i = 0; i < settings.tableCount; i++) i: []});
    }

    // Phase 1: Greedy initial assignment
    var plan = _greedyAssign();

    // Phase 2: Simulated annealing refinement
    plan = _simulatedAnnealing(plan);

    return plan;
  }

  /// Greedy assignment respecting hard constraints
  SeatingPlan _greedyAssign() {
    final tables = <int, List<String>>{};
    for (int i = 0; i < settings.tableCount; i++) {
      tables[i] = [];
    }

    // Sort guests: VIPs first, then by constraint count
    final sortedGuests = List<Guest>.from(guests);
    sortedGuests.sort((a, b) {
      if (a.isVip && !b.isVip) return -1;
      if (!a.isVip && b.isVip) return 1;
      return _constraintCount(b.id) - _constraintCount(a.id);
    });

    final assigned = <String>{};
    
    // First pass: assign must-together groups
    for (final c in constraints.where((c) => c.type == ConstraintType.mustTogether)) {
      if (assigned.contains(c.guestId1) || (c.guestId2 != null && assigned.contains(c.guestId2))) continue;
      
      final tableIdx = _findBestTable(tables, [c.guestId1, if (c.guestId2 != null) c.guestId2!]);
      if (tableIdx != null) {
        tables[tableIdx]!.add(c.guestId1);
        assigned.add(c.guestId1);
        if (c.guestId2 != null) {
          tables[tableIdx]!.add(c.guestId2!);
          assigned.add(c.guestId2!);
        }
      }
    }

    // Second pass: assign remaining guests
    for (final guest in sortedGuests) {
      if (assigned.contains(guest.id)) continue;
      
      int bestTable = 0;
      double bestScore = double.negativeInfinity;
      
      for (int i = 0; i < settings.tableCount; i++) {
        if (tables[i]!.length >= settings.seatsPerTable) continue;
        final score = _evaluateGuestAtTable(guest.id, i, tables);
        if (score > bestScore) {
          bestScore = score;
          bestTable = i;
        }
      }
      
      tables[bestTable]!.add(guest.id);
      assigned.add(guest.id);
    }

    final violations = _countViolations(tables);
    return SeatingPlan(
      tables: tables,
      score: _evaluateScore(tables),
      violationCount: violations,
    );
  }

  /// Simulated annealing to improve the plan
  SeatingPlan _simulatedAnnealing(SeatingPlan initial) {
    var current = initial;
    var best = initial;
    double temperature = 100.0;
    const coolingRate = 0.995;
    const iterations = 2000;

    for (int i = 0; i < iterations; i++) {
      final neighbor = _generateNeighbor(current);
      final delta = neighbor.score - current.score;

      if (delta > 0 || _random.nextDouble() < exp(delta / temperature)) {
        current = neighbor;
        if (current.score > best.score) {
          best = current;
        }
      }

      temperature *= coolingRate;
    }

    return best;
  }

  /// Generate a neighbor solution by swapping two guests
  SeatingPlan _generateNeighbor(SeatingPlan plan) {
    final tables = Map<int, List<String>>.from(
      plan.tables.map((k, v) => MapEntry(k, List<String>.from(v))),
    );

    // Pick two random non-empty tables
    final nonEmpty = tables.entries.where((e) => e.value.isNotEmpty).toList();
    if (nonEmpty.length < 2) return plan;

    final t1 = nonEmpty[_random.nextInt(nonEmpty.length)];
    var t2 = nonEmpty[_random.nextInt(nonEmpty.length)];
    while (t2.key == t1.key && nonEmpty.length > 1) {
      t2 = nonEmpty[_random.nextInt(nonEmpty.length)];
    }

    if (t1.value.isEmpty || t2.value.isEmpty) return plan;

    // Swap two random guests
    final g1idx = _random.nextInt(t1.value.length);
    final g2idx = _random.nextInt(t2.value.length);
    final g1 = t1.value[g1idx];
    final g2 = t2.value[g2idx];

    tables[t1.key]![g1idx] = g2;
    tables[t2.key]![g2idx] = g1;

    final score = _evaluateScore(tables);
    final violations = _countViolations(tables);
    return SeatingPlan(tables: tables, score: score, violationCount: violations);
  }

  double _evaluateScore(Map<int, List<String>> tables) {
    double score = 100.0;

    for (final c in constraints) {
      final t1 = _findGuestTable(c.guestId1, tables);
      final t2 = c.guestId2 != null ? _findGuestTable(c.guestId2!, tables) : null;

      switch (c.type) {
        case ConstraintType.mustTogether:
          if (t1 != null && t2 != null && t1 != t2) score -= 20;
          break;
        case ConstraintType.mustApart:
          if (t1 != null && t2 != null && t1 == t2) score -= 20;
          break;
        case ConstraintType.vipFront:
          if (t1 != null && t1 > 0) score -= (t1 * 5);
          break;
      }
    }

    // Bonus for balanced tables
    final sizes = tables.values.map((v) => v.length).toList();
    if (sizes.isNotEmpty) {
      final avg = sizes.reduce((a, b) => a + b) / sizes.length;
      for (final s in sizes) {
        score -= (s - avg).abs() * 2;
      }
    }

    // Bonus for same-tag grouping
    for (final entry in tables.entries) {
      final guestObjs = entry.value.map((id) => guests.firstWhere((g) => g.id == id, orElse: () => Guest(id: id, name: ''))).toList();
      final tagCounts = <GuestTag, int>{};
      for (final g in guestObjs) {
        tagCounts[g.tag] = (tagCounts[g.tag] ?? 0) + 1;
      }
      for (final count in tagCounts.values) {
        if (count > 1) score += count * 1.5;
      }
    }

    return score;
  }

  int _countViolations(Map<int, List<String>> tables) {
    int v = 0;
    for (final c in constraints) {
      final t1 = _findGuestTable(c.guestId1, tables);
      final t2 = c.guestId2 != null ? _findGuestTable(c.guestId2!, tables) : null;
      if (c.type == ConstraintType.mustTogether && t1 != t2) v++;
      if (c.type == ConstraintType.mustApart && t1 == t2) v++;
    }
    return v;
  }

  int? _findGuestTable(String guestId, Map<int, List<String>> tables) {
    for (final entry in tables.entries) {
      if (entry.value.contains(guestId)) return entry.key;
    }
    return null;
  }

  int _constraintCount(String guestId) {
    return constraints.where((c) => c.guestId1 == guestId || c.guestId2 == guestId).length;
  }

  int? _findBestTable(Map<int, List<String>> tables, List<String> guestIds) {
    for (int i = 0; i < settings.tableCount; i++) {
      if (tables[i]!.length + guestIds.length <= settings.seatsPerTable) return i;
    }
    return null;
  }

  double _evaluateGuestAtTable(String guestId, int tableIdx, Map<int, List<String>> tables) {
    double score = 0;
    final tableGuests = tables[tableIdx]!;

    for (final c in constraints) {
      if (c.guestId1 == guestId || c.guestId2 == guestId) {
        final otherId = c.guestId1 == guestId ? c.guestId2 : c.guestId1;
        if (c.type == ConstraintType.mustTogether && tableGuests.contains(otherId)) {
          score += 10;
        }
        if (c.type == ConstraintType.mustApart && tableGuests.contains(otherId)) {
          score -= 10;
        }
        if (c.type == ConstraintType.vipFront) {
          score -= tableIdx * 2;
        }
      }
    }

    // Prefer balanced tables
    score -= tableGuests.length.toDouble();

    return score;
  }
}
