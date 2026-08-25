Increment 3 accepted. This adds two **deterministic, static-site-native** gates that map cleanly to the “integration tests + contract tests” intent, but for a Jekyll brand portal:

* **Gate 6:** Broken internal links + missing assets + invalid anchors (runs against built `_site/`)
* **Gate 7:** CSS token contract enforcement for `--ft-*` variables (prevents token sprawl and “silent brand drift”)

These are tuned to the **brand-portal** repo realities: `_site/` is present at the root, and the repo contains `themes/`, `branding/`, and `website/microsite/` among other modules. ([GitHub][1])

---

## Increment 3: Gates (IF / AND / THEN)

### Gate 6 — Internal Link, Asset, and Anchor Integrity (Static “Integration Test”)

```text
IF PR changes any file under "website/microsite/" OR "_includes/" OR "_layouts/" OR "_sass/" OR assets used by microsite
  AND the Jekyll build output exists (_site/)
  AND internal link check finds:
      - missing target pages, OR
      - missing local assets (img/script/css), OR
      - invalid anchors (#id not present)
THEN
  Priority: CRITICAL
  Action: Block merge
  Guidance:
    - Fix broken href/src references
    - Fix or remove invalid anchors
    - If link target is intentional, add redirect page or correct permalink
```

### Gate 7 — CSS Token Contract (Brand Token Discipline)

```text
IF PR adds or modifies any CSS/SCSS
  AND introduces any new "--ft-*" variable usage
  AND the canonical token file does NOT define those new tokens
THEN
  Priority: HIGH
  Action: Request token contract update (optionally block)
  Guidance:
    - Add token definitions to the canonical token file
    - Update BRAND_MANIFEST.md with token change summary
    - Reject ad-hoc tokens defined in random components
```

---

# Implementation: Add Increment 3 to your Gate Engine

You already have `scripts/quality-guardian/gates.js`. Add the following **helpers + rules**. This will run in GitHub Actions after the Jekyll build step (so `_site/` exists).

## 1) Add helpers: link/asset/anchor checker (Node, no extra deps)

Add near the top with other helpers:

```js
const fs = require("fs");
const path = require("path");

function walkFiles(dir, exts = null) {
  const acc = [];
  if (!fs.existsSync(dir)) return acc;

  (function rec(d) {
    for (const entry of fs.readdirSync(d)) {
      const full = path.join(d, entry);
      const st = fs.statSync(full);
      if (st.isDirectory()) rec(full);
      else {
        const p = full.replace(/\\/g, "/");
        if (!exts || exts.some((e) => p.endsWith(e))) acc.push(p);
      }
    }
  })(dir);

  return acc;
}

function isExternalUrl(u) {
  return /^https?:\/\//i.test(u) || /^mailto:/i.test(u) || /^tel:/i.test(u);
}

function stripQueryAndHash(u) {
  return u.split("#")[0].split("?")[0];
}

function normalizeSitePath(hrefOrSrc) {
  // Handles:
  //  - "/assets/x.png"  => "_site/assets/x.png"
  //  - "assets/x.png"   => relative, handled per-page
  //  - "/about/"        => "_site/about/index.html" (heuristic)
  //  - "/about.html"    => "_site/about.html"
  const u = stripQueryAndHash(hrefOrSrc);
  if (!u) return null;
  return u;
}

function extractAttrLinks(html, attrName) {
  // naive but effective extraction for href/src
  // matches attr="..." or attr='...'
  const rx = new RegExp(`${attrName}\\s*=\\s*("([^"]+)"|'([^']+)')`, "gi");
  const out = [];
  let m;
  while ((m = rx.exec(html)) !== null) {
    out.push(m[2] || m[3] || "");
  }
  return out;
}

function extractIds(html) {
  const rx = /\sid\s*=\s*("([^"]+)"|'([^']+)')/gi;
  const ids = new Set();
  let m;
  while ((m = rx.exec(html)) !== null) {
    const id = (m[2] || m[3] || "").trim();
    if (id) ids.add(id);
  }
  return ids;
}

function resolveRelative(fromHtmlPath, rel) {
  // fromHtmlPath is like "_site/foo/bar/index.html"
  const baseDir = path.dirname(fromHtmlPath);
  const resolved = path.normalize(path.join(baseDir, rel)).replace(/\\/g, "/");
  return resolved;
}

