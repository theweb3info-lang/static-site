#!/bin/bash

# 多音字修正脚本 - 基于《多音字校正表.md》

cd /Users/andy_crab/.openclaw/workspace/liang-meiji/articles

for file in *-tts.txt; do
  if [ ! -f "$file" ]; then
    continue
  fi
  
  echo "Processing $file..."
  
  # 备份
  cp "$file" "$file.bak"
  
  # 1. "还"字替换（归还义，读huán）
  sed -i '' 's/大政奉还/大政奉环/g' "$file"
  sed -i '' 's/还于朝廷/环于朝廷/g' "$file"
  sed -i '' 's/还政/环政/g' "$file"
  sed -i '' 's/版籍奉还/版籍奉环/g' "$file"
  sed -i '' 's/交还给/交环给/g' "$file"
  
  # 1b. "难"字标注（困难义，读nán二声，不读nàn四声）
  sed -i '' 's/有多难/有多难(nan2)/g' "$file"
  sed -i '' 's/\([^有]\)难度/\1难(nan2)度/g' "$file"
  sed -i '' 's/很难/很难(nan2)/g' "$file"
  sed -i '' 's/太难/太难(nan2)/g' "$file"
  
  # 1c. 高频多音字标注（老梁风格常见误读）
  sed -i '' 's/觉得/觉(jue2)得/g' "$file"
  sed -i '' 's/睡觉/睡觉(jiao4)/g' "$file"
  sed -i '' 's/自觉/自觉(jue2)/g' "$file"
  sed -i '' 's/命中/命中(zhong4)/g' "$file"
  sed -i '' 's/中举/中(zhong4)举/g' "$file"
  sed -i '' 's/中了/中(zhong4)了/g' "$file"
  sed -i '' 's/到处/到处(chu4)/g' "$file"
  sed -i '' 's/处理/处(chu3)理/g' "$file"
  sed -i '' 's/一处/一处(chu4)/g' "$file"
  sed -i '' 's/成长/成长(zhang3)/g' "$file"
  sed -i '' 's/长度/长(chang2)度/g' "$file"
  sed -i '' 's/长官/长(zhang3)官/g' "$file"
  sed -i '' 's/上当/上当(dang4)/g' "$file"
  sed -i '' 's/当铺/当(dang4)铺/g' "$file"
  sed -i '' 's/便宜/便(pian2)宜/g' "$file"
  sed -i '' 's/传记/传(zhuan4)记/g' "$file"
  sed -i '' 's/着急/着(zhao2)急/g' "$file"
  sed -i '' 's/着手/着(zhuo2)手/g' "$file"
  sed -i '' 's/落枕/落(lao4)枕/g' "$file"
  sed -i '' 's/差别/差(cha1)别/g' "$file"
  sed -i '' 's/差不多/差(cha4)不多/g' "$file"
  sed -i '' 's/出差/出差(chai1)/g' "$file"
  sed -i '' 's/参差/参差(ci1)/g' "$file"
  sed -i '' 's/鲜血/鲜血(xue4)/g' "$file"
  sed -i '' 's/血淋淋/血(xie3)淋淋/g' "$file"
  sed -i '' 's/教书/教(jiao1)书/g' "$file"
  sed -i '' 's/行业/行(hang2)业/g' "$file"
  sed -i '' 's/银行/银行(hang2)/g' "$file"
  
  # 2. 年号保护（前后加顿号）
  sed -i '' 's/庆应\([一二三四五六七八九十元]\+\)年/、庆应\1年、/g' "$file"
  sed -i '' 's/安政\([一二三四五六七八九十元]\+\)年/、安政\1年、/g' "$file"
  sed -i '' 's/文久\([一二三四五六七八九十元]\+\)年/、文久\1年、/g' "$file"
  sed -i '' 's/明治\([一二三四五六七八九十元]\+\)年/、明治\1年、/g' "$file"
  sed -i '' 's/天保\([一二三四五六七八九十元]\+\)年/、天保\1年、/g' "$file"
  sed -i '' 's/嘉永\([一二三四五六七八九十元]\+\)年/、嘉永\1年、/g' "$file"
  
  # 3. 专有名词保护
  sed -i '' 's/大政奉环/、大政奉环、/g' "$file"
  sed -i '' 's/萨长同盟/、萨长同盟、/g' "$file"
  sed -i '' 's/萨英战争/、萨英战争、/g' "$file"
  sed -i '' 's/戊辰战争/、戊辰战争、/g' "$file"
  sed -i '' 's/西南战争/、西南战争、/g' "$file"
  sed -i '' 's/船中八策/、船中八策、/g' "$file"
  sed -i '' 's/鸟羽伏见/、鸟羽伏见、/g' "$file"
  sed -i '' 's/王政复古/、王政复古、/g' "$file"
  sed -i '' 's/明治维新/、明治维新、/g' "$file"
  sed -i '' 's/公武合体/、公武合体、/g' "$file"
  sed -i '' 's/尊王攘夷/、尊王攘夷、/g' "$file"
  sed -i '' 's/废藩置县/、废藩置县、/g' "$file"
  
  # 4. 人名保护（已有的，补充新的）
  # （已经在原始生成时处理）
  
  # 5. 清理多余的重复顿号
  sed -i '' 's/、、/、/g' "$file"
  sed -i '' 's/、、、/、/g' "$file"
  
  echo "✓ $file"
done

echo ""
echo "All TTS files updated with polyphone fixes"
echo "Backups saved as *.bak"
