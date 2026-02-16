import 'dart:math';
import 'package:flutter/material.dart';
import '../../guests/model/guest.dart';
import '../../../shared/theme/app_theme.dart';

class TableLayout {
  final int tableIndex;
  final Offset center;
  final double radius;
  final List<SeatPosition> seats;

  const TableLayout({
    required this.tableIndex,
    required this.center,
    required this.radius,
    required this.seats,
  });
}

class SeatPosition {
  final String? guestId;
  final String? guestName;
  final bool isVip;
  final Offset position;
  final int tableIndex;
  final int seatIndex;

  const SeatPosition({
    this.guestId,
    this.guestName,
    this.isVip = false,
    required this.position,
    required this.tableIndex,
    required this.seatIndex,
  });
}

class SeatingChartPainter extends CustomPainter {
  final List<TableLayout> tables;
  final String? highlightGuestId;
  final int? highlightTableIndex;

  SeatingChartPainter({
    required this.tables,
    this.highlightGuestId,
    this.highlightTableIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final table in tables) {
      _drawTable(canvas, table);
    }
  }

  void _drawTable(Canvas canvas, TableLayout table) {
    final isHighlighted = highlightTableIndex == table.tableIndex;

    // Table circle (tablecloth effect)
    final tablePaint = Paint()
      ..color = isHighlighted
          ? AppColors.primary.withValues(alpha: 0.15)
          : const Color(0xFFF5EDE8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(table.center, table.radius, tablePaint);

    // Table border
    final borderPaint = Paint()
      ..color = isHighlighted ? AppColors.primary : AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHighlighted ? 2.5 : 1.5;
    canvas.drawCircle(table.center, table.radius, borderPaint);

    // Table number
    final textPainter = TextPainter(
      text: TextSpan(
        text: '桌${table.tableIndex + 1}',
        style: TextStyle(
          color: isHighlighted ? AppColors.primary : AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      table.center - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // Draw seats
    for (final seat in table.seats) {
      _drawSeat(canvas, seat);
    }
  }

  void _drawSeat(Canvas canvas, SeatPosition seat) {
    const seatRadius = 18.0;
    final isOccupied = seat.guestId != null;
    final isHighlighted = seat.guestId == highlightGuestId;

    // Seat circle
    final seatPaint = Paint()
      ..color = isHighlighted
          ? AppColors.primary
          : isOccupied
              ? (seat.isVip ? AppColors.accent : AppColors.primary.withValues(alpha: 0.8))
              : AppColors.border.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(seat.position, seatRadius, seatPaint);

    // Seat border
    if (isHighlighted) {
      final glowPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(seat.position, seatRadius + 3, glowPaint);
    }

    // Guest initial
    if (isOccupied && seat.guestName != null) {
      final initial = seat.guestName!.isNotEmpty ? seat.guestName![0] : '?';
      final tp = TextPainter(
        text: TextSpan(
          text: initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, seat.position - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant SeatingChartPainter oldDelegate) => true;
}

/// Calculate table layouts for a given size
List<TableLayout> calculateTableLayouts({
  required Size size,
  required int tableCount,
  required int seatsPerTable,
  required Map<int, List<String>> tableAssignments,
  required List<Guest> guests,
}) {
  final layouts = <TableLayout>[];
  if (tableCount == 0) return layouts;

  // Grid layout
  final cols = (sqrt(tableCount)).ceil();
  final rows = (tableCount / cols).ceil();
  final cellW = size.width / cols;
  final cellH = size.height / rows;
  final tableRadius = min(cellW, cellH) * 0.25;

  for (int i = 0; i < tableCount; i++) {
    final col = i % cols;
    final row = i ~/ cols;
    final center = Offset(
      cellW * col + cellW / 2,
      cellH * row + cellH / 2,
    );

    final guestIds = tableAssignments[i] ?? [];
    final seats = <SeatPosition>[];
    final seatRadius = tableRadius + 28;

    for (int s = 0; s < seatsPerTable; s++) {
      final angle = 2 * pi * s / seatsPerTable - pi / 2;
      final seatPos = Offset(
        center.dx + seatRadius * cos(angle),
        center.dy + seatRadius * sin(angle),
      );

      String? guestId;
      String? guestName;
      bool isVip = false;
      if (s < guestIds.length) {
        guestId = guestIds[s];
        final guest = guests.where((g) => g.id == guestId).firstOrNull;
        guestName = guest?.name;
        isVip = guest?.isVip ?? false;
      }

      seats.add(SeatPosition(
        guestId: guestId,
        guestName: guestName,
        isVip: isVip,
        position: seatPos,
        tableIndex: i,
        seatIndex: s,
      ));
    }

    layouts.add(TableLayout(
      tableIndex: i,
      center: center,
      radius: tableRadius,
      seats: seats,
    ));
  }

  return layouts;
}
