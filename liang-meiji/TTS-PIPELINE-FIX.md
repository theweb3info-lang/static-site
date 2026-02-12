# TTS处理流程问题与修复方案

## 发现的问题（2026-02-10）

经Copilot CLI + Qwen + 手动分析，发现**人名保护顿号（、name、）被TTS读出来**，这是导致11-胜海舟音频断句不自然的**最严重原因**。

## 根本原因

`protect-names.py` 脚本在TTS文本中添加的顿号（、坂本龙马、）本意是防止TTS切断人名，但Edge TTS会把顿号朗读出来，导致：
- "叫、坂本龙马、，" → TTS读成 "叫（停顿）坂本龙马（停顿），"
- 全文30+处，严重破坏听感

## 当前修复

创建 `fix-tts-pauses.sh` 脚本，事后清理TTS文本中的：
1. 人名顿号：`、人名、` → `人名`
2. 多音字标注：`(hang2)` → 删除
3. 年份格式：统一为西历在前
4. 数字量词：添加顿号分隔
5. 超长句子：拆分
6. 引语标记：统一
7. 重复标点：清理

## 长期解决方案

**修改 `preprocess-tts.sh` 流程：**

### 当前流程（有问题）
```
Step 0: Markdown清理
Step 1: 多音字校正
Step 2: 儿化音处理
Step 3: 人名保护（添加顿号）← 问题所在
Step 4: 括号清理
Step 5: 重复标点清理
```

### 修正后流程
```
Step 0: Markdown清理
Step 1: 多音字校正（保留标注，稍后清理）
Step 2: 儿化音处理
Step 3: 【删除此步骤】人名保护（不再需要）
Step 4: 括号清理（移到Step 3）
Step 5: 清理多音字标注括号（新增）
Step 6: 年份格式统一（新增）
Step 7: 数字量词顿号（新增）
Step 8: 超长句拆分（新增）
Step 9: 重复标点清理
```

## 人名切断问题

**原假设：** TTS会把"坂本龙马"切成"坂本龙-马"
**实际测试：** Edge TTS对中文人名切分**不需要**顿号保护，已经能正确识别4字人名

**结论：** `protect-names.py` 可以删除或仅用于HTML显示文本（非TTS）

## 实施步骤

1. ✅ 创建 `fix-tts-pauses.sh` 修复现有11篇
2. ⏳ 修改 `preprocess-tts.sh` 集成修复逻辑
3. ⏳ 批量重新生成01-11音频
4. ⏳ 测试新流程生成的文章（12-20）
5. ⏳ 确认听感改善后，删除 `protect-names.py`

## 经验教训

**"保护性"预处理要先测试TTS输出效果，不能假设。**

Edge TTS的中文处理能力比预期强：
- ✅ 人名识别：无需保护
- ✅ 专有名词：无需保护
- ❌ 数字量词：需要顿号分隔
- ❌ 多音字：需要拼音标注（但要在TTS前清理）
- ❌ 超长句：需要手动拆分

## 适用范围

此问题影响**所有已生成的TTS文件**（01-11），需要批量修复。

脚本使用：
```bash
cd /Users/andy_crab/.openclaw/workspace/liang-meiji
./fix-tts-pauses.sh articles/01-坂本龙马-tts.txt
./fix-tts-pauses.sh articles/02-西乡隆盛-tts.txt
# ... 依次修复所有文件
```

或批量：
```bash
for file in articles/{01..11}-*-tts.txt; do
  ./fix-tts-pauses.sh "$file"
done
```
