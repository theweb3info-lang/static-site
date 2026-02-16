class ChoreTemplate {
  final String name;
  final String emoji;
  final int points;

  const ChoreTemplate({
    required this.name,
    required this.emoji,
    required this.points,
  });
}

const defaultChoreTemplates = [
  ChoreTemplate(name: '洗碗', emoji: '🍽️', points: 3),
  ChoreTemplate(name: '拖地', emoji: '🧹', points: 4),
  ChoreTemplate(name: '做饭', emoji: '🍳', points: 5),
  ChoreTemplate(name: '洗衣服', emoji: '👕', points: 4),
  ChoreTemplate(name: '倒垃圾', emoji: '🗑️', points: 2),
  ChoreTemplate(name: '擦桌子', emoji: '🧽', points: 2),
  ChoreTemplate(name: '打扫卫生间', emoji: '🚿', points: 5),
  ChoreTemplate(name: '整理房间', emoji: '🛏️', points: 3),
  ChoreTemplate(name: '买菜', emoji: '🛒', points: 4),
  ChoreTemplate(name: '遛狗', emoji: '🐕', points: 3),
  ChoreTemplate(name: '浇花', emoji: '🌱', points: 1),
  ChoreTemplate(name: '晾衣服', emoji: '👔', points: 2),
  ChoreTemplate(name: '吸尘', emoji: '🧹', points: 3),
  ChoreTemplate(name: '擦窗户', emoji: '🪟', points: 4),
  ChoreTemplate(name: '收快递', emoji: '📦', points: 1),
];
