import 'package:flutter/foundation.dart';

enum GuestTag { family, friend, colleague, vip, child, other }

@immutable
class Guest {
  final String id;
  final String name;
  final GuestTag tag;
  final bool isVip;

  const Guest({
    required this.id,
    required this.name,
    this.tag = GuestTag.other,
    this.isVip = false,
  });

  Guest copyWith({String? name, GuestTag? tag, bool? isVip}) => Guest(
    id: id,
    name: name ?? this.name,
    tag: tag ?? this.tag,
    isVip: isVip ?? this.isVip,
  );

  static String tagLabel(GuestTag tag) {
    switch (tag) {
      case GuestTag.family: return '家人';
      case GuestTag.friend: return '朋友';
      case GuestTag.colleague: return '同事';
      case GuestTag.vip: return 'VIP';
      case GuestTag.child: return '小孩';
      case GuestTag.other: return '其他';
    }
  }
}
