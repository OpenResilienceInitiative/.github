#!/usr/bin/env node
/**
 * Publishes an E2E run's artefacts to the Dreambau evidence gateway and binds
 * them to the pull request being tested.
 *
 * This talks to the gateway API directly rather than shelling out to the
 * `dreambau-evidence` CLI, so a CI runner needs no cross-repository install
 * step. GitHub work goes through `gh`, so no token is held here either.
 *
 * Nothing is published without an open pull request: a nightly run with no PR
 * becomes a private draft, which is the plan's rule and also the safe default
 * for a job that runs unattended.
 */

import { createHash } from "node:crypto";
import { readdirSync, readFileSync, statSync, openSync, readSync, closeSync } from "node:fs";
import { basename, extname, join, relative } from "node:path";
import { spawnSync } from "node:child_process";

const GATEWAY = (process.env.EVIDENCE_URL ?? "https://evidence.dreambau.com/api/v1").replace(/\/$/, "");
const PUBLIC_BASE = (process.env.EVIDENCE_PUBLIC_URL ?? "https://evidence.dreambau.com").replace(/\/$/, "");
const TOKEN = process.env.EVIDENCE_TOKEN ?? "";
const PART_SIZE = 64 * 1024 * 1024;
const MARKER_PREFIX = "dreambau-pr-evidence:v1";

const args = process.argv.slice(2);
const option = (name, fallback) => {
  const index = args.indexOf(`--${name}`);
  return index >= 0 ? args[index + 1] : fallback;
};
const flag = (name) => args.includes(`--${name}`);

function run(command, commandArgs, input) {
  const result = spawnSync(command, commandArgs, {
    encoding: "utf8",
    timeout: 120_000,
    ...(input === undefined ? {} : { input })
  });
  return { code: result.status ?? 1, stdout: String(result.stdout ?? ""), stderr: String(result.stderr ?? "") };
}

function parseJson(raw, what) {
  try {
    return JSON.parse(raw || "null");
  } catch {
    throw new Error(`could not read ${what}: the output was not valid JSON`);
  }
}

// --- what is being tested ---------------------------------------------------

function resolveTarget() {
  const head = run("git", ["rev-parse", "HEAD"]);
  if (head.code !== 0) throw new Error("not inside a Git repository");
  const commitSha = head.stdout.trim();

  const repository = process.env.GITHUB_REPOSITORY
    ?? run("gh", ["repo", "view", "--json", "nameWithOwner", "--jq", ".nameWithOwner"]).stdout.trim();
  if (!/^[A-Za-z0-9._-]+\/[A-Za-z0-9._-]+$/.test(repository)) {
    throw new Error(`could not resolve the repository (got "${repository}")`);
  }

  const explicit = option("pr");
  if (explicit !== undefined) {
    if (!/^[0-9]+$/.test(explicit)) throw new Error(`--pr expects a number, got "${explicit}"`);
    const view = run("gh", ["pr", "view", explicit, "--json", "number,state"]);
    if (view.code !== 0) throw new Error(`pull request #${explicit} was not found`);
    const parsed = parseJson(view.stdout, "the pull request");
    if (String(parsed.state).toUpperCase() !== "OPEN") {
      throw new Error(`pull request #${explicit} is ${String(parsed.state).toLowerCase()}; evidence only goes onto an open one`);
    }
    return { repository, commitSha, pullRequestNumber: parsed.number };
  }

  const branch = run("git", ["rev-parse", "--abbrev-ref", "HEAD"]).stdout.trim();
  if (!branch || branch === "HEAD") return { repository, commitSha, pullRequestNumber: null };
  const list = run("gh", ["pr", "list", "--state", "open", "--head", branch, "--json", "number"]);
  if (list.code !== 0) return { repository, commitSha, pullRequestNumber: null };
  const open = parseJson(list.stdout || "[]", "the open pull requests");
  if (!Array.isArray(open) || open.length === 0) return { repository, commitSha, pullRequestNumber: null };
  if (open.length > 1) throw new Error(`branch ${branch} has several open pull requests; pass --pr`);
  return { repository, commitSha, pullRequestNumber: open[0].number };
}

// --- what to attach ---------------------------------------------------------

