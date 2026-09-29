#!/usr/bin/env node
/* QA de navegador sem Claude in Chrome (lições E9): roda scripts/qa_browser.js num Chromium local
   (Chrome, Chromium, Brave ou Edge) via puppeteer-core e tira capturas no meio (1,2 s) e no fim (4 s)
   de cada slide (lições E2).

   Uso (puppeteer-core instalado na pasta ATUAL, fora da skill):
     cd "$(mktemp -d)" && npm i puppeteer-core
     node <skill>/scripts/qa_headless.mjs <deck.html|url> <pasta_capturas> [n1 n2 ...]
   Sem números de slide = todos. Sai com código 1 se apthtmlQA.run() devolver problema.
   Navegador: variável CHROME_PATH ou detecção automática nos caminhos padrão do macOS e do Linux. */
import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';
import { pathToFileURL, fileURLToPath } from 'node:url';

const require = createRequire(pathToFileURL(path.join(process.cwd(), '/')));
let puppeteer;
try { puppeteer = require('puppeteer-core'); } catch {
  console.error('puppeteer-core não encontrado na pasta atual. Rode: cd "$(mktemp -d)" && npm i puppeteer-core');
  process.exit(2);
}

const CANDIDATES = [
  process.env.CHROME_PATH,
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  '/Applications/Chromium.app/Contents/MacOS/Chromium',
  '/Applications/Brave Browser.app/Contents/MacOS/Brave Browser',
  '/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge',
  '/usr/bin/google-chrome', '/usr/bin/chromium', '/usr/bin/chromium-browser', '/usr/bin/brave-browser',
].filter(Boolean);
const exe = CANDIDATES.find(p => fs.existsSync(p));
if (!exe) { console.error('Nenhum Chromium encontrado. Defina CHROME_PATH.'); process.exit(2); }

const [target, out, ...only] = process.argv.slice(2);
if (!target || !out) { console.error('uso: qa_headless.mjs <deck.html|url> <pasta_capturas> [slides...]'); process.exit(2); }
const url = /^https?:|^file:/.test(target) ? target : pathToFileURL(path.resolve(target)).href;
fs.mkdirSync(out, { recursive: true });
const QA = fs.readFileSync(path.join(path.dirname(fileURLToPath(import.meta.url)), 'qa_browser.js'), 'utf8');

const browser = await puppeteer.launch({ executablePath: exe, headless: 'new', args: ['--hide-scrollbars'] });
const page = await browser.newPage();
await page.setViewport({ width: 1920, height: 1080, deviceScaleFactor: 1 });
const logs = [];
page.on('console', m => { if (m.type() === 'error' && !/favicon/.test(m.text())) logs.push(m.text()); });
page.on('pageerror', e => logs.push(`pageerror: ${e.message}`));
await page.goto(url, { waitUntil: 'networkidle0' });
await page.evaluate(() => document.fonts.ready);
const fontOk = await page.evaluate(() => document.fonts.check('600 64px "Clash Display"'));
await page.evaluate(QA);
const n = await page.evaluate(() => document.querySelectorAll('.slide').length);
const issues = await page.evaluate(() => apthtmlQA.run());

const list = only.length ? only.map(Number) : [...Array(n).keys()].map(i => i + 1);
for (const i of list) {
  await page.evaluate(k => deck.show(k - 1), i);
  await new Promise(r => setTimeout(r, 1200));
  await page.screenshot({ path: path.join(out, `s${String(i).padStart(2, '0')}-meio.png`) });
  await new Promise(r => setTimeout(r, 2800));
  await page.screenshot({ path: path.join(out, `s${String(i).padStart(2, '0')}-fim.png`) });
}
await browser.close();

console.log(`navegador: ${exe}`);
console.log(`slides: ${n} · fonte do manual carregada: ${fontOk ? 'sim' : 'NÃO'} · capturas em ${out}`);
if (logs.length) console.log('console:\n  ' + logs.join('\n  '));
console.log(issues.length ? `QA de navegador: ${issues.length} problema(s)\n  ${issues.join('\n  ')}` : 'QA de navegador: OK');
process.exit(issues.length || !fontOk || logs.length ? 1 : 0);
