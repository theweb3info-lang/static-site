---
name: chrome-extension
description: Build Chrome/Edge extensions (Manifest V3) with proper testing, fallbacks, and cross-browser support. Based on TabFlow project experience.
---

# Chrome Extension Development

Build production-ready Chrome extensions using Manifest V3. Covers common pitfalls, cross-browser compatibility (Chrome/Edge), and best practices.

## Project: TabFlow (Smart Tab Manager)

**Real-world example:** Auto-close inactive tabs with AI classification, notifications, and recovery list.

## Key Learnings & Pitfalls

### 1. Manifest V3 Requirements

**manifest.json structure:**
```json
{
  "manifest_version": 3,
  "name": "Your Extension",
  "version": "1.0.0",
  "permissions": ["tabs", "storage", "notifications", "alarms"],
  "background": {
    "service_worker": "background/service-worker.js",
    "type": "module"
  },
  "action": {
    "default_popup": "popup/popup.html"
  },
  "side_panel": {
    "default_path": "sidepanel/panel.html"
  }
}
```

**Pitfall:** Service workers are killed and restarted frequently. Do NOT rely on global state.

**Solution:** Use `chrome.storage` for persistent state, `chrome.alarms` for periodic tasks.

---

### 2. Side Panel API (Chrome 114+)

**Problem:** `sidePanel` API not supported in Edge or older Chrome.

**Always provide fallback:**
```javascript
document.getElementById('openSidePanel').addEventListener('click', async () => {
  try {
    if (chrome.sidePanel && chrome.sidePanel.open) {
      await chrome.sidePanel.open({ windowId: (await chrome.windows.getCurrent()).id });
    } else {
      throw new Error('sidePanel not supported');
    }
  } catch (err) {
    // Fallback: open as new tab
    chrome.tabs.create({ url: chrome.runtime.getURL('sidepanel/panel.html') });
  }
});
```

**Lesson:** Check API availability at runtime, not just build time.

---

### 3. Chrome Built-in AI (Gemini Nano)

**API:** `self.ai.languageModel` (Prompt API)

**Usage:**
```javascript
async function classifyTab(title, url) {
  if (!self.ai?.languageModel) {
    // Fallback to rule-based
    return classifyByRules(url);
  }

  try {
    const session = await self.ai.languageModel.create();
    const result = await session.prompt(`Classify this website: ${title} (${url})`);
    return parseCategory(result);
  } catch (err) {
    console.error('AI failed:', err);
    return classifyByRules(url);
  }
}
```

**Pitfall:** AI might be in "after-download" state (model downloading).

**Solution:** Always have a rule-based fallback. Never block on AI.

---

### 4. Notifications with Actions

**Problem:** Need user confirmation before closing important tabs.

**Permissions needed:**
```json
"permissions": ["notifications"]
```

**Implementation:**
```javascript
const notificationId = `tab-close-warning-${tabId}`;
chrome.notifications.create(notificationId, {
  type: 'basic',
  iconUrl: 'assets/icon-128.png',
  title: 'TabFlow: Important Tab About to Close',
  message: `"${tab.title}" has been inactive for ${minutes} min`,
  buttons: [
    { title: 'Keep' },
    { title: 'Close' }
  ],
  requireInteraction: false
});

chrome.notifications.onButtonClicked.addListener((notifId, buttonIndex) => {
  if (notifId.startsWith('tab-close-warning-')) {
    const tabId = parseInt(notifId.split('-').pop());
    if (buttonIndex === 0) {
      // Keep: add to temporary whitelist
      temporaryWhitelist.set(tabId, Date.now() + 3600000);
    } else {
      // Close
      chrome.tabs.remove(tabId);
    }
    chrome.notifications.clear(notifId);
  }
});
```

**Pitfall:** `requireInteraction: true` blocks everything. Use `false` + timeout.

---

### 5. Tab Tracking & Activity

**Problem:** Track when tabs were last active.

**Solution:** Listen to tab events + store timestamps.

