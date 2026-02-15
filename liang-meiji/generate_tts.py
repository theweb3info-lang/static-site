import re
import sys

def generate_tts_text(input_file, output_file):
    # Read the markdown file
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Remove markdown formatting
    content = re.sub(r'^#+ ', '', content, flags=re.MULTILINE)  # Remove headers
    content = re.sub(r'\*\*([^*]+)\*\*', r'\1', content)  # Remove bold
    content = re.sub(r'\*([^*]+)\*', r'\1', content)  # Remove italic  
    content = re.sub(r'`([^`]+)`', r'\1', content)  # Remove code
    content = re.sub(r'---+', '', content)  # Remove horizontal rules
    content = re.sub(r'\n\s*\n', '\n\n', content)  # Normalize line breaks

    # Add evaluation-style transitions for better audio flow
    transitions = {
        '背景：幕府末日来临': '话说这事儿的背景，还得从幕府的末日说起。',
        '胜海舟：幕府最后的明白人': '先说说胜海舟这个人，那可真是个传奇。',
        '西乡隆盛：心有慈悲的"人斩"': '再来说说西乡隆盛这边的情况。',
        '关键会面：薩摩屋敷的茶话': '接下来到了最关键的时刻，两人的会面。',
        '智慧博弈：七条协议的诞生': '那么，这场智慧博弈是怎么进行的呢？',
        '历史转折：一座城市的救赎': '咱们再说说这个历史转折点。',
        '人物评价：英雄惺惺相惜': '事后回想起来，这两个人的关系很有意思。',
        '深层思考：什么是真正的英雄': '这个故事给咱们什么启示呢？',
        '历史意义：开创和平变革先例': '从历史意义上来说，这次无血开城可不简单。',
        '结语：历史的选择': '最后，咱们回过头来看看这件事。'
    }

    for old, new in transitions.items():
        content = content.replace(old, new)

    # Protect Japanese names with commas
    japanese_names = [
        '德川庆喜', '胜海舟', '西乡隆盛', '大久保利通', '板仓胜静', '坂本龙马',
        '德川家茂', '孝明天皇', '明治天皇', '岩仓具视', '木户孝允', '大村益次郎',
        '井伊直弼', '松平容保', '松平定敬', '东久世通禧', '相乐总三', '益满休之助'
    ]

    for name in japanese_names:
        content = re.sub(f'(?<![、，])({re.escape(name)})(?![、，])', r'、\1、', content)

    # Protect place names and technical terms
    protected_terms = [
        '大政奉还', '鸟羽伏见之战', '戊辰战争', '王政复古大号令', '小御所会议',
        '江户城', '萨摩藩', '长州藩', '上野宛永寺', '薩摩屋敷', '东征大总督府',
        '庆応四年', '明治元年', '安政大狱', '尊王攘夷', '征韩论', '西南战争'
    ]

    for term in protected_terms:
        content = re.sub(f'(?<![、，])({re.escape(term)})(?![、，])', r'、\1、', content)

    # Clean up multiple commas and fix punctuation issues
    content = re.sub(r'、+', '、', content)
    content = re.sub(r'还→环', '环', content)  # Fix pronunciation
    
    # Write TTS version
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f'TTS text generated successfully: {output_file}')

if __name__ == '__main__':
    input_file = 'articles/event-01-江户无血开城.md'
    output_file = 'articles/event-01-江户无血开城-tts.txt'
    generate_tts_text(input_file, output_file)