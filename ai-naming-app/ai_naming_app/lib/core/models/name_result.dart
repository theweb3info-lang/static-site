class NameResult {
  final String name;
  final String surname;
  final String givenName;
  final NameScores scores;
  final WugeDetail wugeDetail;
  final String analysis;
  final String? culturalReference;
  final String? poetrySource;

  NameResult({
    required this.name,
    required this.surname,
    required this.givenName,
    required this.scores,
    required this.wugeDetail,
    required this.analysis,
    this.culturalReference,
    this.poetrySource,
  });

  factory NameResult.fromJson(Map<String, dynamic> json) {
    return NameResult(
      name: json['name'],
      surname: json['surname'],
      givenName: json['given_name'],
      scores: NameScores.fromJson(json['scores']),
      wugeDetail: WugeDetail.fromJson(json['wuge_detail']),
      analysis: json['analysis'],
      culturalReference: json['cultural_reference'],
      poetrySource: json['poetry_source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'surname': surname,
      'given_name': givenName,
      'scores': scores.toJson(),
      'wuge_detail': wugeDetail.toJson(),
      'analysis': analysis,
      'cultural_reference': culturalReference,
      'poetry_source': poetrySource,
    };
  }

  /// 获取评级文字
  String get gradeText {
    final score = scores.total;
    if (score >= 95) return '极佳';
    if (score >= 85) return '优秀';
    if (score >= 75) return '良好';
    if (score >= 65) return '一般';
    return '需改进';
  }

  /// 获取评级颜色
  Color get gradeColor {
    final score = scores.total;
    if (score >= 95) return const Color(0xFF4CAF50);
    if (score >= 85) return const Color(0xFF8BC34A);
    if (score >= 75) return const Color(0xFFFFC107);
    if (score >= 65) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }
}

class NameScores {
  final double wuxing;
  final double wuge;
  final double meaning;
  final double phonetic;
  final double culture;
  final double total;

  NameScores({
    required this.wuxing,
    required this.wuge,
    required this.meaning,
    required this.phonetic,
    required this.culture,
    required this.total,
  });

  factory NameScores.fromJson(Map<String, dynamic> json) {
    return NameScores(
      wuxing: (json['wuxing'] as num).toDouble(),
      wuge: (json['wuge'] as num).toDouble(),
      meaning: (json['meaning'] as num).toDouble(),
      phonetic: (json['phonetic'] as num).toDouble(),
      culture: (json['culture'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wuxing': wuxing,
      'wuge': wuge,
      'meaning': meaning,
      'phonetic': phonetic,
      'culture': culture,
      'total': total,
    };
  }

  List<ScoreItem> get scoreItems {
    return [
      ScoreItem('五行匹配', wuxing, '与八字五行的匹配程度'),
      ScoreItem('三才五格', wuge, '姓名学数理的吉凶程度'),
      ScoreItem('字义内涵', meaning, '名字寓意的积极程度'),
      ScoreItem('音韵和谐', phonetic, '读音的流畅和谐程度'),
      ScoreItem('文化底蕴', culture, '诗词典故的文化内涵'),
    ];
  }
}

class ScoreItem {
  final String name;
  final double score;
  final String description;

  ScoreItem(this.name, this.score, this.description);

  Color get color {
    if (score >= 90) return const Color(0xFF4CAF50);
    if (score >= 80) return const Color(0xFF8BC34A);
    if (score >= 70) return const Color(0xFFFFC107);
    if (score >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }
}

class WugeDetail {
  final Map<String, int> wuge;
  final SancaiConfig sancai;
  final Map<String, LuckAnalysis> luckAnalysis;
  final double totalScore;

  WugeDetail({
    required this.wuge,
    required this.sancai,
    required this.luckAnalysis,
    required this.totalScore,
  });

  factory WugeDetail.fromJson(Map<String, dynamic> json) {
    return WugeDetail(
      wuge: Map<String, int>.from(json['wuge']),
      sancai: SancaiConfig.fromJson(json['sancai']),
      luckAnalysis: (json['luck_analysis'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, LuckAnalysis.fromJson(value))),
      totalScore: (json['total_score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wuge': wuge,
      'sancai': sancai.toJson(),
      'luck_analysis': luckAnalysis.map((key, value) => MapEntry(key, value.toJson())),
      'total_score': totalScore,
    };
  }

  int get tiange => wuge['tiange'] ?? 0;
  int get renge => wuge['renge'] ?? 0;
  int get dige => wuge['dige'] ?? 0;
  int get waige => wuge['waige'] ?? 0;
  int get zongge => wuge['zongge'] ?? 0;
}

class SancaiConfig {
  final String config;
  final String tiangeWuxing;
  final String rengeWuxing;
  final String digeWuxing;
  final String analysis;

  SancaiConfig({
    required this.config,
    required this.tiangeWuxing,
    required this.rengeWuxing,
    required this.digeWuxing,
    required this.analysis,
  });

  factory SancaiConfig.fromJson(Map<String, dynamic> json) {
    return SancaiConfig(
      config: json['config'],
      tiangeWuxing: json['tiange_wuxing'],
      rengeWuxing: json['renge_wuxing'],
      digeWuxing: json['dige_wuxing'],
      analysis: json['analysis'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'config': config,
      'tiange_wuxing': tiangeWuxing,
      'renge_wuxing': rengeWuxing,
      'dige_wuxing': digeWuxing,
      'analysis': analysis,
    };
  }
}

class LuckAnalysis {
  final String luck;
  final String description;

  LuckAnalysis({
    required this.luck,
    required this.description,
  });

  factory LuckAnalysis.fromJson(Map<String, dynamic> json) {
    return LuckAnalysis(
      luck: json['luck'],
      description: json['desc'] ?? json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'luck': luck,
      'description': description,
    };
  }

  Color get color {
    switch (luck) {
      case '大吉':
        return const Color(0xFF4CAF50);
      case '中吉':
      case '吉':
        return const Color(0xFF8BC34A);
      case '平':
        return const Color(0xFFFFC107);
      case '凶':
        return const Color(0xFFFF9800);
      case '大凶':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}