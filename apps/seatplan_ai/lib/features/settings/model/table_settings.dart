import 'package:flutter/foundation.dart';

@immutable
class TableSettings {
  final int tableCount;
  final int seatsPerTable;

  const TableSettings({this.tableCount = 5, this.seatsPerTable = 10});

  TableSettings copyWith({int? tableCount, int? seatsPerTable}) => TableSettings(
    tableCount: tableCount ?? this.tableCount,
    seatsPerTable: seatsPerTable ?? this.seatsPerTable,
  );

  int get totalSeats => tableCount * seatsPerTable;
}