```javascript
const tabActivity = new Map(); // tabId -> lastActiveTime

chrome.tabs.onActivated.addListener(({ tabId }) => {
  tabActivity.set(tabId, Date.now());
});

chrome.tabs.onRemoved.addListener((tabId) => {
  tabActivity.delete(tabId);
});

function getInactiveMinutes(tabId) {
  const lastActive = tabActivity.get(tabId);
  if (!lastActive) return Infinity; // Never seen, assume inactive
  return Math.floor((Date.now() - lastActive) / 60000);
}
```

**Pitfall:** Service worker restarts lose the Map. Save to `chrome.storage` periodically.

---

### 6. Pinned Tabs & Special URLs

**Never auto-close these:**
- Pinned tabs: `tab.pinned === true`
- Audio/video playing: `tab.audible === true`
- Special URLs: `chrome://`, `about:`, `devtools://`, `edge://`

```javascript
function shouldSkipTab(tab) {
  if (tab.pinned) return true;
  if (tab.audible) return true;
  const url = tab.url || '';
  if (url.startsWith('chrome://') || url.startsWith('about:') || 
      url.startsWith('devtools://') || url.startsWith('edge://') || 
      url === '' || url.startsWith('file://')) return true;
  return false;
}
```

---

### 7. Storage Management

**Problem:** `chrome.storage.local` has 5MB limit.

**Solution:** Limit stored items (e.g., max 200 closed tabs), use LRU.

```javascript
async function addClosedTab(tab) {
  const closed = await getClosedTabs();
  closed.unshift(tab); // Add to front
  const trimmed = closed.slice(0, MAX_CLOSED_TABS); // Keep only N
  await chrome.storage.local.set({ closedTabs: trimmed });
}
```

---

### 8. XSS Prevention

**Problem:** User-generated content (tab titles, URLs) could contain HTML.

**Never use `innerHTML` for user content:**
```javascript
// ❌ WRONG
el.innerHTML = `<div>${tab.title}</div>`;

// ✅ CORRECT
function escapeHtml(str) {
  const div = document.createElement('div');
  div.textContent = str;
  return div.innerHTML;
}
el.innerHTML = `<div>${escapeHtml(tab.title)}</div>`;
```

---

### 9. Testing Strategy

**Unit tests (run with Node.js):**
- Test logic modules separately
- Mock Chrome APIs

**Example test:**
```javascript
// test-storage.js
globalThis.chrome = {
  storage: {
    local: {
      data: {},
      async get(keys) {
        return keys.reduce((acc, k) => ({ ...acc, [k]: this.data[k] }), {});
      },
      async set(obj) {
        Object.assign(this.data, obj);
      }
    }
  }
};

import { getSettings, setSettings } from '../utils/storage.js';

async function testStorage() {
  await setSettings({ threshold: 45 });
  const s = await getSettings();
  console.assert(s.threshold === 45, 'Settings mismatch');
}
```

**Manual testing:**
1. Load unpacked extension
2. Test in both Chrome and Edge
3. Test on Windows/Mac/Linux if possible

---

### 10. Distribution

**Problem:** Gmail blocks `.zip` attachments.

**Solutions:**
1. Rename to `.dat` (still might be blocked)
2. Host on GitHub Pages or similar
3. Use Google Drive sharing link

**We used:** GitHub Pages static hosting
```bash
cp extension.zip /path/to/static-site/
cd /path/to/static-site
git add extension.zip && git commit -m "add extension" && git push
# URL: https://your-username.github.io/static-site/extension.zip
```

---

### 11. Git Workflow (Conventional Commits)

**Use Conventional Commits for clean history:**
```
feat: add notification for important tabs
fix: improve Recovery List fallback for Edge
test: add unit tests for AI engine
docs: update README
chore: bump version to 1.6.0
```

**Always commit by feature:**
- Don't bundle multiple features in one commit
- Each bug fix is a separate commit
- Tag releases: `git tag v1.6.0`

---

## Edge vs Chrome Compatibility

| Feature | Chrome 114+ | Edge | Fallback |
|---------|-------------|------|----------|
| `chrome.sidePanel` | ✅ | ❌ | Open as new tab |
| `self.ai` (Gemini Nano) | ✅ | ❌ | Rule-based classification |
| Notifications | ✅ | ✅ | - |
| Service Worker | ✅ | ✅ | - |

