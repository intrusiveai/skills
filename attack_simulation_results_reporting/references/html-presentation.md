# HTML presentation

## Visual foundation

Use bundled assets as a static report without a framework, server, or build pipeline.
The theme comes from INTRUSIVE.AI website `styles.css` at revision
`a44dcc589f69675a5bfb0143b7b2cb6891264151`. Its source checkout was
`~/workspaces/intrusiveai-engineering/www`; generated reports do not require it.
Keep brand tokens together for an explicitly requested future theme refresh.

| Role | Website value |
| --- | --- |
| Background / surface / raised surface | `#08090a` / `#0d0f11` / `#121416` |
| Main / supporting text | `#f2f2ee` / `#95979a` |
| Dividers | `#292c2f` |
| Accent / bright accent / dark accent | `#f54444` / `#ff6965` / `#45191b` |
| Headings | Instrument Sans, Arial, sans-serif |
| Body and data | IBM Plex Mono, SFMono-Regular, Consolas, monospace |
| Body type | `0.9rem`, weight 300, line height 1.7 |
| Page padding | `clamp(1.25rem, 4vw, 4.5rem)` |

Reuse restrained section scale and spacing rather than the marketing hero. Assets
use website-derived section headings, 1–1.5rem gaps, and responsive 1.5–3rem panels.
Do not shrink evidence to tiny decorative labels. Use readable supporting text and
explicit status words; red is a brand accent, not a universal severity signal.

Package locally available, appropriately licensed Instrument Sans and IBM Plex Mono
files and add local `@font-face` declarations matching their actual weights. Include
redistribution notices when required. Do not depend on Google Fonts/CDNs or download
fonts when opening a report. If files are unavailable, retain fallbacks and disclose
that exact typography was not reproduced. Bundled CSS has family stacks, not binaries.

## Populate and package

Copy `assets/report.html`, `assets/report.css`, and `assets/report.js` into a new report
directory. Fill every `{{...}}` slot; remove authoring comments and unused controls.
Structured slots expect author-generated HTML whose inserted text is escaped.
They are not raw evidence interpolation. `REPORT_TITLE` and `CAMPAIGN_LABEL` are
plain escaped text slots. Other sections follow the report-content guide.

Keep verified sources in a sibling `evidence/` directory or another stable relative
location delivered with the report. Copy a verified export unchanged there when
suitable; do not insert HTML into immutable generations or edit manifests. List
omitted attachments if a reduced package is requested. Links must survive moving
the package. Do not claim the HTML itself is a native deterministic generation.

Use one `<tr data-scenario-row data-coverage="...">` per scenario with `dispatched`,
`not-dispatched`, or `unknown` as coverage. Each row links to a unique detail ID such
as `scenario-001`. Derive fragment IDs from controlled indices, not raw source IDs.
Details use `<article class="scenario" id="scenario-001">`. The script filters only
index rows; all details remain available through direct links and print.

Columns are scenario, required/optional, execution coverage, and evidence assessment.
For objectives-only reports show zero scenarios, omit the empty table/filters, and
provide objective results. Evidence can use `<details><summary>…</summary>` with
`<pre>` text and a source link. Keep essential conclusions/limitations visible.

## Safe and accessible reading

- Escape evidence, bundle descriptions, model text, and diagnostics as text. Never
  use them in `innerHTML`, execute scripts, or render their Markdown/HTML as trusted
  markup. Adversarial strings must remain literal evidence.
- Construct links from verified local inventories, not embedded source URLs. Reject
  traversal, executable URL schemes, and source-controlled attributes. Do not preview
  captured HTML/SVG in frames. Link such files as clearly labeled downloads.
- Use no analytics, remote images, runtime fetches, or external scripts. Core content
  and anchor navigation must work from `file://` with JavaScript disabled.
- Preserve semantic headings, table headers, keyboard focus, a skip link, and labels.
  Meaning must not depend on color/hover. Honor reduced-motion preferences.
- Print all scenarios and expanded evidence details, omit controls, avoid clipped
  tables, and retain source labels. A light print palette is a readability adaptation.

## Verify the delivered report

Reconcile totals and associations with the accepted bundle and verified attempts.
Check citations and local links, missing evidence handling, bundle identity, and no
invented coverage from exploratory/rejected attempts. Remove remaining slots and
sample conclusions. Ensure recommendations have evidence and analysis is attributed.

Open locally at desktop/mobile widths; inspect screenshots, keyboard navigation,
filtering, empty results, direct links, long evidence wrapping, expanded details,
and print output. Check offline and JavaScript-disabled behavior. Include a literal
markup/script string in a temporary fixture to confirm it stays inert. Check source
hashes remain unchanged and report assets make no network requests.

When changing this skill, use a temporary representative report with observed,
inconclusive, and untested scenarios plus exploratory/rejected attempts; also check
zero scenarios. Label synthetic fixtures; never call them live campaign results.
Report actual verification scope; unavailable browser/evidence checks are limitations.
