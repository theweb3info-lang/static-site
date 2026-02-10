import re

html_file = "zh/01-坂本龙马.html"

with open(html_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Scene 1: After "二、黑船来了" heading
scene1_html = '''<h2>二、黑船来了：从"攘夷愤青"到"开国先锋"</h2>
<div style="margin: 20px 0; text-align: center;">
<img src="../images/ryoma-scene1-blackships-1.webp" style="max-width: 100%; border-radius: 8px; margin: 10px 0;" alt="1853年品川海岸，坂本龙马警戒黑船来航">
<p style="color: #666; font-size: 0.9em; margin-top: 8px;">📍 1853年品川海岸：坂本龙马与武士们警戒美国黑船来航</p>
</div>'''

content = content.replace('<h2>二、黑船来了：从"攘夷愤青"到"开国先锋"</h2>', scene1_html)

# Scene 2: After "三、'我本来是去杀他的'" heading  
scene2_html = '''<h2>三、"我本来是去杀他的"：龙马与胜海舟</h2>
<div style="margin: 20px 0; text-align: center;">
<img src="../images/ryoma-scene2-katsu-2.webp" style="max-width: 100%; border-radius: 8px; margin: 10px 0;" alt="1862年江户赤坂，坂本龙马与胜海舟会面">
<p style="color: #666; font-size: 0.9em; margin-top: 8px;">📍 1862年江户赤坂：龙马本来要刺杀胜海舟，结果被说服拜师</p>
</div>'''

content = content.replace('<h2>三、"我本来是去杀他的"：龙马与胜海舟</h2>', scene2_html)

# Scene 3: After "四、撮合死敌" heading
scene3_html = '''<h2>四、撮合死敌：萨长同盟</h2>
<div style="margin: 20px 0; text-align: center;">
<img src="../images/ryoma-scene3-alliance-1.webp" style="max-width: 100%; border-radius: 8px; margin: 10px 0;" alt="1866年京都，萨长同盟签订">
<p style="color: #666; font-size: 0.9em; margin-top: 8px;">📍 1866年京都小松带刀府邸：龙马促成萨摩和长州死敌同盟</p>
</div>'''

content = content.replace('<h2>四、撮合死敌：萨长同盟</h2>', scene3_html)

# Scene 4: After "七、近江屋之夜" heading
scene4_html = '''<h2>七、近江屋之夜：三十一岁，生日即忌日</h2>
<div style="margin: 20px 0; text-align: center;">
<img src="../images/ryoma-scene4-assassination-1.webp" style="max-width: 100%; border-radius: 8px; margin: 10px 0;" alt="1867年京都近江屋，坂本龙马遇刺">
<p style="color: #666; font-size: 0.9em; margin-top: 8px;">📍 1867年京都近江屋：31岁生日夜晚，龙马被刺客暗杀</p>
</div>'''

content = content.replace('<h2>七、近江屋之夜：三十一岁，生日即忌日</h2>', scene4_html)

# Write back
with open(html_file, 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ 已在HTML中插入4个历史场景图片")
