# AI取名App技术架构方案 (TECH)

## 整体架构设计

```
┌─────────────────┐    ┌─────────────────┐
│  Flutter App    │    │  微信小程序      │
│  (iOS/Android)  │    │  (WeChat Mini)  │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          └──────────┬───────────┘
                     │ HTTPS API
         ┌───────────▼────────────┐
         │     FastAPI Backend    │
         │    (Python 3.11+)     │
         └───────────┬────────────┘
                     │
    ┌────────────────┼────────────────┐
    │                │                │
┌───▼──┐    ┌─────▼─────┐    ┌─────▼─────┐
│ MySQL│    │   Redis   │    │  Claude   │
│  DB  │    │   Cache   │    │  API AI   │
└──────┘    └───────────┘    └───────────┘
```

---

## 1. 八字计算模块

### 核心算法库选择

#### 推荐方案：`lunar-python` + 自研校验
```bash
# GitHub Star: 1.2k+, 维护活跃
pip install lunar-python
```

**优势**：
- 支持公历农历互转
- 天干地支计算准确
- 二十四节气精确
- 文档完整，社区活跃

**备选方案**：`zhdate` + `bazi-calculator`
```bash
pip install zhdate
# 自研八字计算逻辑
```

### 核心实现代码

```python
from lunar_python import Lunar, Solar
from datetime import datetime, timezone
from typing import Dict, List, Tuple

class BaziCalculator:
    """八字计算核心类"""
    
    # 天干地支五行对应表
    TIANGAN_WUXING = {
        '甲': '木', '乙': '木', '丙': '火', '丁': '火',
        '戊': '土', '己': '土', '庚': '金', '辛': '金',
        '壬': '水', '癸': '水'
    }
    
    DIZHI_WUXING = {
        '子': '水', '丑': '土', '寅': '木', '卯': '木',
        '辰': '土', '巳': '火', '午': '火', '未': '土',
        '申': '金', '酉': '金', '戌': '土', '亥': '水'
    }
    
    def __init__(self):
        self.wuxing_score = {'木': 0, '火': 0, '土': 0, '金': 0, '水': 0}
    
    def calculate_bazi(self, year: int, month: int, day: int, 
                      hour: int, longitude: float = 116.4074) -> Dict:
        """
        计算八字
        :param longitude: 经度，用于真太阳时校正
        """
        try:
            # 创建Solar对象（公历）
            solar = Solar.fromYmdHms(year, month, day, hour, 0, 0)
            
            # 真太阳时校正
            true_solar_hour = self._adjust_true_solar_time(hour, longitude)
            solar_adjusted = Solar.fromYmdHms(year, month, day, true_solar_hour, 0, 0)
            
            # 转换为农历
            lunar = solar_adjusted.getLunar()
            
            # 获取八字
            bazi_data = {
                'year_tiangan': lunar.getYearGan(),
                'year_dizhi': lunar.getYearZhi(),
                'month_tiangan': lunar.getMonthGan(),
                'month_dizhi': lunar.getMonthZhi(),
                'day_tiangan': lunar.getDayGan(),
                'day_dizhi': lunar.getDayZhi(),
                'hour_tiangan': lunar.getTimeGan(),
                'hour_dizhi': lunar.getTimeZhi(),
            }
            
            # 计算五行得分
            wuxing_analysis = self._analyze_wuxing(bazi_data)
            
            # 确定用神忌神
            yongshen_analysis = self._determine_yongshen(wuxing_analysis)
            
            return {
                'bazi': bazi_data,
                'wuxing_scores': wuxing_analysis,
                'yongshen': yongshen_analysis['yongshen'],
                'jishen': yongshen_analysis['jishen'],
                'lunar_date': f"{lunar.getYearInChinese()}年{lunar.getMonthInChinese()}月{lunar.getDayInChinese()}日",
                'solar_date': f"{year}年{month}月{day}日{hour}时"
            }
            
        except Exception as e:
            raise ValueError(f"八字计算错误: {str(e)}")
    
    def _adjust_true_solar_time(self, hour: int, longitude: float) -> int:
        """真太阳时校正"""
        # 简化版真太阳时计算
        # 实际应用中需要考虑时差方程等因素
        time_offset = (longitude - 120) / 15  # 以东八区为基准
        adjusted_hour = hour + time_offset
        return int(adjusted_hour) % 24
    
    def _analyze_wuxing(self, bazi_data: Dict) -> Dict:
        """分析五行得分"""
        scores = {'木': 0, '火': 0, '土': 0, '金': 0, '水': 0}
        
        # 天干得分（权重较高）
        tiangan_weight = {
            'year': 3, 'month': 4, 'day': 5, 'hour': 2
        }
        
        # 地支得分（权重较低）
        dizhi_weight = {
            'year': 2, 'month': 3, 'day': 3, 'hour': 1
        }
        
        for position in ['year', 'month', 'day', 'hour']:
            tiangan_key = f"{position}_tiangan"
            dizhi_key = f"{position}_dizhi"
            
            if tiangan_key in bazi_data:
                wuxing = self.TIANGAN_WUXING.get(bazi_data[tiangan_key], '')
                if wuxing:
                    scores[wuxing] += tiangan_weight[position]
            
            if dizhi_key in bazi_data:
                wuxing = self.DIZHI_WUXING.get(bazi_data[dizhi_key], '')
                if wuxing:
                    scores[wuxing] += dizhi_weight[position]
        
        return scores
    
    def _determine_yongshen(self, wuxing_scores: Dict) -> Dict:
        """确定用神忌神"""
        total_score = sum(wuxing_scores.values())
        percentages = {k: (v/total_score)*100 for k, v in wuxing_scores.items()}
        
        # 简化判断逻辑：最弱的为用神，最强的为忌神
        yongshen = min(percentages.keys(), key=lambda x: percentages[x])
        jishen = max(percentages.keys(), key=lambda x: percentages[x])
        
        return {
            'yongshen': yongshen,
            'jishen': jishen,
            'analysis': f"五行{yongshen}最弱需补强，五行{jishen}过旺需抑制"
        }
```

