#!/usr/bin/env node
/**
 * Notion Page Fetcher - Read Notion pages using saved browser session
 *
 * Usage:
 *   node scripts/notion-fetch.mjs <notion-url>                    # Print page content as text
 *   node scripts/notion-fetch.mjs <notion-url> --screenshot       # Save screenshot
 *   node scripts/notion-fetch.mjs <notion-url> --output out.md    # Save content to file
 *
 * Prerequisites:
 *   Run `node scripts/notion-login.mjs` first to save your session.
 */

import { chromium } from "playwright";
import { existsSync, writeFileSync } from "fs";
import { resolve, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const STATE_FILE = resolve(__dirname, "..", ".notion-auth.json");

function parseArgs() {
  const args = process.argv.slice(2);
  const result = { url: null, screenshot: false, output: null };

  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--screenshot") {
      result.screenshot = true;
    } else if (args[i] === "--output" && args[i + 1]) {
      result.output = args[++i];
    } else if (!args[i].startsWith("--")) {
      result.url = args[i];
    }
  }

  return result;
}

async function fetchPage(url, options = {}) {
  if (!existsSync(STATE_FILE)) {
    console.error("No saved session found. Run `node scripts/notion-login.mjs` first.");
    process.exit(1);
  }

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ storageState: STATE_FILE });
  const page = await context.newPage();

  console.error(`Fetching: ${url}`);
  await page.goto(url, { waitUntil: "domcontentloaded" });

  // Wait for Notion content to load
  await page.waitForTimeout(5000);

  // Check if redirected to login
  if (page.url().includes("/login")) {
    console.error("Session expired. Run `node scripts/notion-login.mjs` to re-authenticate.");
    await browser.close();
    process.exit(1);
  }

  // Take screenshot if requested
  if (options.screenshot) {
    const screenshotsDir = resolve(__dirname, "..", "screenshots");
    const screenshotPath = resolve(
      screenshotsDir,
      `notion-screenshot-${Date.now()}.png`
    );
    await page.screenshot({ path: screenshotPath, fullPage: true });
    console.error(`Screenshot saved: ${screenshotPath}`);
  }

  // Extract page content
  const content = await page.evaluate(() => {
    // Get the main content area
    const mainContent =
      document.querySelector(".notion-page-content") ||
      document.querySelector('[class*="page-content"]') ||
      document.querySelector("main") ||
      document.body;

    // Extract text content with some structure
    function extractText(element, depth = 0) {
      const lines = [];
      const children = element.children;

      for (const child of children) {
        const tag = child.tagName?.toLowerCase();
        const text = child.textContent?.trim();

        if (!text) continue;

        // Skip navigation, sidebar elements
        if (
          child.getAttribute("role") === "navigation" ||
          child.classList?.contains("notion-sidebar")
        ) {
          continue;
        }

        // Headers
        if (tag === "h1" || child.classList?.contains("notion-header-block")) {
          lines.push(`\n# ${text}\n`);
        } else if (tag === "h2" || child.classList?.contains("notion-sub_header-block")) {
          lines.push(`\n## ${text}\n`);
        } else if (tag === "h3" || child.classList?.contains("notion-sub_sub_header-block")) {
          lines.push(`\n### ${text}\n`);
        }
        // Lists
        else if (tag === "ul" || tag === "ol") {
          const items = child.querySelectorAll(":scope > li");
          items.forEach((li) => {
            lines.push(`- ${li.textContent?.trim()}`);
          });
          lines.push("");
        }
        // Tables
        else if (tag === "table" || child.classList?.contains("notion-table-block")) {
          const rows = child.querySelectorAll("tr");
          rows.forEach((row, i) => {
            const cells = Array.from(row.querySelectorAll("td, th")).map(
              (c) => c.textContent?.trim() || ""
            );
            lines.push(`| ${cells.join(" | ")} |`);
            if (i === 0) {
              lines.push(`| ${cells.map(() => "---").join(" | ")} |`);
            }
          });
          lines.push("");
        }
        // Code blocks
        else if (child.classList?.contains("notion-code-block") || tag === "pre") {
          lines.push("```");
          lines.push(text);
          lines.push("```\n");
        }
        // Toggle blocks - extract summary
        else if (child.classList?.contains("notion-toggle-block")) {
          lines.push(`<details><summary>${text.split("\n")[0]}</summary>`);
          lines.push(text.split("\n").slice(1).join("\n"));
          lines.push("</details>\n");
        }
        // Regular blocks with nested content
        else if (children.length > 0 && depth < 3) {
          const nested = extractText(child, depth + 1);
          if (nested) lines.push(nested);
        }
        // Leaf text
        else if (text.length > 1) {
          lines.push(text);
        }
      }

      return lines.join("\n");
    }

    // Get page title
    const title =
      document.querySelector(".notion-page-block h1")?.textContent ||
      document.querySelector('[placeholder="Untitled"]')?.textContent ||
      document.title?.replace(" | Notion", "") ||
      "Untitled";

    const body = extractText(mainContent);

    return `# ${title}\n\n${body}`;
  });

  // Output
  if (options.output) {
    const outPath = resolve(process.cwd(), options.output);
    writeFileSync(outPath, content, "utf-8");
    console.error(`Content saved to: ${outPath}`);
  } else {
    // Print to stdout for piping
    console.log(content);
  }

  await browser.close();
}

const { url, screenshot, output } = parseArgs();

if (!url) {
  console.error("Usage: node scripts/notion-fetch.mjs <notion-url> [--screenshot] [--output file.md]");
  process.exit(1);
}

await fetchPage(url, { screenshot, output });
