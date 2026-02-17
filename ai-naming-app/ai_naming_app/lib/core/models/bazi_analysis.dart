class BaziAnalysis {
  final BaziData bazi;
  final Map<String, int> wuxingScores;
  final String yongshen;
  final String jishen;
  final String lunarDate;
  final String solarDate;

  BaziAnalysis({
    required this.bazi,
    required this.wuxingScores,
    required this.yongshen,
    required this.jishen,
    required this.lunarDate,
    required this.solarDate,
  });

  factory BaziAnalysis.fromJson(Map<String, dynamic> json) {
    return BaziAnalysis(
      bazi: BaziData.fromJson(json['bazi']),
      wuxingScores: Map<String, int>.from(json['wuxing_scores']),
      yongshen: json['yongshen'],
      jishen: json['jishen'],
      lunarDate: json['lunar_date'],
      solarDate: json['solar_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bazi': bazi.toJson(),
      'wuxing_scores': wuxingScores,
      'yongshen': yongshen,
      'jishen': jishen,
      'lunar_date': lunarDate,
      'solar_date': solarDate,
    };
  }
}

class BaziData {
  final String yearTiangan;
  final String yearDizhi;
  final String monthTiangan;
  final String monthDizhi;
  final String dayTiangan;
  final String dayDizhi;
  final String hourTiangan;
  final String hourDizhi;

  BaziData({
    required this.yearTiangan,
    required this.yearDizhi,
    required this.monthTiangan,
    required this.monthDizhi,
    required this.dayTiangan,
    required this.dayDizhi,
    required this.hourTiangan,
    required this.hourDizhi,
  });

  factory BaziData.fromJson(Map<String, dynamic> json) {
    return BaziData(
      yearTiangan: json['year_tiangan'],
      yearDizhi: json['year_dizhi'],
      monthTiangan: json['month_tiangan'],
      monthDizhi: json['month_dizhi'],
      dayTiangan: json['day_tiangan'],
      dayDizhi: json['day_dizhi'],
      hourTiangan: json['hour_tiangan'],
      hourDizhi: json['hour_dizhi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year_tiangan': yearTiangan,
      'year_dizhi': yearDizhi,
      'month_tiangan': monthTiangan,
      'month_dizhi': monthDizhi,
      'day_tiangan': dayTiangan,
      'day_dizhi': dayDizhi,
      'hour_tiangan': hourTiangan,
      'hour_dizhi': hourDizhi,
    };
  }

  List<BaziPillar> get pillars {
    return [
      BaziPillar(
        tiangan: yearTiangan,
        dizhi: yearDizhi,
        label: '年柱',
      ),
      BaziPillar(
        tiangan: monthTiangan,
        dizhi: monthDizhi,
        label: '月柱',
      ),
      BaziPillar(
        tiangan: dayTiangan,
        dizhi: dayDizhi,
        label: '日柱',
      ),
      BaziPillar(
        tiangan: hourTiangan,
        dizhi: hourDizhi,
        label: '时柱',
      ),
    ];
  }
}

class BaziPillar {
  final String tiangan;
  final String dizhi;
  final String label;

  BaziPillar({
    required this.tiangan,
    required this.dizhi,
    required this.label,
  });
}