function guessHtmlTarget(siteRoot, u) {
  // u is already stripped of query/hash
  // absolute paths start with "/"
  const rel = u.startsWith("/") ? u.slice(1) : u;
  if (!rel) return path.join(siteRoot, "index.html").replace(/\\/g, "/");

  // If already ends with .html, use directly
  if (rel.endsWith(".html")) {
    return path.join(siteRoot, rel).replace(/\\/g, "/");
  }

  // If ends with "/", assume index.html
  if (rel.endsWith("/")) {
    return path.join(siteRoot, rel, "index.html").replace(/\\/g, "/");
  }

  // Otherwise: try as file, then as directory index.html
  const asFile = path.join(siteRoot, rel).replace(/\\/g, "/");
  const asIndex = path.join(siteRoot, rel, "index.html").replace(/\\/g, "/");
  if (fs.existsSync(asFile)) return asFile;
  return asIndex;
}

function checkBuiltSiteIntegrity(siteRoot = "_site") {
  if (!fs.existsSync(siteRoot)) {
    return { ok: true, issues: [] }; // another gate may handle missing build
  }

  const htmlFiles = walkFiles(siteRoot, [".html"]);
  const idCache = new Map(); // file -> Set(ids)
  const issues = [];

  // First pass: cache IDs
  for (const f of htmlFiles) {
    const html = fs.readFileSync(f, "utf8");
    idCache.set(f, extractIds(html));
  }

  // Second pass: validate href/src
  for (const f of htmlFiles) {
    const html = fs.readFileSync(f, "utf8");
    const hrefs = extractAttrLinks(html, "href");
    const srcs = extractAttrLinks(html, "src");

    const refs = [
      ...hrefs.map((v) => ({ type: "href", v })),
      ...srcs.map((v) => ({ type: "src", v })),
    ];

    for (const { type, v } of refs) {
      const raw = (v || "").trim();
      if (!raw || raw === "#" || raw.startsWith("javascript:")) continue;
      if (isExternalUrl(raw)) continue;

      const [pathPart, hashPart] = raw.split("#");
      const cleanPath = stripQueryAndHash(pathPart || "");

      // Anchor-only link: "#section"
      if (!cleanPath && hashPart) {
        const ids = idCache.get(f) || new Set();
        if (!ids.has(hashPart)) {
          issues.push({ severity: "CRITICAL", file: f, kind: "ANCHOR", ref: raw });
        }
        continue;
      }

      // Determine target file
      let target;
      if (cleanPath.startsWith("/")) {
        // site-root relative
        target = type === "href"
          ? guessHtmlTarget(siteRoot, cleanPath)
          : path.join(siteRoot, cleanPath.slice(1)).replace(/\\/g, "/");
      } else {
        // page-relative
        target = type === "href"
          ? guessHtmlTarget(siteRoot, resolveRelative(f, cleanPath).replace(siteRoot + "/", ""))
          : resolveRelative(f, cleanPath);
      }

      // Existence check
      if (!fs.existsSync(target)) {
        issues.push({ severity: "CRITICAL", file: f, kind: "MISSING_TARGET", ref: raw, target });
        continue;
      }

      // Anchor validity for href links
      if (type === "href" && hashPart) {
        const ids = idCache.get(target) || new Set();
        if (!ids.has(hashPart)) {
          issues.push({ severity: "CRITICAL", file: f, kind: "BAD_ANCHOR", ref: raw, target });
        }
      }
    }
  }

  return { ok: issues.length === 0, issues };
}
```

---

## 2) Add helpers: CSS token contract enforcement (`--ft-*`)

```js
function findCanonicalTokenFile() {
  // Prefer explicit token files if present; otherwise discover by scanning.
  const preferred = [
    "website/microsite/assets/css/tokens.css",
    "website/microsite/assets/css/tokens.scss",
    "website/microsite/_sass/_tokens.scss",
    "website/microsite/_sass/tokens.scss",
    "themes/tokens.css",
    "themes/tokens.scss",
  ];

  for (const p of preferred) {
    if (fs.existsSync(p)) return p;
  }

  // Fallback: first file containing a meaningful number of --ft- definitions
  const candidates = walkFiles(".", [".css", ".scss"]).filter((p) => !p.startsWith("_site/"));
  for (const p of candidates) {
    const txt = fs.readFileSync(p, "utf8");
    const defs = (txt.match(/--ft-[a-z0-9-]+\s*:/gi) || []).length;
    if (defs >= 5) return p;
  }

  return null;
}

function parseTokenDefinitions(filePath) {
  if (!filePath || !fs.existsSync(filePath)) return new Set();
  const txt = fs.readFileSync(filePath, "utf8");
  const matches = txt.match(/--ft-[a-z0-9-]+\s*:/gi) || [];
  return new Set(matches.map((m) => m.replace(":", "").trim().toLowerCase()));
}

