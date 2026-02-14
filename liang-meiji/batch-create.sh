#!/bin/bash
# 老梁明治维新 - Claude CLI 批量创作
# 循环创作直到所有文章完成

cd /Users/andy_crab/.openclaw/workspace/liang-meiji

while true; do
  # 找到下一篇未完成的
  NEXT=$(grep -n "^|" PROJECT.md | grep -v "✅.*✅" | grep -v "^.*|.*#.*|.*人物" | grep -v "^.*|.*---" | head -1)
  
  if [ -z "$NEXT" ]; then
    echo "🎉 所有文章已完成！"
    openclaw system event --text "🎉 老梁明治维新全部文章创作完成！" --mode now
    break
  fi
  
  # 提取编号和人名
  NUM=$(echo "$NEXT" | sed 's/.*| *\([0-9]*\) *|.*/\1/')
  NAME=$(echo "$NEXT" | sed 's/.*|[^|]*| *\([^|]*\) *|.*/\1/' | xargs)
  
  echo "📝 开始创作第${NUM}篇：${NAME}"
  
  claude -p "你是老梁风格写作专家。请完成以下任务：

1. 读取 PROJECT.md 了解项目规范
2. 读取 /Users/andy_crab/.openclaw/workspace/skills/liang/SKILL.md 了解老梁写作风格
3. 为第${NUM}篇「${NAME}」创作3000-4000字老梁风格文章
4. 保存到 articles/${NUM}-${NAME}.md
5. 运行 bash preprocess-tts.sh articles/${NUM}-${NAME}.md 生成TTS文本
6. 运行 edge-tts --voice zh-CN-YunjianNeural --rate=+3% --pitch=-8Hz --file articles/${NUM}-${NAME}-tts.txt --write-media articles/${NUM}-${NAME}.mp3
7. 复制文件到 ../static-site/meiji/ 并更新 index.html
8. cd ../static-site && git add -A && git commit -m '添加第${NUM}篇${NAME}' && git push
9. 更新 PROJECT.md 进度表，标记第${NUM}篇完成

规则：
- 文中不要出现'老梁''梁宏达'等字样
- 标题最多两个分句，不超过30字
- 完成后输出简短报告

开始执行。" --allowedTools "Bash,Read,Write,Edit" 2>&1 | tail -20
  
  echo "✅ 第${NUM}篇${NAME}完成"
  echo "---"
  
  # 通知 OpenClaw
  openclaw system event --text "✅ 老梁明治维新第${NUM}篇「${NAME}」已完成 (Claude CLI执行)" --mode now 2>/dev/null
  
  # 短暂休息避免rate limit
  sleep 10
done