const KIND_BY_EXTENSION = new Map([
  [".png", "screenshot"], [".jpg", "screenshot"], [".jpeg", "screenshot"], [".webp", "screenshot"],
  [".webm", "video"], [".mp4", "video"], [".mov", "video"],
  [".md", "document"], [".json", "log"], [".txt", "log"], [".log", "log"]
]);
const CONTENT_TYPE_BY_EXTENSION = new Map([
  [".png", "image/png"], [".jpg", "image/jpeg"], [".jpeg", "image/jpeg"], [".webp", "image/webp"],
  [".webm", "video/webm"], [".mp4", "video/mp4"], [".mov", "video/quicktime"],
  [".md", "text/markdown; charset=utf-8"], [".json", "application/json; charset=utf-8"],
  [".txt", "text/plain; charset=utf-8"], [".log", "text/plain; charset=utf-8"],
  [".zip", "application/zip"]
]);

/** Documents an E2E run produces. Missing ones are skipped, not invented. */
const REPORT_DOCUMENTS = ["REPORT.md", "RUN-STATE.md", "FIX-LOG.md", "SCREENSHOT-INDEX.md"];

function walk(directory, depth = 0) {
  if (depth > 4) return [];
  let entries;
  try {
    entries = readdirSync(directory, { withFileTypes: true });
  } catch {
    return [];
  }
  return entries.flatMap((entry) => {
    const path = join(directory, entry.name);
    if (entry.isDirectory()) return walk(path, depth + 1);
    return entry.isFile() ? [path] : [];
  });
}

/**
 * Reads the primary actor out of a session ledger, if one is present. Only the
 * synthetic identity is taken — never a password, a token or an OTP.
 */
function primaryActorFrom(ledgerPath) {
  let text;
  try {
    text = readFileSync(ledgerPath, "utf8");
  } catch {
    return undefined;
  }
  const email = text.match(/([a-z0-9._%+-]+@(?:oriso\.org|openresilience\.cc|trail\.ist))/i);
  if (!email) return undefined;
  const row = text.split("\n").find((line) => line.includes(email[1])) ?? "";
  const cells = row.split("|").map((cell) => cell.trim()).filter(Boolean);
  return {
    accountId: cells[0] || email[1],
    username: (cells.find((cell) => /^[a-z][a-z0-9_-]{2,}$/i.test(cell) && !cell.includes("@")) ?? email[1].split("@")[0]),
    syntheticEmail: email[1],
    role: cells.find((cell) => /consultant|counsellor|admin|user|client|agency/i.test(cell)) ?? "test user"
  };
}

function collectFiles(options) {
  const found = [];
  const seen = new Set();
  const add = (path, kind, caption) => {
    const key = path;
    if (seen.has(key)) return;
    try {
      if (!statSync(path).isFile()) return;
    } catch {
      return;
    }
    seen.add(key);
    found.push({ path, kind, caption });
  };

  for (const name of REPORT_DOCUMENTS) {
    for (const root of options.documentRoots) add(join(root, name), "document", name.replace(/\.md$/, ""));
  }
  if (options.reportArchive) add(options.reportArchive, "playwright-report", "Playwright report");

  for (const path of walk(options.resultsDirectory)) {
    const extension = extname(path).toLowerCase();
    const kind = path.endsWith("trace.zip") ? "trace" : KIND_BY_EXTENSION.get(extension);
    if (!kind) continue;
    add(path, kind, relative(options.resultsDirectory, path));
  }
  return found;
}

/** Playwright's JSON summary decides the result, when it is there. */
function resultFromReport(resultsDirectory) {
  for (const candidate of ["results.json", "report.json"]) {
    try {
      const parsed = JSON.parse(readFileSync(join(resultsDirectory, candidate), "utf8"));
      const failed = Number(parsed?.stats?.unexpected ?? 0) + Number(parsed?.stats?.flaky ?? 0);
      const unexpected = Number(parsed?.stats?.unexpected ?? 0);
      if (unexpected > 0) return "FAIL";
      return failed > 0 ? "FLAKY" : "PASS";
    } catch {
      // No summary here; try the next name.
    }
  }
  return null;
}

// --- gateway ----------------------------------------------------------------

async function call(path, init = {}) {
  const { expect = [200, 201], binary, ...request } = init;
  const response = await fetch(`${GATEWAY}${path}`, {
    ...request,
    headers: {
      authorization: `Bearer ${TOKEN}`,
      ...(request.body ? { "content-type": binary ? "application/octet-stream" : "application/json" } : {}),
      ...(init.headers ?? {})
    }
  });
  const text = await response.text();
  let payload = {};
  if (text) {
    try {
      payload = JSON.parse(text);
    } catch {
      throw new Error(`the gateway answered ${path} with HTTP ${response.status} and a non-JSON body`);
    }
  }
  if (!expect.includes(response.status)) {
    const reasons = payload.reasons ? ` (${payload.reasons.join(", ")})` : "";
    const findings = payload.findings ? ` (${payload.findings.map((entry) => entry.rule).join(", ")})` : "";
    throw new Error(`gateway ${path} returned HTTP ${response.status}: ${payload.error ?? "error"}${reasons}${findings}`);
  }
  return payload;
}

