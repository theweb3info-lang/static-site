import 'package:flutter/foundation.dart';

/// A table assignment: tableIndex -> list of guestIds
@immutable
class SeatingPlan {
  final Map<int, List<String>> tables; // tableIndex -> guestIds
  final double score;
  final int violationCount;

  const SeatingPlan({
    required this.tables,
    this.score = 0,
    this.violationCount = 0,
  });

  SeatingPlan copyWith({Map<int, List<String>>? tables, double? score, int? violationCount}) =>
      SeatingPlan(
        tables: tables ?? this.tables,
        score: score ?? this.score,
        violationCount: violationCount ?? this.violationCount,
      );

  /// Move a guest from one table to another
  SeatingPlan moveGuest(String guestId, int fromTable, int toTable) {
    final newTables = Map<int, List<String>>.from(
      tables.map((k, v) => MapEntry(k, List<String>.from(v))),
    );
    newTables[fromTable]?.remove(guestId);
    newTables.putIfAbsent(toTable, () => []);
    newTables[toTable]!.add(guestId);
    return SeatingPlan(tables: newTables, score: score, violationCount: violationCount);
  }
}