### 数据验证与测试
```python
def test_bazi_accuracy():
    """八字计算准确性测试"""
    test_cases = [
        {
            'birth': (1990, 5, 15, 10),  # 公历生日
            'expected_year': ('庚', '午'),  # 预期年柱
            'expected_month': ('辛', '巳'), # 预期月柱
        }
        # 添加更多测试用例...
    ]
    
    calculator = BaziCalculator()
    for case in test_cases:
        result = calculator.calculate_bazi(*case['birth'])
        assert result['bazi']['year_tiangan'] == case['expected_year'][0]
        # 更多断言...
```

---

## 2. 三才五格计算模块

### 康熙字典笔画数据库

```python
class StrokeCalculator:
    """笔画数计算类"""
    
    def __init__(self):
        # 载入康熙字典笔画数据
        self.stroke_dict = self._load_kangxi_strokes()
    
    def _load_kangxi_strokes(self) -> Dict[str, int]:
        """载入康熙字典笔画数据"""
        # 部分示例数据，实际需要完整的康熙字典数据库
        return {
            # 常用字笔画数（康熙字典标准）
            '一': 1, '二': 2, '三': 3, '四': 5, '五': 4,
            '王': 4, '李': 7, '张': 11, '刘': 15, '陈': 16,
            '杨': 13, '黄': 12, '赵': 14, '周': 8, '吴': 7,
            # 需要包含3000+常用汉字
        }
    
    def get_stroke_count(self, char: str) -> int:
        """获取单个字的康熙笔画数"""
        return self.stroke_dict.get(char, 0)
    
    def calculate_sancai_wuge(self, surname: str, given_name: str) -> Dict:
        """计算三才五格"""
        if not surname or not given_name:
            raise ValueError("姓名不能为空")
        
        # 计算各字笔画数
        surname_strokes = sum(self.get_stroke_count(char) for char in surname)
        given_strokes = [self.get_stroke_count(char) for char in given_name]
        
        if not all(given_strokes):
            raise ValueError("包含未知笔画数的字符")
        
        # 计算五格
        tiange = surname_strokes + (1 if len(surname) == 1 else 0)  # 天格
        renge = surname_strokes + (given_strokes[0] if given_strokes else 0)  # 人格
        dige = sum(given_strokes) + (1 if len(given_name) == 1 else 0)  # 地格
        waige = tiange + dige - renge  # 外格
        zongge = surname_strokes + sum(given_strokes)  # 总格
        
        # 计算三才配置
        sancai = self._get_sancai_config(tiange, renge, dige)
        
        # 数理吉凶判断
        luck_analysis = {
            'tiange': self._judge_number_luck(tiange),
            'renge': self._judge_number_luck(renge),
            'dige': self._judge_number_luck(dige),
            'waige': self._judge_number_luck(waige),
            'zongge': self._judge_number_luck(zongge),
        }
        
        return {
            'wuge': {
                'tiange': tiange,
                'renge': renge,
                'dige': dige,
                'waige': waige,
                'zongge': zongge
            },
            'sancai': sancai,
            'luck_analysis': luck_analysis,
            'total_score': self._calculate_wuge_score(luck_analysis)
        }
    
    def _get_sancai_config(self, tiange: int, renge: int, dige: int) -> Dict:
        """三才配置分析"""
        wuxing_map = {
            1: '木', 2: '木', 3: '火', 4: '火', 5: '土',
            6: '土', 7: '金', 8: '金', 9: '水', 0: '水'
        }
        
        tian_wuxing = wuxing_map[tiange % 10]
        ren_wuxing = wuxing_map[renge % 10]
        di_wuxing = wuxing_map[dige % 10]
        
        config_name = f"{tian_wuxing}-{ren_wuxing}-{di_wuxing}"
        
        return {
            'config': config_name,
            'tiange_wuxing': tian_wuxing,
            'renge_wuxing': ren_wuxing,
            'dige_wuxing': di_wuxing,
            'analysis': self._analyze_sancai_relationship(tian_wuxing, ren_wuxing, di_wuxing)
        }
    
    def _judge_number_luck(self, number: int) -> Dict:
        """81数理吉凶判断"""
        # 简化版吉凶判断表
        lucky_numbers = {
            1: {'luck': '大吉', 'desc': '太极之数，万物开泰，生发无穷，利禄亨通'},
            3: {'luck': '大吉', 'desc': '三才之数，天地人和，大事大业，繁荣昌隆'},
            5: {'luck': '大吉', 'desc': '五行俱权，循环相生，圆通畅达，福祉无穷'},
            # ... 需要完整的81数理表
        }
        
        bad_numbers = {
            2: {'luck': '凶', 'desc': '两仪之数，混沌未开，进退保守，志望难达'},
            4: {'luck': '凶', 'desc': '四象之数，待于生发，万事慎重，不具营谋'},
            # ... 需要完整的凶数表
        }
        
        adjusted_number = number % 81 if number > 81 else number
        
        if adjusted_number in lucky_numbers:
            return lucky_numbers[adjusted_number]
        elif adjusted_number in bad_numbers:
            return bad_numbers[adjusted_number]
        else:
            return {'luck': '平', 'desc': '平常之数，无大吉大凶'}
    
    def _calculate_wuge_score(self, luck_analysis: Dict) -> float:
        """计算五格总体评分"""
        weight = {
            'renge': 0.3,  # 人格最重要
            'zongge': 0.25, # 总格次之
            'dige': 0.2,   # 地格
            'tiange': 0.15, # 天格
            'waige': 0.1   # 外格
        }
        
        luck_score_map = {'大吉': 95, '中吉': 80, '吉': 70, '平': 60, '凶': 40, '大凶': 20}
        
        total_score = 0
        for position, analysis in luck_analysis.items():
            score = luck_score_map.get(analysis['luck'], 60)
            total_score += score * weight.get(position, 0.1)
        
        return round(total_score, 1)
```

