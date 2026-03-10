#!/usr/bin/env node
/**
 * Notion Browser Login - Save authentication state for reuse
 *
 * Usage:
 *   node scripts/notion-login.mjs                    # Login to notion.so top page
 *   node scripts/notion-login.mjs <notion-url>      # Login and navigate to specific page
 *   node scripts/notion-login.mjs --check            # Check if saved state works
 *
 * You can also set NOTION_TARGET_PAGE env var as the default target page.
 *
 * This opens a browser window for you to log in to Notion manually.
 * Once logged in, the session state is saved to .notion-auth.json
 * so that notion-fetch.mjs can reuse it without re-authenticating.
 */

import { chromium } from "playwright";
import { existsSync } from "fs";
import { resolve, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const STATE_FILE = resolve(__dirname, "..", ".notion-auth.json");
const TARGET_PAGE = process.argv.find(a => a.startsWith('https://'))
  || process.env.NOTION_TARGET_PAGE
  || "https://www.notion.so";

async function login() {
  console.log("Opening browser for Notion login...");
  console.log("Please log in manually.\n");
  console.log("IMPORTANT: After logging in, wait until you can see the workspace page.");
  console.log("Press Ctrl+C in this terminal ONLY AFTER the page has fully loaded.\n");

  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();

  // Navigate to the target page — Notion will redirect to login if needed
  await page.goto(TARGET_PAGE);

  console.log("Waiting for you to log in and reach the workspace...");
  console.log("(The script will detect when you leave the login page)\n");

  // Wait until the URL no longer contains /login
  // This handles both notion.so and notion.com domains
  try {
    await page.waitForFunction(
      () => !window.location.href.includes("/login"),
      { timeout: 300_000 } // 5 minutes
    );

    console.log("Login detected! Waiting for page to fully load...");

    // Wait for token_v2 cookie — this is the key auth cookie
    console.log("Waiting for auth token...");
    let hasToken = false;
    for (let i = 0; i < 30; i++) {
      await page.waitForTimeout(2000);
      const cookies = await context.cookies();
      const token = cookies.find((c) => c.name === "token_v2");
      if (token) {
        hasToken = true;
        console.log("Auth token captured!");
        break;
      }
      console.log(`  waiting... (${i + 1}/30)`);
    }

    if (!hasToken) {
      console.log("WARNING: token_v2 cookie not found. Session may not work in headless mode.");
      console.log("Try navigating to a page in the workspace and waiting a moment.");
    }

    // Log the final URL
    console.log(`Current URL: ${page.url()}`);
  } catch (e) {
    console.log("Timeout waiting for login. Saving state anyway...");
  }

  // Save authentication state
  await context.storageState({ path: STATE_FILE });
  console.log(`\nAuthentication state saved to: ${STATE_FILE}`);
  console.log("You can now use notion-fetch.mjs to read Notion pages.");

  await browser.close();
}

async function check() {
  if (!existsSync(STATE_FILE)) {
    console.error("No saved state found. Run without --check first to log in.");
    process.exit(1);
  }

  console.log("Checking saved authentication state...");

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ storageState: STATE_FILE });
  const page = await context.newPage();

  await page.goto(TARGET_PAGE, { waitUntil: "domcontentloaded" });
  await page.waitForTimeout(5000);

  const url = page.url();
  if (url.includes("/login")) {
    console.log("Session expired. Run without --check to re-login.");
    await browser.close();
    process.exit(1);
  }

  console.log("Session is valid!");
  console.log(`Current URL: ${url}`);
  await browser.close();
}

const isCheck = process.argv.includes("--check");
if (isCheck) {
  await check();
} else {
  await login();
}
