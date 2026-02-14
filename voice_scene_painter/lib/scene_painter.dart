import 'package:flutter/material.dart';
import 'dart:math';

/// A visual element in the scene
class SceneElement {
  final String ascii;
  final Color color;
  final Offset position; // 0.0-1.0 relative
  final double scale;

  const SceneElement({
    required this.ascii,
    required this.color,
    required this.position,
    this.scale = 1.0,
  });
}

/// Parses Chinese text into ASCII art scene elements
class SceneParser {
  static final _rng = Random(42);

  static List<SceneElement> parse(String text) {
    final elements = <SceneElement>[];
    final t = text.toLowerCase();

    // Sky / Weather
    if (t.contains('晴') || t.contains('阳光') || t.contains('太阳')) {
      elements.add(const SceneElement(
        ascii: r'''
    \   |   /
     .---.
    /     \
   |  ☀️   |
    \     /
     '---'
    /   |   \
''',
        color: Colors.yellow,
        position: Offset(0.7, 0.02),
      ));
    }

    if (t.contains('云') || t.contains('多云')) {
      elements.add(const SceneElement(
        ascii: '''
    .--~~--.
   /        \\
  |  ~~~~    |
   \\      __/
    '--~~--'
''',
        color: Colors.white70,
        position: Offset(0.3, 0.05),
      ));
    }

    if (t.contains('雨') || t.contains('下雨')) {
      elements.add(const SceneElement(
        ascii: '''
     .--~~--.
    /  ~~~~  \\
    '--------'
    /  /  /  /
   /  /  /  /
''',
        color: Colors.blueGrey,
        position: Offset(0.4, 0.05),
      ));
    }

    if (t.contains('雪')) {
      elements.add(const SceneElement(
        ascii: '''
   *  .  *  .
  .  *  .  *
   *  .  *  .
  .  *  .  *
''',
        color: Colors.white,
        position: Offset(0.3, 0.15),
      ));
    }

    if (t.contains('月') || t.contains('晚上') || t.contains('夜')) {
      elements.add(const SceneElement(
        ascii: '''
      _.._
    .'    '.
   /   🌙   \\
   \\       /
    '._ _.'
''',
        color: Colors.amber,
        position: Offset(0.75, 0.02),
      ));
    }

    if (t.contains('星') || t.contains('星星')) {
      elements.add(const SceneElement(
        ascii: '''
  ✦     ★   ✦
     ✦    ★
  ★    ✦     ★
''',
        color: Colors.yellowAccent,
        position: Offset(0.2, 0.02),
      ));
    }

    // Nature
    if (t.contains('树') || t.contains('森林') || t.contains('公园')) {
      elements.add(const SceneElement(
        ascii: '''
     🌿
    /|\\
   / | \\
  /  |  \\
     |
    /|\\
''',
        color: Colors.green,
        position: Offset(0.1, 0.35),
      ));
      elements.add(const SceneElement(
        ascii: '''
    🌳
   /|\\
  / | \\
 /  |  \\
    |
   /|\\
''',
        color: Colors.lightGreen,
        position: Offset(0.85, 0.33),
      ));
    }

    if (t.contains('花') || t.contains('花园')) {
      elements.add(const SceneElement(
        ascii: '''
  🌸 🌺 🌼
  .|. .|. .|.
  .|. .|. .|.
''',
        color: Colors.pinkAccent,
        position: Offset(0.4, 0.72),
      ));
    }

    if (t.contains('草') || t.contains('草地') || t.contains('公园')) {
      elements.add(const SceneElement(
        ascii: '''
~^~v~^~v~^~v~^~v~^~v~^~v~^~v~^~
 v~^~v~^~v~^~v~^~v~^~v~^~v~^~v~
''',
        color: Colors.green,
        position: Offset(0.0, 0.82),
      ));
    }

    if (t.contains('山') || t.contains('山脉')) {
      elements.add(const SceneElement(
        ascii: r'''
        /\
       /  \    /\
      /    \  /  \
     /      \/    \
    /              \
   /________________\
''',
        color: Colors.brown,
        position: Offset(0.2, 0.4),
      ));
    }

    if (t.contains('河') || t.contains('水') || t.contains('湖')) {
      elements.add(const SceneElement(
        ascii: '''
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ~  ~  ~  ~  ~  ~  ~  ~  ~  ~ ~
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
''',
        color: Colors.lightBlue,
        position: Offset(0.0, 0.75),
      ));
    }

    // People
    if (t.contains('小朋友') || t.contains('孩子') || t.contains('小孩')) {
      final count = _extractCount(t, ['小朋友', '孩子', '小孩']);
      for (var i = 0; i < count; i++) {
        elements.add(SceneElement(
          ascii: '''
  O
 /|\\
 / \\
''',
          color: [
            Colors.cyan,
            Colors.orange,
            Colors.pink,
            Colors.purple
          ][i % 4],
          position: Offset(0.2 + i * 0.15, 0.58),
          scale: 0.9,
        ));
      }
    }

    if (t.contains('人') && !t.contains('小朋友') && !t.contains('孩子')) {
      elements.add(const SceneElement(
        ascii: '''
   O
  /|\\
  / \\
''',
        color: Colors.white,
        position: Offset(0.5, 0.55),
      ));
    }

    // Animals
    if (t.contains('狗') || t.contains('小狗')) {
      elements.add(const SceneElement(
        ascii: r'''
  / \__
 (    @\___
 /          O
/    (_____/
/_____/  U
''',
        color: Colors.brown,
        position: Offset(0.6, 0.62),
      ));
    }

    if (t.contains('猫') || t.contains('小猫')) {
      elements.add(const SceneElement(
        ascii: r'''
  /\_/\
 ( o.o )
  > ^ <
 /|   |\
(_|   |_)
''',
        color: Colors.orange,
        position: Offset(0.65, 0.6),
      ));
    }

    if (t.contains('鸟') || t.contains('小鸟')) {
      elements.add(const SceneElement(
        ascii: '''
   ___
  ('v')
  (( ))
   ^^
''',
        color: Colors.lightBlue,
        position: Offset(0.5, 0.15),
      ));
    }

    // Buildings
    if (t.contains('房子') || t.contains('房屋') || t.contains('家')) {
      elements.add(const SceneElement(
        ascii: r'''
      /\
     /  \
    /    \
   /______\
   |  __  |
   | |  | |
   |_|__|_|
''',
        color: Colors.amber,
        position: Offset(0.6, 0.35),
      ));
    }

    if (t.contains('城市') || t.contains('大楼') || t.contains('建筑')) {
      elements.add(const SceneElement(
        ascii: '''
   ___ _____
  |   |     |___
  | □ | □□□ |   |
  | □ | □□□ | □ |
  | □ | □□□ | □ |
  |___|_____|___|
''',
        color: Colors.blueGrey,
        position: Offset(0.3, 0.35),
      ));
    }

    // Playground items
    if (t.contains('秋千') || t.contains('滑梯') || t.contains('游乐')) {
      elements.add(const SceneElement(
        ascii: r'''
   ___________
  ||         ||
  || O     O ||
  ||/|\   /|\||
  ||/ \   / \||
''',
        color: Colors.deepOrange,
        position: Offset(0.35, 0.5),
      ));
    }

    // Vehicles
    if (t.contains('车') || t.contains('汽车')) {
      elements.add(const SceneElement(
        ascii: r'''
    ______
   /|_||_\`.__
  (   _    _ _\
  =`-(_)--(_)-'
''',
        color: Colors.red,
        position: Offset(0.05, 0.68),
      ));
    }

    if (t.contains('船') || t.contains('小船')) {
      elements.add(const SceneElement(
        ascii: r'''
       |
      /|\
     / | \
  ~~~\___/~~~
''',
        color: Colors.white,
        position: Offset(0.4, 0.6),
      ));
    }

    return elements;
  }

  static int _extractCount(String text, List<String> keywords) {
    // Look for number words before keywords
    final numMap = {
      '一': 1, '两': 2, '二': 2, '三': 3, '四': 4, '五': 5,
      '六': 6, '七': 7, '八': 8, '九': 9, '十': 10,
      '很多': 4, '好多': 4, '几个': 3, '一些': 3, '许多': 4,
    };

    for (final kw in keywords) {
      final idx = text.indexOf(kw);
      if (idx > 0) {
        final before = text.substring(max(0, idx - 3), idx);
        for (final entry in numMap.entries) {
          if (before.contains(entry.key)) return min(entry.value, 5);
        }
      }
    }
    return 2; // default
  }
}

/// Widget to render ASCII scene
class AsciiSceneCanvas extends StatelessWidget {
  final List<SceneElement> elements;

  const AsciiSceneCanvas({super.key, required this.elements});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: elements.map((e) {
            return Positioned(
              left: e.position.dx * constraints.maxWidth,
              top: e.position.dy * constraints.maxHeight,
              child: Text(
                e.ascii,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12 * e.scale,
                  color: e.color,
                  height: 1.1,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
