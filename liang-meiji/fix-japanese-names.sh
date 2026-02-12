#!/bin/bash

# 日本人名完整读音保护脚本
# 确保TTS读出完整人名，不在中间断句

cd /Users/andy_crab/.openclaw/workspace/liang-meiji/articles

# 人名列表（按出现频率排序）
declare -a names=(
  "坂本龙马"
  "西乡隆盛"
  "大久保利通"
  "德川庆喜"
  "伊藤博文"
  "木户孝允"
  "桂小五郎"
  "岩仓具视"
  "胜海舟"
  "高杉晋作"
  "岛津齐彬"
  "岛津久光"
  "中冈慎太郎"
  "后藤象二郎"
  "山内容堂"
  "福泽谕吉"
  "井伊直弼"
  "近藤勇"
  "土方岁三"
  "大村益次郎"
  "吉田松阴"
  "榎本武扬"
  "板垣退助"
  "大隈重信"
  "井上馨"
  "岩崎弥太郎"
  "东乡平八郎"
  "乃木希典"
  "山县有朋"
  "西乡从道"
  "小松带刀"
  "久坂玄瑞"
  "武市半平太"
  "江藤新平"
  "陆奥宗光"
  "黑田清隆"
  "大山岩"
  "松平容保"
  "松平春嶽"
  "伊达宗城"
  "高桥是清"
  "涩泽荣一"
  "夏目漱石"
  "明治天皇"
  "孝明天皇"
  "德川家茂"
  "德川家康"
  "德川齐昭"
  "毛利敬亲"
  "新岛八重"
  "天璋院"
  "和宫"
  "津田梅子"
  "与谢野晶子"
)

for file in *-tts.txt; do
  if [ ! -f "$file" ] || [[ "$file" == *.bak ]]; then
    continue
  fi
  
  echo "Processing $file for full name protection..."
  
  # 备份
  if [ ! -f "$file.name-bak" ]; then
    cp "$file" "$file.name-bak"
  fi
  
  # 为每个人名前后加顿号（如果还没有）
  for name in "${names[@]}"; do
    # 处理各种上下文场景
    # 1. 句首/段首的人名
    sed -i '' "s/^${name}/、${name}、/g" "$file"
    
    # 2. 空格后的人名
    sed -i '' "s/ ${name}/ 、${name}、/g" "$file"
    
    # 3. 标点符号后的人名
    sed -i '' "s/，${name}/，、${name}、/g" "$file"
    sed -i '' "s/。${name}/。、${name}、/g" "$file"
    sed -i '' "s/；${name}/；、${name}、/g" "$file"
    sed -i '' "s/！${name}/！、${name}、/g" "$file"
    sed -i '' "s/？${name}/？、${name}、/g" "$file"
    sed -i '' "s/：${name}/：、${name}、/g" "$file"
    
    # 4. "叫/是/为/的"等词后的人名
    sed -i '' "s/叫${name}/叫、${name}、/g" "$file"
    sed -i '' "s/是${name}/是、${name}、/g" "$file"
    sed -i '' "s/为${name}/为、${name}、/g" "$file"
    
    # 5. 引号内的人名
    sed -i '' "s/\"${name}/\"、${name}、/g" "$file"
    sed -i '' "s/"${name}/"、${name}、/g" "$file"
    
    # 6. 已有顿号的不重复添加（清理多余顿号）
    sed -i '' "s/、、${name}、/、${name}、/g" "$file"
    sed -i '' "s/、${name}、、/、${name}、/g" "$file"
    sed -i '' "s/、、、/、/g" "$file"
    sed -i '' "s/、、/、/g" "$file"
  done
  
  echo "✓ $file - Japanese names protected"
done

echo ""
echo "All files updated with full Japanese name protection"
echo "Original backups: *.name-bak"