---

## 3. AI命名引擎

### Claude API集成

```python
import asyncio
import aiohttp
from typing import List, Dict
import re

class AINameGenerator:
    """AI命名引擎"""
    
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.anthropic.com/v1/messages"
        self.headers = {
            "Content-Type": "application/json",
            "x-api-key": self.api_key,
            "anthropic-version": "2023-06-01"
        }
    
    async def generate_names(self, 
                           surname: str, 
                           gender: str, 
                           bazi_analysis: Dict, 
                           count: int = 50) -> List[str]:
        """生成候选名字"""
        
        prompt = self._build_prompt(surname, gender, bazi_analysis, count)
        
        try:
            async with aiohttp.ClientSession() as session:
                payload = {
                    "model": "claude-3-sonnet-20240229",
                    "max_tokens": 2000,
                    "temperature": 0.7,
                    "messages": [
                        {
                            "role": "user",
                            "content": prompt
                        }
                    ]
                }
                
                async with session.post(
                    self.base_url, 
                    headers=self.headers, 
                    json=payload
                ) as response:
                    if response.status == 200:
                        result = await response.json()
                        content = result['content'][0]['text']
                        return self._parse_names_from_response(content, surname)
                    else:
                        raise Exception(f"API调用失败: {response.status}")
                        
        except Exception as e:
            raise Exception(f"名字生成失败: {str(e)}")
    
    def _build_prompt(self, surname: str, gender: str, bazi_analysis: Dict, count: int) -> str:
        """构建AI提示词"""
        yongshen = bazi_analysis.get('yongshen', '木')
        jishen = bazi_analysis.get('jishen', '土')
        
        gender_trait = "阳刚、坚毅、大气" if gender == "男" else "温婉、秀雅、灵动"
        
        prompt = f"""
你是一位专业的取名大师，请为{surname}姓{gender}宝宝生成{count}个好名字。

要求：
1. 五行要求：需要补{yongshen}，避开{jishen}
2. 性别特质：体现{gender}孩子的{gender_trait}特质
3. 寓意积极：包含美好祝愿，符合中华文化价值观
4. 音韵和谐：读音朗朗上口，避免不雅谐音
5. 字形美观：结构协调，不使用生僻字
6. 文化内涵：有典故出处更佳

输出格式：
每行一个名字，格式为：{surname}XX
如：{surname}浩然、{surname}雅馨

请开始生成：
"""
        return prompt
    
    def _parse_names_from_response(self, response_content: str, surname: str) -> List[str]:
        """从AI响应中解析名字列表"""
        names = []
        lines = response_content.strip().split('\n')
        
        for line in lines:
            line = line.strip()
            if not line:
                continue
                
            # 提取名字的正则表达式
            pattern = rf'{surname}([一-龥]{{1,2}})'
            matches = re.findall(pattern, line)
            
            for match in matches:
                full_name = f"{surname}{match}"
                if len(match) in [1, 2] and full_name not in names:  # 只要1-2个字的名字
                    names.append(full_name)
        
        return names[:50]  # 最多返回50个
```

### 算法过滤验证