function readChunk(path, start, length) {
  const descriptor = openSync(path, "r");
  try {
    const buffer = Buffer.alloc(length);
    const read = readSync(descriptor, buffer, 0, length, start);
    return buffer.subarray(0, read);
  } finally {
    closeSync(descriptor);
  }
}

async function uploadFile(runId, file, actor) {
  const byteSize = statSync(file.path).size;
  if (byteSize === 0) return null;
  const digest = createHash("sha256");
  for (let offset = 0; offset < byteSize; offset += PART_SIZE) {
    digest.update(readChunk(file.path, offset, PART_SIZE));
  }
  const extension = extname(file.path).toLowerCase();
  const initialised = await call(`/runs/${runId}/files/init`, {
    method: "POST",
    body: JSON.stringify({
      kind: file.kind,
      filename: basename(file.path),
      caption: file.caption,
      contentType: CONTENT_TYPE_BY_EXTENSION.get(extension) ?? "application/octet-stream",
      byteSize,
      sha256: digest.digest("hex"),
      head: readChunk(file.path, 0, 4096).toString("base64"),
      ...(actor && file.kind === "screenshot" ? { primaryActor: actor } : {})
    }),
    expect: [200, 201, 422]
  });
  if (initialised.deduplicated || !initialised.file) return initialised.file ?? null;

  const parts = Math.max(1, Math.ceil(byteSize / PART_SIZE));
  for (let partNumber = 1; partNumber <= parts; partNumber += 1) {
    await call(`/runs/${runId}/files/${initialised.file.id}/parts/${partNumber}`, {
      method: "PUT",
      body: readChunk(file.path, (partNumber - 1) * PART_SIZE, PART_SIZE),
      binary: true,
      expect: [200]
    });
  }
  const completed = await call(`/runs/${runId}/files/${initialised.file.id}/complete`, {
    method: "POST",
    expect: [200, 422]
  });
  return completed.state === "ready" ? completed.file : null;
}

// --- pull request comment ---------------------------------------------------

const escapeMarkdown = (value) =>
  String(value).replace(/[\\`*_{}[\]()#+\-.!|<>]/g, (character) => `\\${character}`).replace(/\s+/g, " ").trim();

const ENVIRONMENT_LABELS = { local: "Local", "pre-dev": "Pre-Dev", dev: "Dev", "production-test": "Production test" };

function renderComment(run, files) {
  const lines = [
    `<!-- ${MARKER_PREFIX} run=${run.id} -->`,
    "",
    "## Verification evidence",
    "",
    "| Result | Environment | Commit | Source |",
    "|---|---|---|---|",
    `| ${run.result} | ${ENVIRONMENT_LABELS[run.environment] ?? run.environment} | \`${run.commitSha.slice(0, 7)}\` | GitHub Actions |`,
    ""
  ];
  const screenshots = files.filter((file) => file.kind === "screenshot");
  const videos = files.filter((file) => file.kind === "video");
  const others = files.filter((file) => file.kind !== "screenshot" && file.kind !== "video");

  for (const file of screenshots) {
    lines.push(`### ${escapeMarkdown(file.caption || file.filename)}`, "", `![${escapeMarkdown(file.caption || file.filename)}](${file.publicUrl})`, "");
  }
  for (const file of videos) {
    lines.push(`### ${escapeMarkdown(file.caption || file.filename)}`, "", `[▶ Watch video](${file.viewerUrl ?? file.publicUrl})`, "");
  }
  if (others.length > 0) {
    lines.push("### Reports and logs", "");
    for (const file of others) {
      const target = file.kind === "playwright-report"
        ? `${PUBLIC_BASE}/reports/${run.publicId}/${file.id}/index.html`
        : file.publicUrl;
      lines.push(`- [${escapeMarkdown(file.caption || file.filename)}](${target})`);
    }
    lines.push("");
  }
  lines.push(`[All evidence for this run](${PUBLIC_BASE}/r/${run.publicId})`, "");
  return `${lines.join("\n").trimEnd()}\n`;
}

