import { Readability } from '@mozilla/readability';
import { JSDOM } from 'jsdom';
import TurndownService from 'turndown';

const turndown = new TurndownService({ headingStyle: 'atx', codeBlockStyle: 'fenced' });

export function extractContent(html, url, maxChars) {
  const dom = new JSDOM(html, { url });
  const reader = new Readability(dom.window.document);
  const article = reader.parse();
  
  if (!article) {
    // Fallback: get body text
    const body = dom.window.document.body;
    let text = body ? body.textContent.trim() : '';
    if (maxChars && text.length > maxChars) text = text.slice(0, maxChars);
    return { title: dom.window.document.title || '', content: text };
  }

  let markdown = turndown.turndown(article.content || '');
  const title = article.title || '';
  
  if (maxChars && markdown.length > maxChars) {
    markdown = markdown.slice(0, maxChars);
  }

  return { title, content: markdown };
}
