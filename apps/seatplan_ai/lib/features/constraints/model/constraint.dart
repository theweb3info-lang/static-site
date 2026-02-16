import 'package:flutter/foundation.dart';

enum ConstraintType { mustTogether, mustApart, vipFront }

@immutable
class SeatConstraint {
  final String id;
  final ConstraintType type;
  final String guestId1;
  final String? guestId2; // null for vipFront
  final String description;

  const SeatConstraint({
    required this.id,
    required this.type,
    required this.guestId1,
    this.guestId2,
    this.description = '',
  });

  static String typeLabel(ConstraintType type) {
    switch (type) {
      case ConstraintType.mustTogether: return '必须同桌';
      case ConstraintType.mustApart: return '不能同桌';
      case ConstraintType.vipFront: return 'VIP靠前';
    }
  }

  static String typeIcon(ConstraintType type) {
    switch (type) {
      case ConstraintType.mustTogether: return '💑';
      case ConstraintType.mustApart: return '🚫';
      case ConstraintType.vipFront: return '⭐';
    }
  }
}