function upsertComment(repository, pullRequestNumber, runId, body) {
  const listed = run("gh", [
    "api", "--paginate", `repos/${repository}/issues/${pullRequestNumber}/comments`,
    "--jq", ".[] | {id: .id, body: .body, html_url: .html_url}"
  ]);
  if (listed.code !== 0) throw new Error(`could not read pull request comments: ${listed.stderr.trim()}`);
  const marker = `<!-- ${MARKER_PREFIX} run=${runId} -->`;
  const existing = listed.stdout.split("\n").map((line) => line.trim()).filter(Boolean)
    .map((line) => parseJson(line, "a pull request comment"))
    .find((comment) => String(comment.body).includes(marker));

  const target = existing
    ? ["api", "--method", "PATCH", `repos/${repository}/issues/comments/${existing.id}`, "--input", "-"]
    : ["api", "--method", "POST", `repos/${repository}/issues/${pullRequestNumber}/comments`, "--input", "-"];
  const written = run("gh", target, JSON.stringify({ body }));
  if (written.code !== 0) throw new Error(`GitHub rejected the evidence comment: ${written.stderr.trim()}`);
  return { comment: parseJson(written.stdout, "the created comment"), created: !existing };
}

// --- main -------------------------------------------------------------------

async function main() {
  if (!TOKEN) throw new Error("EVIDENCE_TOKEN is required");

  const resultsDirectory = option("results", "test-results");
  const documentRoots = [option("docs", "."), process.env.E2E_DOCUMENT_ROOT].filter(Boolean);
  const target = resolveTarget();
  const draftOnly = target.pullRequestNumber === null;

  const files = collectFiles({
    resultsDirectory,
    documentRoots,
    reportArchive: option("report-archive")
  });
  if (files.length === 0) {
    console.log("no evidence artefacts found; nothing to publish");
    return 0;
  }

  const actor = primaryActorFrom(join(documentRoots[0], "SESSION-LEDGER.md"));
  const result = option("result") ?? resultFromReport(resultsDirectory) ?? "INFORMATIONAL";
  const environment = option("environment", "pre-dev");

  const run_ = await call("/runs", {
    method: "POST",
    body: JSON.stringify({
      project: "oriso",
      repository: target.repository,
      pullRequestNumber: target.pullRequestNumber,
      commitSha: target.commitSha,
      environment,
      title: option("title", "ORISO E2E nightly"),
      result,
      source: "github-actions"
    }),
    expect: [201]
  });
  console.log(`run ${run_.id} (${result}, ${files.length} artefact(s))`);

  const uploaded = [];
  for (const file of files) {
    try {
      const stored = await uploadFile(run_.id, file, actor);
      if (stored) uploaded.push(stored);
      else console.log(`  skipped ${basename(file.path)}`);
    } catch (error) {
      // One bad artefact must not lose the rest of the run.
      console.log(`  skipped ${basename(file.path)}: ${error.message}`);
    }
  }
  if (uploaded.length === 0) {
    console.log("no artefact survived processing; nothing to publish");
    return 1;
  }

  if (draftOnly) {
    console.log(`draft run ${run_.id}: no open pull request, so nothing was published`);
    return 0;
  }

  const publishBody = {
    repository: target.repository,
    pullRequestNumber: target.pullRequestNumber,
    commitSha: target.commitSha
  };
  const prepared = await call(`/runs/${run_.id}/publish`, {
    method: "POST",
    body: JSON.stringify({ ...publishBody, stage: "prepare" }),
    expect: [200]
  });
  const body = renderComment({ ...prepared, result, environment }, prepared.files);
  const { comment, created } = upsertComment(target.repository, target.pullRequestNumber, run_.id, body);
  await call(`/runs/${run_.id}/publish`, {
    method: "POST",
    body: JSON.stringify({ ...publishBody, stage: "commit", githubCommentUrl: comment.html_url }),
    expect: [200]
  });

  console.log(`${created ? "created" : "updated"} the evidence comment: ${comment.html_url}`);
  console.log(`${PUBLIC_BASE}/r/${prepared.publicId}`);
  return 0;
}

if (flag("help")) {
  console.log(`usage: node scripts/publish-evidence.mjs [options]

  --results <dir>          Playwright output directory (default test-results)
  --docs <dir>             where REPORT.md, RUN-STATE.md, FIX-LOG.md,
                           SCREENSHOT-INDEX.md and SESSION-LEDGER.md live
  --report-archive <file>  a zipped Playwright HTML report
  --result <PASS|FAIL|FLAKY|BLOCKED|INFORMATIONAL>
  --environment <name>     default pre-dev
  --title <text>
  --pr <number>            required when the branch has several open PRs

EVIDENCE_TOKEN is required. Without an open pull request the run stays a
private draft.`);
  process.exit(0);
}

main().then(
  (code) => { process.exitCode = code; },
  (error) => {
    console.error(error instanceof Error ? error.message : String(error));
    process.exitCode = 1;
  }
);