```python
class NameValidator:
    """名字验证过滤器"""
    
    def __init__(self, stroke_calculator: StrokeCalculator):
        self.stroke_calc = stroke_calculator
        # 不雅谐音词库
        self.bad_homophones = {'死', '屎', '尸', '痢', '离', '你妈', '他妈'}
        
    def validate_and_score_names(self, 
                                names: List[str], 
                                bazi_analysis: Dict) -> List[Dict]:
        """验证并评分名字列表"""
        validated_names = []
        
        for name in names:
            try:
                surname = name[0]
                given_name = name[1:]
                
                # 基础验证
                if not self._basic_validation(name):
                    continue
                
                # 五行匹配度检查
                wuxing_score = self._check_wuxing_match(given_name, bazi_analysis)
                if wuxing_score < 60:  # 五行匹配度太低
                    continue
                
                # 三才五格计算
                wuge_result = self.stroke_calc.calculate_sancai_wuge(surname, given_name)
                if wuge_result['total_score'] < 70:  # 三才五格评分太低
                    continue
                
                # 音韵检查
                phonetic_score = self._check_phonetics(name)
                
                # 字义评分
                meaning_score = self._evaluate_meaning(given_name)
                
                # 文化内涵评分
                culture_score = self._check_cultural_reference(given_name)
                
                # 综合评分
                total_score = self._calculate_comprehensive_score(
                    wuxing_score, wuge_result['total_score'], 
                    meaning_score, phonetic_score, culture_score
                )
                
                validated_names.append({
                    'name': name,
                    'surname': surname,
                    'given_name': given_name,
                    'scores': {
                        'wuxing': wuxing_score,
                        'wuge': wuge_result['total_score'],
                        'meaning': meaning_score,
                        'phonetic': phonetic_score,
                        'culture': culture_score,
                        'total': total_score
                    },
                    'wuge_detail': wuge_result,
                    'analysis': self._generate_name_analysis(name, wuge_result, bazi_analysis)
                })
                
            except Exception as e:
                print(f"验证名字 {name} 时出错: {str(e)}")
                continue
        
        # 按总分排序
        validated_names.sort(key=lambda x: x['scores']['total'], reverse=True)
        return validated_names
    
    def _basic_validation(self, name: str) -> bool:
        """基础验证"""
        # 长度检查
        if len(name) < 2 or len(name) > 4:
            return False
        
        # 谐音检查
        if any(bad in name for bad in self.bad_homophones):
            return False
        
        # 字符检查（只允许中文字符）
        if not all('\u4e00' <= char <= '\u9fff' for char in name):
            return False
            
        return True
    
    def _check_wuxing_match(self, given_name: str, bazi_analysis: Dict) -> float:
        """检查五行匹配度"""
        yongshen = bazi_analysis.get('yongshen', '木')
        jishen = bazi_analysis.get('jishen', '土')
        
        # 简化版汉字五行属性字典
        char_wuxing = {
            '木': ['林', '森', '树', '松', '柏', '杨', '柳', '梅', '桃', '李'],
            '火': ['炎', '焱', '烈', '辉', '光', '明', '亮', '灿', '耀', '阳'],
            '土': ['山', '岩', '石', '磊', '坤', '埔', '培', '城', '基', '堃'],
            '金': ['金', '银', '铁', '钢', '锋', '锐', '钧', '铭', '鑫', '钰'],
            '水': ['海', '江', '河', '湖', '波', '涛', '流', '润', '泽', '清']
        }
        
        score = 60  # 基础分
        
        for char in given_name:
            # 检查是否包含用神五行的字
            if any(char in chars for chars in [char_wuxing.get(yongshen, [])]):
                score += 15
            
            # 检查是否包含忌神五行的字
            if any(char in chars for chars in [char_wuxing.get(jishen, [])]):
                score -= 20
        
        return min(100, max(0, score))
    
    def _calculate_comprehensive_score(self, wuxing: float, wuge: float, 
                                     meaning: float, phonetic: float, 
                                     culture: float) -> float:
        """计算综合评分"""
        weights = {
            'wuxing': 0.30,
            'wuge': 0.25,
            'meaning': 0.20,
            'phonetic': 0.15,
            'culture': 0.10
        }
        
        total = (
            wuxing * weights['wuxing'] +
            wuge * weights['wuge'] +
            meaning * weights['meaning'] +
            phonetic * weights['phonetic'] +
            culture * weights['culture']
        )
        
        return round(total, 1)
```

---

## 4. Flutter项目架构

### 项目结构设计

```
ai_naming_app/
├── lib/
│   ├── main.dart                    # App入口
│   ├── app/
│   │   ├── app.dart                 # 应用配置
│   │   └── routes/                  # 路由配置
│   ├── core/
│   │   ├── constants/               # 常量定义
│   │   ├── utils/                   # 工具类
│   │   ├── services/                # 服务层
│   │   │   ├── api_service.dart     # API服务
│   │   │   ├── auth_service.dart    # 认证服务
│   │   │   └── payment_service.dart # 支付服务
│   │   └── models/                  # 数据模型
│   ├── features/                    # 功能模块
│   │   ├── auth/                    # 认证模块
│   │   ├── naming/                  # 取名核心功能
│   │   │   ├── controllers/         # 控制器
│   │   │   ├── models/             # 模型
│   │   │   ├── services/           # 服务
│   │   │   └── views/              # 界面
│   │   ├── payment/                # 支付模块
│   │   └── profile/                # 用户中心
│   └── shared/
│       ├── widgets/                # 通用组件
│       ├── themes/                 # 主题样式
│       └── extensions/             # 扩展方法
├── android/                        # Android配置
├── ios/                           # iOS配置
└── pubspec.yaml                   # 依赖配置
```

### 核心依赖 pubspec.yaml

```yaml
name: ai_naming_app
description: AI智能取名应用

publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # 状态管理
  get: ^4.6.5
  
  # 网络请求
  dio: ^5.3.2
  pretty_dio_logger: ^1.3.1
  
  # 数据存储
  get_storage: ^2.1.1
  
  # UI组件
  cupertino_icons: ^1.0.2
  google_fonts: ^6.1.0
  flutter_screenutil: ^5.9.0
  
  # 支付相关
  fluwx: ^4.0.1  # 微信支付
  
  # 工具库
  intl: ^0.18.1
  uuid: ^4.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
  fonts:
    - family: SourceHanSans
      fonts:
        - asset: assets/fonts/SourceHanSans-Regular.ttf
```

### 核心模型定义

