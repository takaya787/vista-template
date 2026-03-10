#!/usr/bin/env node
/**
 * Notion Click Fetcher - Navigate to a DB page, click a row, extract content
 *
 * Usage:
 *   node scripts/notion-click-fetch.mjs <notion-db-url> <row-text>
 */
import { chromium } from "playwright";
import { existsSync } from "fs";
import { resolve, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const STATE_FILE = resolve(__dirname, "..", ".notion-auth.json");

async function main() {
  const [dbUrl, rowText] = process.argv.slice(2);
  if (!dbUrl || !rowText) {
    console.error("Usage: node scripts/notion-click-fetch.mjs <notion-db-url> <row-text>");
    process.exit(1);
  }

  if (!existsSync(STATE_FILE)) {
    console.error("No saved session found. Run `node scripts/notion-login.mjs` first.");
    process.exit(1);
  }

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ storageState: STATE_FILE });
  const page = await context.newPage();

  console.error(`Fetching DB: ${dbUrl}`);
  await page.goto(dbUrl, { waitUntil: "domcontentloaded" });
  await page.waitForTimeout(5000);

  console.error(`Clicking row: ${rowText}`);
  const link = page.locator(`text=${rowText}`).first();
  await link.click();
  await page.waitForTimeout(5000);

  const url = page.url();
  console.error(`Page URL: ${url}`);

  const content = await page.evaluate(() => {
    const mainContent =
      document.querySelector(".notion-page-content") ||
      document.querySelector("main") ||
      document.body;
    return mainContent.innerText;
  });

  console.log(content);
  await browser.close();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
