#!/bin/bash
# wechat-style.sh - Convert markdown to WeChat-styled HTML

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$HOME/.openclaw/workspace/static-site"
TEMPLATE_FILE="$SCRIPT_DIR/template.html"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Parse arguments
TITLE=""
INPUT_FILE=""
CONTENT=""
COVER_IMAGE=""
OUTPUT_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --title)
            TITLE="$2"
            shift 2
            ;;
        --input)
            INPUT_FILE="$2"
            shift 2
            ;;
        --content)
            CONTENT="$2"
            shift 2
            ;;
        --cover)
            COVER_IMAGE="$2"
            shift 2
            ;;
        --output)
            OUTPUT_NAME="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Interactive mode if no arguments
if [ -z "$TITLE" ]; then
    echo -e "${BLUE}WeChat Article Generator${NC}"
    echo ""
    read -p "Article title: " TITLE
fi

if [ -z "$CONTENT" ] && [ -z "$INPUT_FILE" ]; then
    echo ""
    echo "Paste markdown content (Ctrl+D when done):"
    CONTENT=$(cat)
fi

if [ -n "$INPUT_FILE" ] && [ -f "$INPUT_FILE" ]; then
    CONTENT=$(cat "$INPUT_FILE")
fi

if [ -z "$TITLE" ] || [ -z "$CONTENT" ]; then
    echo -e "${YELLOW}Error: Title and content are required${NC}"
    exit 1
fi

# Generate output filename
if [ -z "$OUTPUT_NAME" ]; then
    OUTPUT_NAME=$(echo "$TITLE" | sed 's/[^a-zA-Z0-9\u4e00-\u9fa5]/-/g' | sed 's/--*/-/g' | tr '[:upper:]' '[:lower:]')
    OUTPUT_NAME="${OUTPUT_NAME:0:50}.html"
fi

OUTPUT_FILE="$OUTPUT_DIR/$OUTPUT_NAME"

echo -e "${GREEN}Processing article...${NC}"

# Process markdown to HTML
# Convert markdown patterns to HTML
process_markdown() {
    local content="$1"
    
    # Headers
    content=$(echo "$content" | sed -E 's/^### (.+)$/<h3>\1<\/h3>/g')
    content=$(echo "$content" | sed -E 's/^## (.+)$/<h2>\1<\/h2>/g')
    content=$(echo "$content" | sed -E 's/^# (.+)$/<h1>\1<\/h1>/g')
    
    # Bold
    content=$(echo "$content" | sed -E 's/\*\*([^*]+)\*\*/<strong>\1<\/strong>/g')
    
    # Highlight (==text== or [[text]])
    content=$(echo "$content" | sed -E 's/==([^=]+)==/<span class="highlight">\1<\/span>/g')
    content=$(echo "$content" | sed -E 's/\[\[([^\]]+)\]\]/<span class="highlight">\1<\/span>/g')
    
    # Quotes
    content=$(echo "$content" | sed -E 's/^> (.+)$/<div class="quote">\1<\/div>/g')
    
    # Lists
    content=$(echo "$content" | sed -E 's/^- (.+)$/<li>\1<\/li>/g')
    content=$(echo "$content" | sed -E 's/^• (.+)$/<li>\1<\/li>/g')
    
    # Wrap consecutive <li> tags in <ul>
    content=$(echo "$content" | perl -0pe 's/(<li>.*?<\/li>\n)+/<ul>$&<\/ul>\n/gs')
    
    # Paragraphs (lines not already tagged)
    content=$(echo "$content" | sed -E 's/^([^<].+)$/<p>\1<\/p>/g')
    
    # Dividers
    content=$(echo "$content" | sed -E 's/^---$/<div class="divider">━━━<\/div>/g')
    content=$(echo "$content" | sed -E 's/^\*\*\*$/<div class="divider">━━━<\/div>/g')
    content=$(echo "$content" | sed -E 's/^━━━$/<div class="divider">━━━<\/div>/g')
    
    # Images
    content=$(echo "$content" | sed -E 's/!\[([^\]]*)\]\(([^)]+)\)/<img src="\2" alt="\1" class="section-img">/g')
    
    # Line breaks
    content=$(echo "$content" | sed -E 's/<\/p>\n<p>/<\/p>\n\n<p>/g')
    
    echo "$content"
}

HTML_CONTENT=$(process_markdown "$CONTENT")

# Generate cover image if not provided
if [ -z "$COVER_IMAGE" ]; then
    COVER_IMAGE="https://images.unsplash.com/photo-1551434678-e076c223a692?w=1200&q=80"
fi

# Create HTML file from template
cat > "$OUTPUT_FILE" << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$TITLE</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto", "Helvetica Neue", Arial, "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", sans-serif;
            line-height: 1.8;
            color: #3a3a3a;
            background: #f5f5f5;
            padding: 20px 0;
        }
        
        .article {
            max-width: 750px;
            margin: 0 auto;
            background: white;
            padding: 30px 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .cover-img {
            width: 100%;
            height: auto;
            border-radius: 8px;
            margin-bottom: 25px;
        }
        
        .section-img {
            width: 100%;
            height: auto;
            border-radius: 8px;
            margin: 25px 0;
        }
        
        h1 {
            font-size: 24px;
            font-weight: 700;
            color: #000;
            margin-bottom: 25px;
            line-height: 1.4;
            text-align: left;
        }
        
        h2 {
            font-size: 20px;
            font-weight: 700;
            color: #000;
            margin: 40px 0 20px;
            padding-left: 15px;
            border-left: 4px solid #07c160;
            text-align: left;
        }
        
        h3 {
            font-size: 18px;
            font-weight: 600;
            color: #000;
            margin: 30px 0 15px;
            text-align: left;
        }
        
        p {
            font-size: 16px;
            margin-bottom: 18px;
            text-align: left;
            color: #3a3a3a;
        }
        
        strong {
            font-weight: 700;
            color: #000;
        }
        
        .highlight {
            background: linear-gradient(180deg, rgba(255,255,255,0) 60%, #fef3ac 60%);
            padding: 2px 0;
        }
        
        .quote {
            background: #f7f8fa;
            border-left: 4px solid #07c160;
            padding: 18px 20px;
            margin: 25px 0;
            font-style: normal;
            color: #555;
            line-height: 1.8;
        }
        
        .divider {
            text-align: center;
            margin: 35px 0;
            color: #ccc;
            font-size: 18px;
            letter-spacing: 8px;
        }
        
        ul {
            margin: 18px 0 18px 25px;
            list-style: none;
        }
        
        ul li {
            position: relative;
            padding-left: 20px;
            margin-bottom: 12px;
            color: #3a3a3a;
        }
        
        ul li:before {
            content: "•";
            position: absolute;
            left: 0;
            color: #07c160;
            font-weight: bold;
        }
        
        .emphasis {
            font-weight: 600;
            color: #000;
        }
    </style>
</head>
<body>
    <div class="article">
        <h1>$TITLE</h1>
        
        <img src="$COVER_IMAGE" alt="Cover" class="cover-img">
        
        $HTML_CONTENT
    </div>
</body>
</html>
EOF

echo -e "${GREEN}✅ Generated: $OUTPUT_FILE${NC}"

# Commit and push
cd "$OUTPUT_DIR"
git add "$(basename "$OUTPUT_FILE")"
git commit -m "feat: add WeChat-styled article - $TITLE" || true
git push || true

echo ""
echo -e "${BLUE}📱 Preview URL:${NC}"
echo "https://theweb3info-lang.github.io/static-site/$(basename "$OUTPUT_FILE")"
echo ""
echo -e "${GREEN}✨ Done!${NC}"
