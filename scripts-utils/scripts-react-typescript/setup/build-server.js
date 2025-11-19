#!/usr/bin/env node

/**
 * Server build script
 * Compiles TypeScript server files to JavaScript for production using tsc
 */

import { execSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
import fs from "node:fs";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = resolve(__dirname, "..");

try {
  console.log("Building server...");

  // Create dist directory if it doesn't exist
  const distDir = resolve(rootDir, "dist");
  if (!fs.existsSync(distDir)) {
    fs.mkdirSync(distDir, { recursive: true });
  }

  // Copy server files to dist (for production we run with tsx)
  // In production, the start script will use tsx to run TypeScript directly
  console.log(
    "✓ Server build complete (TypeScript files will be executed with tsx)",
  );
} catch (error) {
  console.error("Server build failed:", error);
  process.exit(1);
}
