# 🎯 超高质量App推广页生成提示词

> 使用方法：复制下方提示词，替换 `[方括号]` 中的内容，发给AI即可生成。

---

## 提示词

```
你是一个顶级产品设计师+前端工程师+增长黑客的结合体。请为以下App创建一个世界级的产品推广Landing Page。

## App信息
- **名称：** [App名称]
- **一句话描述：** [用一句话说清楚App做什么]
- **目标用户：** [谁会用？具体描述]
- **核心痛点：** [用户现在面对的最大问题是什么？]
- **核心差异化：** [和竞品比，最大的不同是什么？]
- **主要功能（3-6个）：** [列出功能名+一句话描述]
- **竞品（2-3个）：** [名称+它们的弱点]
- **定价方案：** [免费版/付费版功能对比+价格]
- **品牌调性：** [专业/友好/极客/温暖/高端？]
- **主色调：** [如：深蓝+绿色，或让AI建议]

## 设计标准（必须严格遵守）

### 视觉级别
对标 Linear.app / Raycast.com / Vercel.com / Arc.net 的设计水准。不是"还行"，是"让设计师看了都想截图"的级别。

### 技术约束
- 单文件HTML+CSS（可含少量vanilla JS用于导航栏滚动效果和FAQ展开）
- 不依赖任何外部资源（无CDN字体、无外部图片、无框架）
- 系统字体栈：-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif
- 完美响应式（移动端优先，断点：640px / 1024px）

### 配色系统
使用CSS变量定义完整配色，方便一键换色：
```css
:root {
  --bg-primary: #0a0a0b;        /* 页面背景（近黑不纯黑） */
  --bg-secondary: #111113;      /* 卡片/section背景 */
  --bg-elevated: #1a1a1f;       /* 悬浮元素背景 */
  --border: rgba(255,255,255,0.06); /* 精致边框 */
  --text-primary: #f5f5f7;      /* 主文字 */
  --text-secondary: #8a8a8e;    /* 副文字 */
  --accent: [品牌主色];          /* 品牌色 */
  --accent-glow: [品牌色低透明度]; /* 光晕色 */
  --success: #34d399;           /* 正面/安全 */
  --warning: #fbbf24;           /* 注意 */
  --danger: #f87171;            /* 危险/问题 */
}
```

### 必须包含的视觉效果
1. **光晕背景** — Hero区域用 radial-gradient 模拟品牌色光源扩散
2. **毛玻璃导航栏** — `backdrop-filter: blur(20px)` + 半透明背景
3. **精致边框** — 所有卡片用 `1px solid var(--border)` 
4. **悬浮动画** — 按钮hover上移2px+阴影增强，卡片hover微妙放大
5. **光泽扫过** — 关键卡片hover时有对角线光泽扫过（CSS伪元素+linear-gradient）
6. **渐变CTA** — 主按钮用品牌色渐变+圆角+大padding
7. **数字/emoji强调** — 用大号数字和emoji作为视觉锚点
8. **留白** — 每个section之间至少120px间距，内容不要拥挤

### 页面结构（12个Section，每个都要精致）

**① 导航栏 (Nav)**
- 固定顶部，毛玻璃背景
- Logo（文字即可）+ 3-4个锚点链接 + CTA按钮
- 滚动后背景加深（JS监听scroll）

**② Hero**
- 全屏高度（min-height: 100vh）
- 大标题：48-72px，font-weight: 700，letter-spacing: -0.02em
- Tagline：20-24px，var(--text-secondary)
- 两个CTA按钮（主+次）
- 右侧/下方：用CSS制作产品模拟界面（手机框架+内部UI模拟）
- 背景：品牌色光晕 radial-gradient

**③ 社会认证条 (Social Proof Bar)**
- 灰色小字："Trusted by X,XXX+ users worldwide"
- 5星评分 + "4.9 on App Store"
- 媒体/合作logo占位（用灰色方块+文字代替）

**④ 痛点阐述 (Problem)**
- 大标题："[描述问题的emotional标题]"
- Before/After对比：左侧=现在的痛苦方式（灰暗），右侧=用了App之后（品牌色高亮）
- 关键数据点：用大号数字+描述（如 "250M people worldwide..."）

**⑤ 使用流程 (How It Works)**
- 3-4步，每步：大数字 + 标题 + 描述 + 视觉装饰
- 步骤之间用虚线或渐变线连接
- 整体横向排列（移动端竖向）

**⑥ 功能展示 (Features — Bento Grid)**
- 不规则网格布局（2列，有的卡片占满宽度，有的占半宽）
- 每个功能卡片：emoji图标(48px) + 标题(20px bold) + 描述(16px) + 视觉装饰背景
- 最重要的功能占大卡片（span 2列），次要功能小卡片
- 卡片有 hover 光泽效果

**⑦ 竞品对比 (Comparison)**
- 表格形式：行=功能，列=我们 vs 竞品A vs 竞品B
- 我们的列用品牌色背景高亮
- 用 ✅ ❌ ⚠️ 标记
- 移动端横向可滚动

**⑧ 用户评价 (Testimonials)**
- 3张评价卡片
- 每张：头像圆圈(CSS生成首字母) + 名字 + 身份标签 + 5星 + 引用文字
- 卡片有微妙旋转角度（transform: rotate(-1deg)）增加真实感

**⑨ 定价 (Pricing)**
- 2-3档并排
- 推荐档：更大、品牌色边框、"Most Popular"badge、微妙上移
- 每档：名称 + 价格 + 功能列表（✅标记）+ CTA按钮
- 年付有"Save X%"标签

**⑩ FAQ**
- 用HTML `<details><summary>` 实现手风琴
- summary样式：大字+右侧箭头，展开时箭头旋转
- 5-8个常见问题
- 纯CSS动画展开

**⑪ 最终CTA (Final CTA)**
- 全宽渐变背景（品牌色暗色→亮色）
- 大标题："Ready to [动作]?"
- 副标题+两个CTA按钮
- 营造紧迫感但不油腻

**⑫ Footer**
- 简洁2-3列：产品链接 / 法律链接 / 社交媒体
- "Made with ❤️ for [社区名]"
- 版权信息

### 文案风格
- **标题：** 短、有力、emotional。不要generic的"The Best App For..."，要有观点
- **描述：** 具体、有数据、避免空洞形容词
- **CTA：** 动作导向（"Start Scanning Free" 而非 "Sign Up"）
- **语气：** 自信但不傲慢，专业但温暖，像一个聪明的朋友在推荐好东西

### 代码质量
- 语义化HTML标签（section, article, nav, header, footer, details）
- CSS变量统一管理颜色/间距
- 类名有意义（.hero, .features-grid, .pricing-card）
- 注释标记每个section的开始和结束
- 总文件大小控制在30KB以内

### 最终检查清单
□ 在375px宽度下完美显示
□ 在1440px宽度下完美显示
□ 所有hover效果流畅
□ FAQ展开收起正常
□ 导航栏固定且不遮挡内容
□ 无外部依赖，单文件可运行
□ 视觉级别对标Linear/Raycast
□ 文案有说服力，不是模板腔
□ CTA按钮位置合理，不少于4处
□ 配色和谐，品牌色使用恰到好处
```