```dart
// lib/core/models/bazi_analysis.dart
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
}

// lib/core/models/name_result.dart
class NameResult {
  final String name;
  final String surname;
  final String givenName;
  final NameScores scores;
  final WugeDetail wugeDetail;
  final String analysis;

  NameResult({
    required this.name,
    required this.surname,
    required this.givenName,
    required this.scores,
    required this.wugeDetail,
    required this.analysis,
  });

  factory NameResult.fromJson(Map<String, dynamic> json) {
    return NameResult(
      name: json['name'],
      surname: json['surname'],
      givenName: json['given_name'],
      scores: NameScores.fromJson(json['scores']),
      wugeDetail: WugeDetail.fromJson(json['wuge_detail']),
      analysis: json['analysis'],
    );
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
      wuxing: json['wuxing'].toDouble(),
      wuge: json['wuge'].toDouble(),
      meaning: json['meaning'].toDouble(),
      phonetic: json['phonetic'].toDouble(),
      culture: json['culture'].toDouble(),
      total: json['total'].toDouble(),
    );
  }
}
```

### API服务层

```dart
// lib/core/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

class ApiService extends GetxService {
  late Dio _dio;
  static const String baseUrl = 'https://your-api-domain.com/api/v1';

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 添加拦截器
    _dio.interceptors.add(PrettyDioLogger());
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 添加认证token
        final token = GetStorage().read('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  // 计算八字
  Future<BaziAnalysis> calculateBazi({
    required String surname,
    required String gender,
    required DateTime birthDate,
    required int hour,
    double longitude = 116.4074,
  }) async {
    try {
      final response = await _dio.post('/bazi/calculate', data: {
        'surname': surname,
        'gender': gender,
        'year': birthDate.year,
        'month': birthDate.month,
        'day': birthDate.day,
        'hour': hour,
        'longitude': longitude,
      });

      return BaziAnalysis.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 生成名字
  Future<List<NameResult>> generateNames({
    required String surname,
    required String gender,
    required BaziAnalysis baziAnalysis,
    required bool isPaid,
  }) async {
    try {
      final response = await _dio.post('/names/generate', data: {
        'surname': surname,
        'gender': gender,
        'bazi_analysis': baziAnalysis.toJson(),
        'is_paid': isPaid,
      });

      return (response.data['names'] as List)
          .map((json) => NameResult.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查网络';
      case DioExceptionType.receiveTimeout:
        return '响应超时，请重试';
      case DioExceptionType.badResponse:
        return e.response?.data['message'] ?? '服务器错误';
      default:
        return '网络错误，请重试';
    }
  }
}
```

### 取名控制器

```dart
// lib/features/naming/controllers/naming_controller.dart
import 'package:get/get.dart';

class NamingController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // 响应式状态
  var isLoading = false.obs;
  var currentStep = 1.obs;
  
  // 用户输入数据
  var surname = ''.obs;
  var gender = '男'.obs;
  var birthDate = DateTime.now().obs;
  var birthHour = 12.obs;
  
  // 计算结果
  Rx<BaziAnalysis?> baziAnalysis = Rx<BaziAnalysis?>(null);
  RxList<NameResult> nameResults = <NameResult>[].obs;
  RxList<NameResult> favoriteNames = <NameResult>[].obs;

  // 计算八字
  Future<void> calculateBazi() async {
    if (surname.isEmpty) {
      Get.snackbar('提示', '请输入姓氏');
      return;
    }

    try {
      isLoading.value = true;
      
      final result = await _apiService.calculateBazi(
        surname: surname.value,
        gender: gender.value,
        birthDate: birthDate.value,
        hour: birthHour.value,
      );
      
      baziAnalysis.value = result;
      currentStep.value = 2;
      
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // 生成免费名字
  Future<void> generateFreeNames() async {
    if (baziAnalysis.value == null) {
      Get.snackbar('错误', '请先完成八字分析');
      return;
    }

    try {
      isLoading.value = true;
      
      final results = await _apiService.generateNames(
        surname: surname.value,
        gender: gender.value,
        baziAnalysis: baziAnalysis.value!,
        isPaid: false,
      );
      
      nameResults.assignAll(results);
      currentStep.value = 3;
      
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // 购买完整版
  Future<void> purchaseFullVersion() async {
    // 调用支付服务
    final paymentService = Get.find<PaymentService>();
    
    try {
      isLoading.value = true;
      
      final success = await paymentService.pay(
        amount: 1999, // 19.99元，单位：分
        productName: '专业取名服务',
        description: '50个精选名字 + 详细分析报告',
      );
      
      if (success) {
        await generatePaidNames();
      }
      
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // 生成付费名字
  Future<void> generatePaidNames() async {
    try {
      isLoading.value = true;
      
      final results = await _apiService.generateNames(
        surname: surname.value,
        gender: gender.value,
        baziAnalysis: baziAnalysis.value!,
        isPaid: true,
      );
      
      nameResults.assignAll(results);
      
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // 收藏名字
  void toggleFavorite(NameResult name) {
    if (favoriteNames.contains(name)) {
      favoriteNames.remove(name);
    } else {
      favoriteNames.add(name);
    }
    
    // 保存到本地存储
    GetStorage().write('favorite_names', favoriteNames.map((e) => e.toJson()).toList());
  }
}
```

---

## 5. 微信小程序方案

### 技术选型：uni-app

**优势**：
- 一套代码多端运行
- Vue.js语法，开发效率高
- 社区成熟，插件丰富
- 可同时发布到微信小程序和H5

### 项目结构

```
ai-naming-mini/
├── pages/                  # 页面文件
│   ├── index/              # 首页
│   ├── naming/             # 取名功能页
│   ├── result/             # 结果页面
│   └── profile/            # 个人中心
├── components/             # 组件
├── static/                 # 静态资源
├── utils/                  # 工具函数
├── store/                  # 状态管理
├── api/                    # API接口
├── App.vue                # 应用配置
├── main.js                # 入口文件
├── manifest.json          # 应用配置
└── pages.json             # 页面配置
```

