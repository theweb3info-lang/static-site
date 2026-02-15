# App Promo Landing Page Template — Usage Guide

## Quick Start

1. Copy `app-promo-template.html` → `your-app.html`
2. Find & replace all `{{PLACEHOLDER}}` values
3. Customize CSS variables for your brand colors
4. Deploy

## All Placeholders to Replace

Use **Ctrl+F** (or Cmd+F) to find and replace each `{{...}}` token.

### Meta & Branding
| Placeholder | Description | Example |
|---|---|---|
| `{{APP_NAME}}` | App name | `AllerScan` |
| `{{APP_TAGLINE}}` | Short tagline for `<title>` | `Scan. Know. Eat Safe.` |
| `{{META_DESCRIPTION}}` | SEO description (150 chars) | `AI-powered food allergen scanner...` |
| `{{OG_IMAGE_URL}}` | Open Graph image URL (1200×630) | `https://example.com/og.png` |
| `{{CANONICAL_URL}}` | Page canonical URL | `https://example.com/` |
| `{{FAVICON_URL}}` | Favicon path | `/favicon.png` |
| `{{APP_ICON_EMOJI}}` | Emoji for nav logo icon | `🔍` |
| `{{CURRENT_YEAR}}` | Copyright year | `2026` |

### Colors (CSS Variables in `:root`)
| Variable | Description | Default |
|---|---|---|
| `{{ACCENT_COLOR}}` | Primary brand color | `#6366f1` (indigo) |
| `{{ACCENT_HOVER}}` | Lighter accent for gradients | `#818cf8` |
| `{{ACCENT_GLOW}}` | Accent with alpha for glows | `rgba(99,102,241,0.35)` |

### Hero Section
| Placeholder | Example |
|---|---|
| `{{HERO_BADGE_TEXT}}` | `Now available on iOS` |
| `{{HERO_TITLE_LINE1}}` | `Never worry about` |
| `{{HERO_TITLE_LINE2}}` | `food allergies again.` |
| `{{HERO_SUBTITLE}}` | `Scan any food label...` |
| `{{CTA_TEXT}}` | `Download Free` |
| `{{CTA_URL}}` | App Store URL |
| `{{SECONDARY_CTA_TEXT}}` | `Watch Demo` |
| `{{SECONDARY_CTA_URL}}` | `#how-it-works` |
| `{{APP_SCREENSHOT_PLACEHOLDER}}` | `<img src="screenshot.png" alt="...">` or text |

### All Other Sections
Every section follows the pattern: `{{SECTION_LABEL}}`, `{{SECTION_TITLE}}`, `{{SECTION_DESC}}`, then content-specific placeholders like `{{STEP_1_TITLE}}`, `{{FEATURE_1_EMOJI}}`, etc.

**Full list** — search for `{{` in the HTML to find every placeholder (~100 total).

### Footer
| Placeholder | Example |
|---|---|
| `{{PRIVACY_URL}}` | `/privacy` |
| `{{TERMS_URL}}` | `/terms` |
| `{{SUPPORT_EMAIL}}` | `hello@example.com` |

---

## Customizing Colors

Edit the CSS variables at the top of `<style>`:

```css
:root {
  --accent: #22c55e;           /* green brand */
  --accent-hover: #4ade80;
  --accent-glow: rgba(34,197,94,0.35);
}
```

**Preset palettes:**
- 🔵 Blue: `#3b82f6` / `#60a5fa` / `rgba(59,130,246,0.35)`
- 🟢 Green: `#22c55e` / `#4ade80` / `rgba(34,197,94,0.35)`
- 🟣 Purple: `#a855f7` / `#c084fc` / `rgba(168,85,247,0.35)`
- 🟠 Orange: `#f97316` / `#fb923c` / `rgba(249,115,22,0.35)`
- 🔴 Red: `#ef4444` / `#f87171` / `rgba(239,68,68,0.35)`

---

## Adding / Removing Sections

Each section is a self-contained block between HTML comments like:
```html
<!-- 6. FEATURE SHOWCASE -->
<section class="section" id="features">
  ...
</section>
```

- **Remove:** Delete the entire `<section>` block + its CSS if you want a smaller file
- **Add:** Copy any section, change the id, update nav links
- **Reorder:** Just move the `<section>` blocks around

---

## Best Practices

### Copywriting
- **Hero title:** 5-8 words max. Focus on the outcome, not the feature
- **CTA text:** Use action verbs: "Get Started Free", "Download Now", "Try for Free"
- **Problem section:** Make the pain visceral. The "Before" should feel frustrating
- **Social proof:** Specific numbers > vague claims. "12,847 users" > "thousands of users"

### Social Proof Tips
- Show App Store rating with star count
- "Featured by [publication]" badges
- Specific user count (update regularly)
- Real testimonials with names and photos

### CTA Optimization
- One primary CTA repeated 3x (hero, mid-page, final)
- App Store / Google Play buttons for mobile apps
- "Free" in CTA text increases conversion ~20%
- Add urgency sparingly: "Limited time offer" only if true

### Performance
- Inline all CSS (already done — single file)
- Optimize images: WebP, lazy loading
- No external fonts loaded (uses system stack) — add Google Fonts link if needed

---

## Phone vs Desktop Mockup

The template includes both mockup styles:
- **`.mockup-phone`** — for mobile apps (default in hero)
- **`.mockup-desktop`** — for web/desktop apps

Switch by replacing the mockup div in the hero section.

---

## Deploy Checklist

- [ ] All `{{...}}` placeholders replaced (search for `{{` — should return 0)
- [ ] Real screenshots added to mockup
- [ ] OG image created (1200×630)
- [ ] Favicon set
- [ ] All links working (CTA, footer, nav)
- [ ] Mobile tested (Chrome DevTools device mode)
- [ ] Page title & meta description set
- [ ] Analytics added (e.g., Plausible, Umami, or GA snippet before `</body>`)
- [ ] Privacy & Terms pages linked
- [ ] Tested on Safari, Chrome, Firefox
- [ ] Pushed to GitHub Pages / hosting