**Rule:** Always test in both browsers before releasing.

---

## File Structure

```
extension/
├── manifest.json
├── background/
│   └── service-worker.js      # Background tasks, alarms
├── popup/
│   ├── popup.html
│   ├── popup.css
│   └── popup.js               # Popup UI
├── sidepanel/
│   ├── panel.html
│   ├── panel.css
│   └── panel.js               # Side panel / recovery list
├── options/
│   ├── options.html
│   ├── options.css
│   └── options.js             # Settings page
├── utils/
│   ├── storage.js             # chrome.storage wrapper
│   ├── tab-tracker.js         # Tab activity tracking
│   ├── ai-engine.js           # AI + fallback
│   └── constants.js
├── tests/
│   ├── test-storage.js
│   ├── test-tab-tracker.js
│   └── run-tests.js
└── assets/
    └── icon-*.png             # 16/32/48/128px
```

---

## Common Commands

**Load extension:**
```
chrome://extensions → Developer mode → Load unpacked
```

**Reload after changes:**
Click reload button or `Ctrl+R` in extensions page

**View service worker logs:**
Click "Service Worker" link in extension details

**Debug popup:**
Right-click extension icon → Inspect popup

---

## Checklist Before Release

- [ ] Manifest version bumped
- [ ] All permissions justified
- [ ] No console errors in service worker
- [ ] Tested in Chrome
- [ ] Tested in Edge
- [ ] Unit tests passing
- [ ] README updated
- [ ] Git tagged (e.g., `v1.6.0`)
- [ ] Zip created and hosted

---

## Resources

- [Chrome Extensions Docs](https://developer.chrome.com/docs/extensions/)
- [Manifest V3 Migration](https://developer.chrome.com/docs/extensions/migrating/)
- [Chrome Built-in AI](https://developer.chrome.com/docs/ai/built-in)
- [Service Workers](https://developer.chrome.com/docs/extensions/mv3/service_workers/)

---

## Real Issues We Hit

### Issue 1: Recovery List button not working in Edge
**Symptom:** Clicking "Recovery List" does nothing.
**Cause:** Edge doesn't support `chrome.sidePanel.open()`.
**Fix:** Wrap in try-catch, fallback to `chrome.tabs.create()`.

### Issue 2: AI classification blocking close
**Symptom:** Tabs not closing because AI is slow.
**Cause:** Awaiting AI before closing.
**Fix:** Run AI async, use cached result or fallback immediately.

### Issue 3: Last tab in window gets closed
**Symptom:** Closing all tabs kills the browser window.
**Cause:** Didn't check if it's the last tab.
**Fix:** Count tabs in window, skip if only 1 left.

### Issue 4: Pinned tabs still auto-closed
**Symptom:** Pinned tabs closed despite being pinned.
**Cause:** Forgot to check `tab.pinned`.
**Fix:** Add `if (tab.pinned) return;` in cleanup.

### Issue 5: Tabs playing audio auto-closed
**Symptom:** YouTube tab closed while watching.
**Cause:** Didn't check `tab.audible`.
**Fix:** Add `if (tab.audible) return;` in cleanup.

### Issue 6: XSS in whitelist domain display
**Symptom:** User adds domain with `<script>`, it executes.
**Cause:** Used `innerHTML` for user input.
**Fix:** Use `textContent` or escape HTML.

---

## Example: TabFlow Project

**Final stats:**
- 18 files, ~2000 lines of code
- 52 unit tests, all passing
- 6 bugs fixed during QA
- Supports Chrome 114+ and Edge (with fallbacks)

**Version history:**
- v1.0: Basic auto-close + recovery
- v1.1: Fixed critical bugs (last tab, audio)
- v1.6: Notifications for important tabs, Edge support

**Key success factors:**
- Always have fallbacks (AI, sidePanel)
- Test edge cases (last tab, pinned, audio)
- Git discipline (clean commits, tags)
- Cross-browser testing before each release