### 核心代码示例

```vue
<!-- pages/naming/naming.vue -->
<template>
  <view class="naming-container">
    <view class="step-indicator">
      <view class="step" :class="{ active: currentStep >= 1 }">输入信息</view>
      <view class="step" :class="{ active: currentStep >= 2 }">八字分析</view>
      <view class="step" :class="{ active: currentStep >= 3 }">推荐名字</view>
    </view>

    <!-- 步骤1：输入基本信息 -->
    <view v-if="currentStep === 1" class="input-form">
      <uni-forms ref="form" :modelValue="formData">
        <uni-forms-item label="宝宝姓氏" name="surname" required>
          <uni-easyinput v-model="formData.surname" placeholder="请输入姓氏" />
        </uni-forms-item>
        
        <uni-forms-item label="性别" name="gender" required>
          <uni-data-checkbox 
            v-model="formData.gender" 
            :localdata="genderOptions"
          />
        </uni-forms-item>
        
        <uni-forms-item label="出生日期" name="birthDate" required>
          <uni-datetime-picker 
            v-model="formData.birthDate"
            type="date"
          />
        </uni-forms-item>
        
        <uni-forms-item label="出生时辰" name="birthHour" required>
          <uni-data-select
            v-model="formData.birthHour"
            :localdata="hourOptions"
          />
        </uni-forms-item>
      </uni-forms>
      
      <button @click="calculateBazi" class="primary-btn">
        开始八字分析
      </button>
    </view>

    <!-- 步骤2：八字分析结果 -->
    <view v-if="currentStep === 2" class="bazi-analysis">
      <view class="bazi-chart">
        <view class="pillar" v-for="(pillar, index) in baziData" :key="index">
          <view class="tiangan">{{ pillar.tiangan }}</view>
          <view class="dizhi">{{ pillar.dizhi }}</view>
          <view class="label">{{ pillar.label }}</view>
        </view>
      </view>
      
      <view class="wuxing-analysis">
        <view class="wuxing-item" v-for="(score, element) in wuxingScores" :key="element">
          <text>{{ element }}：</text>
          <progress :percent="score" />
          <text>{{ score }}%</text>
        </view>
      </view>
      
      <view class="suggestion">
        <text>用神：{{ yongshen }}</text>
        <text>忌神：{{ jishen }}</text>
        <text>建议：补{{ yongshen }}，避{{ jishen }}</text>
      </view>
      
      <button @click="generateNames" class="primary-btn">
        生成推荐名字
      </button>
    </view>

    <!-- 步骤3：名字推荐 -->
    <view v-if="currentStep === 3" class="name-results">
      <view class="free-section">
        <view class="section-title">免费推荐（3个）</view>
        <view class="name-list">
          <view 
            v-for="name in freeNames" 
            :key="name.name"
            class="name-card"
            @click="showNameDetail(name)"
          >
            <view class="name-text">{{ name.name }}</view>
            <view class="score">{{ name.scores.total }}分</view>
          </view>
        </view>
      </view>
      
      <view class="paid-section">
        <view class="section-title">
          完整版推荐（50个） 
          <text class="price">¥19.9</text>
        </view>
        
        <view v-if="!isPaid" class="upgrade-prompt">
          <image src="/static/premium-icon.png" class="premium-icon" />
          <text>解锁50个精选好名 + 详细分析报告</text>
          <button @click="purchaseFullVersion" class="upgrade-btn">
            立即购买
          </button>
        </view>
        
        <view v-else class="name-list">
          <view 
            v-for="name in allNames" 
            :key="name.name"
            class="name-card premium"
            @click="showNameDetail(name)"
          >
            <view class="name-text">{{ name.name }}</view>
            <view class="score">{{ name.scores.total }}分</view>
            <view class="favorite" @click.stop="toggleFavorite(name)">
              <uni-icons 
                :type="isFavorite(name) ? 'heart-filled' : 'heart'" 
                color="#ff5722"
              />
            </view>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      currentStep: 1,
      formData: {
        surname: '',
        gender: '男',
        birthDate: '',
        birthHour: 12
      },
      genderOptions: [
        { value: '男', text: '男孩' },
        { value: '女', text: '女孩' }
      ],
      hourOptions: [
        { value: 0, text: '子时(23:00-00:59)' },
        { value: 2, text: '丑时(01:00-02:59)' },
        // ... 更多时辰
      ],
      baziData: [],
      wuxingScores: {},
      yongshen: '',
      jishen: '',
      freeNames: [],
      allNames: [],
      isPaid: false,
      favoriteNames: []
    }
  },
  
  methods: {
    async calculateBazi() {
      try {
        uni.showLoading({ title: '计算中...' });
        
        const res = await this.$api.calculateBazi(this.formData);
        
        this.baziData = res.bazi;
        this.wuxingScores = res.wuxing_scores;
        this.yongshen = res.yongshen;
        this.jishen = res.jishen;
        this.currentStep = 2;
        
      } catch (error) {
        uni.showToast({
          title: error.message || '计算失败',
          icon: 'none'
        });
      } finally {
        uni.hideLoading();
      }
    },
    
    async generateNames() {
      try {
        uni.showLoading({ title: '生成中...' });
        
        const res = await this.$api.generateNames({
          ...this.formData,
          bazi_analysis: {
            wuxing_scores: this.wuxingScores,
            yongshen: this.yongshen,
            jishen: this.jishen
          },
          is_paid: false
        });
        
        this.freeNames = res.slice(0, 3);
        this.currentStep = 3;
        
      } catch (error) {
        uni.showToast({
          title: error.message || '生成失败',
          icon: 'none'
        });
      } finally {
        uni.hideLoading();
      }
    },
    
    async purchaseFullVersion() {
      try {
        // 调用微信支付
        const res = await uni.requestPayment({
          provider: 'wxpay',
          timeStamp: String(Date.now()),
          nonceStr: 'random-string',
          package: 'prepay_id=wx_prepay_id',
          signType: 'MD5',
          paySign: 'pay-sign'
        });
        
        if (res.errMsg === 'requestPayment:ok') {
          await this.generatePaidNames();
          this.isPaid = true;
        }
        
      } catch (error) {
        uni.showToast({
          title: '支付失败',
          icon: 'none'
        });
      }
    },
    
    async generatePaidNames() {
      try {
        uni.showLoading({ title: '生成中...' });
        
        const res = await this.$api.generateNames({
          ...this.formData,
          bazi_analysis: {
            wuxing_scores: this.wuxingScores,
            yongshen: this.yongshen,
            jishen: this.jishen
          },
          is_paid: true
        });
        
        this.allNames = res;
        
      } catch (error) {
        uni.showToast({
          title: error.message || '生成失败',
          icon: 'none'
        });
      } finally {
        uni.hideLoading();
      }
    }
  }
}
</script>
```