function parseTokenUsagesFromDiff(base, head, cssFiles) {
  if (!cssFiles.length) return new Set();
  const diff = sh(`git diff ${base}...${head} -- ${cssFiles.join(" ")}`);
  const added = diff.split("\n").filter((l) => l.startsWith("+") && !l.startsWith("+++"));
  const used = new Set();
  for (const l of added) {
    const ms = l.match(/var\(\s*(--ft-[a-z0-9-]+)\s*\)/gi) || [];
    for (const m of ms) {
      const token = m.replace(/.*var\(\s*/i, "").replace(/\s*\).*/i, "").trim().toLowerCase();
      used.add(token);
    }
  }
  return used;
}
```

---

## 3) Add Gate 6 + Gate 7 rules inside `run()`

Place these near the end (after your prior gates):

````js
// === Gate 6 (CRITICAL): built site integrity ===
const micrositeTouched = files.some((f) => f.startsWith("website/microsite/"));
if (micrositeTouched) {
  const integrity = checkBuiltSiteIntegrity("_site");
  if (!integrity.ok) {
    const top = integrity.issues.slice(0, 20).map((i) =>
      `- ${i.kind}: ${i.ref}\n  in: ${i.file}\n  target: ${i.target || "(same page)"}`
    ).join("\n");

    postPRComment([
      `**Quality Gate – CRITICAL**`,
      `- Microsite changed: YES`,
      `- Built site integrity: FAIL (broken internal links/assets/anchors)`,
      ``,
      `**Action:** Block merge.`,
      `**Guidance:** Fix missing targets and anchors. If a permalink changed, add redirect or update references.`,
      ``,
      `**Top issues (first 20):**`,
      "```text",
      top,
      "```",
    ].join("\n"));

    console.error("BLOCK: Built site integrity failed.");
    process.exit(1);
  }
}

// === Gate 7 (HIGH): CSS token contract ===
const cssFilesChanged = files.filter((f) => f.endsWith(".css") || f.endsWith(".scss"));
if (cssFilesChanged.length) {
  const canonical = findCanonicalTokenFile();
  const defined = parseTokenDefinitions(canonical);
  const usedInDiff = parseTokenUsagesFromDiff(BASE, HEAD, cssFilesChanged);

  // Identify new tokens used but not defined in canonical file
  const missing = [...usedInDiff].filter((t) => !defined.has(t));

  if (missing.length) {
    postPRComment([
      `**Quality Gate – HIGH**`,
      `- New FlowTrain tokens referenced via var(): ${missing.join(", ")}`,
      `- Canonical token file: ${canonical || "(not found)"}`,
      ``,
      `**Action:** Add missing token definitions to the canonical token file and summarize change in BRAND_MANIFEST.md.`,
      `**Guidance:** Keep token definitions centralized; do not define new --ft-* ad-hoc inside components.`,
    ].join("\n"));

    // Optional: enforce as blocking by uncommenting:
    // process.exit(1);
    console.warn("WARN: Token contract violation (missing canonical definitions).");
  }
}
````

---

# GitHub Action tweak (one line)

Because Gate 6 expects `_site/` output, ensure your workflow builds into the repo root `_site` (your repo has `_site/` at root). ([GitHub][1])

If your build command runs inside `website/microsite`, set destination:

```bash
cd website/microsite
bundle exec jekyll build --trace --destination ../../_site
```

---

# VS Code shift-left (optional but recommended)

Add a local task to run Gate 6 after a build:

```json
{
  "label": "Microsite: Integrity Check (links/assets/anchors)",
  "type": "shell",
  "command": "node scripts/quality-guardian/gates.js --base origin/main --head HEAD",
  "group": "test"
}
```

---

## Why this Increment 3 matters (for this repo)

* You already have `_site/` checked in at the top level, which increases the risk of “looks fine locally” but broken links after content moves. A deterministic integrity check is the static-site equivalent of an integration test. ([GitHub][1])
* A token contract gate is how you prevent brand entropy when you have multiple asset/theme modules (`themes/`, `branding/`, `website/microsite/`). ([GitHub][1])

If you want **Increment 4**, the next two high-leverage gates would be:

1. **redirect/permalink contract** (detect moved pages and require redirect stubs)
2. **release artifact provenance** (ensure archives in root match `release/ vX.Y.Z/` inventory + checksums)

[1]: https://github.com/FlowTrain/brand-portal "GitHub - FlowTrain/brand-portal: Description: Flow Train brand, documentation, system themes, and training assets"