---

## 快速使用示例

### 示例1：过敏原扫描App
```
名称：AllerScan
一句话描述：用AI识别食品标签和菜单中的过敏原
目标用户：食物过敏者及其家人（尤其是儿童家长）
核心痛点：读成分表费力、隐性过敏原难识别、外出就餐焦虑
核心差异化：AI理解隐性过敏原（如casein=牛奶），不只是关键词匹配
主要功能：AI标签扫描、条码查询、餐厅菜单扫描、家庭共享、SOS紧急按钮、离线模式
竞品：Soosee（只做高亮不理解含义）、Fig（社区导向不够工具化）
定价：Free 5次/天 | Pro $3.99/月 $29.99/年
品牌调性：专业可信赖+温暖关怀
主色调：深蓝+安全绿
```

### 示例2：合同AI阅读器
```
名称：ClauseGuard
一句话描述：拍照扫描任何合同，AI标出隐藏的风险条款
目标用户：租房者、自由职业者、小企业主
核心痛点：没人读合同但里面有坑（自动续费、竞业条款、涨价条款）
核心差异化：不只标注，还解释"这对你意味着什么"+给出谈判建议
主要功能：拍照扫描、风险评分、逐条解释、谈判话术生成、合同对比
竞品：DoNotPay（被FTC处罚已倒）、人工律师（太贵$300+/h）
定价：Free 3份/月 | Pro $7.99/月 $59.99/年
品牌调性：专业+聪明+略带幽默
主色调：深紫+金色
```

---

## 进阶技巧

### 如何让页面更有说服力
1. **数字 > 形容词**：说"3秒识别200+过敏原"而非"快速识别"
2. **用户语言 > 专业术语**：说"Eat out without the anxiety"而非"Allergen detection solution"
3. **Before/After对比**：最能打动人的section
4. **Loss aversion**：强调"不用会怎样"比"用了会怎样"更有力
5. **Social proof要具体**："Sarah, mom of 2 kids with peanut allergies"比"Happy User"有效100倍

### 如何实现高速增长的Landing Page设计
1. **首屏必须有CTA** — 用户不会滚到底
2. **每2-3个section放一次CTA** — 不同时机触发不同用户
3. **加入urgency但不油腻** — "Join 10,000+ families" vs "LIMITED TIME OFFER!!!"
4. **SEO友好** — 语义化HTML + 正确的heading层级 + meta description
5. **加载速度** — 单文件、无外部请求、<30KB = 首屏<1s