---

## 6. 后端API设计 (FastAPI)

### API架构设计

```python
# main.py
from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.core.config import settings
from app.core.database import engine, create_tables
from app.api.v1 import api_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    # 启动时创建表
    create_tables()
    yield

app = FastAPI(
    title="AI取名API",
    description="AI驱动的专业取名服务",
    version="1.0.0",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_HOSTS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix="/api/v1")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
```

### API路由定义

```python
# app/api/v1/__init__.py
from fastapi import APIRouter
from .endpoints import bazi, naming, auth, payment

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["认证"])
api_router.include_router(bazi.router, prefix="/bazi", tags=["八字分析"])
api_router.include_router(naming.router, prefix="/names", tags=["取名服务"])
api_router.include_router(payment.router, prefix="/payment", tags=["支付"])

# app/api/v1/endpoints/bazi.py
from fastapi import APIRouter, Depends, HTTPException
from typing import Dict, Any
from datetime import datetime

from app.schemas.bazi import BaziRequest, BaziResponse
from app.services.bazi_service import BaziService
from app.core.deps import get_current_user

router = APIRouter()

@router.post("/calculate", response_model=BaziResponse)
async def calculate_bazi(
    request: BaziRequest,
    current_user: dict = Depends(get_current_user),
    bazi_service: BaziService = Depends()
):
    """计算八字分析"""
    try:
        result = await bazi_service.calculate_bazi(
            surname=request.surname,
            gender=request.gender,
            year=request.year,
            month=request.month,
            day=request.day,
            hour=request.hour,
            longitude=request.longitude
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# app/api/v1/endpoints/naming.py
from fastapi import APIRouter, Depends, HTTPException
from typing import List

from app.schemas.naming import NamingRequest, NameResult
from app.services.naming_service import NamingService
from app.core.deps import get_current_user, verify_payment

router = APIRouter()

@router.post("/generate", response_model=List[NameResult])
async def generate_names(
    request: NamingRequest,
    current_user: dict = Depends(get_current_user),
    naming_service: NamingService = Depends()
):
    """生成名字推荐"""
    try:
        # 如果是付费请求，验证支付状态
        if request.is_paid:
            await verify_payment(current_user["id"], "naming_service")
        
        result = await naming_service.generate_names(
            surname=request.surname,
            gender=request.gender,
            bazi_analysis=request.bazi_analysis,
            is_paid=request.is_paid
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
```

### 数据模型定义

```python
# app/schemas/bazi.py
from pydantic import BaseModel
from typing import Dict
from datetime import datetime

class BaziRequest(BaseModel):
    surname: str
    gender: str
    year: int
    month: int
    day: int
    hour: int
    longitude: float = 116.4074

class BaziData(BaseModel):
    year_tiangan: str
    year_dizhi: str
    month_tiangan: str
    month_dizhi: str
    day_tiangan: str
    day_dizhi: str
    hour_tiangan: str
    hour_dizhi: str

class BaziResponse(BaseModel):
    bazi: BaziData
    wuxing_scores: Dict[str, int]
    yongshen: str
    jishen: str
    lunar_date: str
    solar_date: str

# app/schemas/naming.py
class NamingRequest(BaseModel):
    surname: str
    gender: str
    bazi_analysis: Dict
    is_paid: bool = False

class NameScores(BaseModel):
    wuxing: float
    wuge: float
    meaning: float
    phonetic: float
    culture: float
    total: float

class WugeDetail(BaseModel):
    wuge: Dict[str, int]
    sancai: Dict[str, str]
    luck_analysis: Dict[str, Dict]
    total_score: float

class NameResult(BaseModel):
    name: str
    surname: str
    given_name: str
    scores: NameScores
    wuge_detail: WugeDetail
    analysis: str
```

### 业务服务层

```python
# app/services/naming_service.py
from typing import List, Dict
import asyncio

from app.core.ai_client import AINameGenerator
from app.core.bazi_calculator import BaziCalculator
from app.core.stroke_calculator import StrokeCalculator
from app.core.name_validator import NameValidator
from app.schemas.naming import NameResult

class NamingService:
    def __init__(self):
        self.ai_generator = AINameGenerator(api_key=settings.CLAUDE_API_KEY)
        self.stroke_calculator = StrokeCalculator()
        self.name_validator = NameValidator(self.stroke_calculator)
    
    async def generate_names(self, 
                           surname: str, 
                           gender: str, 
                           bazi_analysis: Dict, 
                           is_paid: bool) -> List[NameResult]:
        """生成名字推荐"""
        
        # 1. 使用AI生成候选名字
        candidate_names = await self.ai_generator.generate_names(
            surname=surname,
            gender=gender,
            bazi_analysis=bazi_analysis,
            count=100 if is_paid else 20
        )
        
        # 2. 验证和评分
        validated_names = self.name_validator.validate_and_score_names(
            names=candidate_names,
            bazi_analysis=bazi_analysis
        )
        
        # 3. 根据付费状态返回结果
        if is_paid:
            return validated_names[:50]  # 付费用户返回50个
        else:
            return validated_names[:3]   # 免费用户返回3个
    
    async def get_name_detail(self, name: str, bazi_analysis: Dict) -> NameResult:
        """获取单个名字的详细分析"""
        surname = name[0]
        given_name = name[1:]
        
        validated_names = self.name_validator.validate_and_score_names(
            names=[name],
            bazi_analysis=bazi_analysis
        )
        
        if not validated_names:
            raise ValueError("名字分析失败")
        
        return validated_names[0]
```

---

## 7. 支付集成

### 微信支付集成

```python
# app/services/payment_service.py
import hashlib
import time
import uuid
from typing import Dict
import aiohttp

from app.core.config import settings

class WechatPayService:
    def __init__(self):
        self.app_id = settings.WECHAT_APP_ID
        self.mch_id = settings.WECHAT_MCH_ID
        self.api_key = settings.WECHAT_API_KEY
        self.notify_url = settings.WECHAT_NOTIFY_URL
    
    async def create_order(self, 
                          user_id: str,
                          amount: int,  # 分为单位
                          product_name: str,
                          description: str) -> Dict:
        """创建微信支付订单"""
        
        order_id = f"ORDER_{int(time.time())}_{uuid.uuid4().hex[:8]}"
        
        # 构建支付参数
        params = {
            'appid': self.app_id,
            'mch_id': self.mch_id,
            'nonce_str': uuid.uuid4().hex,
            'body': product_name,
            'detail': description,
            'out_trade_no': order_id,
            'total_fee': amount,
            'spbill_create_ip': '127.0.0.1',
            'notify_url': self.notify_url,
            'trade_type': 'JSAPI',
            'openid': await self._get_user_openid(user_id)
        }
        
        # 生成签名
        params['sign'] = self._generate_sign(params)
        
        # 调用微信统一下单API
        xml_data = self._dict_to_xml(params)
        
        async with aiohttp.ClientSession() as session:
            async with session.post(
                'https://api.mch.weixin.qq.com/pay/unifiedorder',
                data=xml_data,
                headers={'Content-Type': 'application/xml'}
            ) as response:
                result_xml = await response.text()
                result = self._xml_to_dict(result_xml)
        
        if result.get('return_code') == 'SUCCESS' and result.get('result_code') == 'SUCCESS':
            # 生成小程序支付参数
            prepay_id = result['prepay_id']
            pay_params = self._generate_miniapp_pay_params(prepay_id)
            
            # 保存订单到数据库
            await self._save_order(
                order_id=order_id,
                user_id=user_id,
                amount=amount,
                product_name=product_name,
                prepay_id=prepay_id
            )
            
            return {
                'order_id': order_id,
                'pay_params': pay_params
            }
        else:
            raise Exception(f"创建订单失败: {result.get('err_code_des', '未知错误')}")
    
    def _generate_sign(self, params: Dict) -> str:
        """生成微信支付签名"""
        # 按ASCII码排序
        sorted_params = sorted([(k, v) for k, v in params.items() if v])
        query_string = '&'.join([f'{k}={v}' for k, v in sorted_params])
        query_string += f'&key={self.api_key}'
        
        return hashlib.md5(query_string.encode('utf-8')).hexdigest().upper()
    
    def _generate_miniapp_pay_params(self, prepay_id: str) -> Dict:
        """生成小程序支付参数"""
        timestamp = str(int(time.time()))
        nonce_str = uuid.uuid4().hex
        
        params = {
            'appId': self.app_id,
            'timeStamp': timestamp,
            'nonceStr': nonce_str,
            'package': f'prepay_id={prepay_id}',
            'signType': 'MD5'
        }
        
        params['paySign'] = self._generate_sign(params)
        
        return params

# 支付回调处理
@router.post("/wechat/notify")
async def wechat_pay_notify(request: Request):
    """微信支付回调"""
    xml_data = await request.body()
    result = WechatPayService._xml_to_dict(xml_data.decode('utf-8'))
    
    if result.get('return_code') == 'SUCCESS' and result.get('result_code') == 'SUCCESS':
        order_id = result['out_trade_no']
        transaction_id = result['transaction_id']
        
        # 更新订单状态
        await update_order_status(order_id, 'paid', transaction_id)
        
        # 发放用户权限
        await grant_user_privilege(order_id)
        
        return {"return_code": "SUCCESS", "return_msg": "OK"}
    
    return {"return_code": "FAIL", "return_msg": "签名验证失败"}
```

---

## 第四步：创建Flutter项目骨架

<function_calls>
<invoke name="exec">
<parameter name="command">cd /Users/andy_crab/.openclaw/workspace/ai-naming-app && flutter create --org com.aicrab.naming ai_naming_app