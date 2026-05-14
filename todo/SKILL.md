---
name: todo-journal
description: Personal task-tracking journal. Use when the user asks to log task start/stop/pause, record a working note, save an inbound request (Slack/email) as a task, generate a daily standup report, query task history, or update task status. Timestamps are recorded on every line for chronological audit, but no clocking or elapsed-time computation is performed. The system is markdown-only, single-user, file-based.
---

# TODO Journal — conventions for AI agents

A personal, file-based, markdown-only task tracker. Org-mode in spirit. The user logs everything chronologically into one journal file, with the open task list pinned at the top. Per-task context files are optional — created only when a task accumulates substantial info. Every line is timestamped for ordering and audit, but the system does **not** clock time or compute elapsed durations — timestamps are positional, not metered.

**Source of truth = `journal.md`.** Per-task context files in `tasks/<id>.md` are optional projections that only exist when there's substantial context to capture.

## On invocation

Before doing anything stateful:

1. Read the `## Active` section at the top of `journal.md` to see open tasks and their states.
2. Read today's section in `journal.md` (the last `## YYYY-MM-DD` header to EOF) for recent context.
3. Read `tasks/<id>.md` only for task IDs the user explicitly mentions or that are clearly relevant. Many tasks won't have a file at all — that's the default.
4. Use `today = 2026-04-28`-style absolute dates from the environment, not relative ones.

Do not preload all task files. They are referenced on demand.

## File layout

```
Todo/
├── SKILL.md              # this file
├── journal.md            # primary file — Active list at top, then chronological log
├── howto.md              # personal cheatsheet — commands, tutorials, snippets to recall later
├── tasks/                # optional per-task context files (only when needed)
│   └── <task-id>.md
├── meetings/             # plain transcripts/notes
│   └── YYYY-MM-DD-<slug>.md
└── archive/              # closed quarters, optional
    └── YYYY-Qn-journal.md
```

## journal.md structure

Two parts: a pinned `## Active` list at the top, then a chronological day-by-day log.

```markdown
# Journal

## Active

- DOING - Integration test coverage (#integration-test-coverage) → [[tasks/integration-test-coverage]]
- DOING - User profile page (#user-profile-page) → [[tasks/user-profile-page]]
- REVIEW - Some review task (#some-review-task) → [[tasks/some-review-task]]
- TODO - Quick CSS tweak (#quick-css-tweak)

---

## 2026-04-28 Tuesday

**Plan:** finish #solana-retry, prep audit, handle inbound.

- `09:15` [START ] #solana-retry — Ádám: exp backoff
- `09:30` [NOTE  ] #solana-retry — root cause search underway
- `10:45` [PAUSE ] #solana-retry
- `11:00` [WORK  ] Email triage: KYC, Stripe
- `11:30` [MEET  ] Standup → [[meetings/2026-04-28-standup]]
- `13:00` [RESUME] #solana-retry
- `14:30` [DONE  ] #solana-retry — fix merged, tests green

  Optional longer comment, indented two spaces, blank line above and
  below. Multi-line OK. This block does NOT appear in single-line grep
  output, which is fine — the headline above is the audit trail.

- `14:35` [WORK  ] CI node bump

**EOD:** #solana-retry done; #user-profile-page in TODO.
```

### Active list format

Each line: `- STATE - Human-readable name (#slug-id) → [[tasks/<id>]]`

- `STATE` is one of `TODO`, `DOING`, `PAUSED`, `BLOCKED`, `REVIEW` — uppercase, separated from name by ` - ` (space-dash-space).
- Human-readable name is the descriptive title (the same as it would appear in a daily standup report).
- `(#slug-id)` in parentheses is the canonical task ID — needed to cross-reference journal entries via `grep '#slug-id'`.
- `→ [[tasks/<id>]]` wikilink **only when a task file exists**. Tasks without files (most short tasks) just end after the slug.

The Active list is updated on every state-changing verb (`[NEW   ]`, `[START ]`, `[PAUSE ]`, `[RESUME]`, `[BLOCK ]`, `[REVIEW]`, `[DONE  ]`, `[CANCEL]`). DONE/CANCELED tasks are removed from Active (their existence lives in the journal's chronological history).

The list is grouped/ordered freely — typically by state (DOING first, then REVIEW, PAUSED, BLOCKED, TODO), then by recency. This is for human glanceability; not critical for correctness.

### Line structure (event lines, rigid)

```
- `HH:MM` [VERB  ] [#task-id] [— content]
```

| Field | Width | Required |
|---|---|---|
| time in backticks | 5 chars (`HH:MM`) | yes — every line |
| `[VERB  ]` | 8 chars (6 inside + brackets) | yes |
| `#task-id` | variable | iff line refers to a task |
| ` — content` | variable | optional; em-dash separator only when content present |

**Why these rules:**
- Time only on event lines: the date is already in the day's `## YYYY-MM-DD` header, so prefixing every line with the full ISO date is redundant. The day-header anchor is enough — when grepping for a task ID, run `grep -n` and let the surrounding header give you the date, or use `awk '/^## /,/^## /'` to slice a day.
- Brackets around the verb because rendered markdown collapses runs of spaces; brackets keep the column visually fixed in both raw and rendered views.
- Verb right-padded to 6 chars inside brackets (longest words: `RESUME`, `REVIEW`, `CANCEL`).
- **Where full ISO timestamps still apply:** `## Notes` bullets in `tasks/<id>.md` (and similar event-tracking subsections like `## Review feedback`) keep the full `YYYY-MM-DD HH:MM` since they are not nested under a day header. Task-file timestamps must still match the journal entry that triggered the addition.

## Verb keywords

Each is exactly 6 characters, right-padded with spaces inside `[ ]`.

| Verb | Meaning | State transition |
|---|---|---|
| `[NEW   ]` | task created | (creates task in `TODO`) |
| `[START ]` | begin work first time | TODO → DOING |
| `[PAUSE ]` | stop, will resume later | DOING → PAUSED |
| `[RESUME]` | continue paused/blocked/review task | PAUSED → DOING (or BLOCKED → DOING, REVIEW → DOING) |
| `[BLOCK ]` | external blocker hit | * → BLOCKED |
| `[REVIEW]` | submitted for review (PR opened) | DOING → REVIEW |
| `[DONE  ]` | finished | * → DONE |
| `[CANCEL]` | abandoned | * → CANCELED |
| `[NOTE  ]` | working note, no state change | (state unchanged) |
| `[MEET  ]` | meeting | usually no `#task-id` |
| `[WORK  ]` | non-task activity (email, admin, ad-hoc) | usually no `#task-id` |

The current state of a task = the state implied by the most recent verb on a journal line containing that `#task-id`. The `## Active` list at the top of the journal mirrors this.

States: `TODO`, `DOING`, `PAUSED`, `BLOCKED`, `REVIEW`, `DONE`, `CANCELED`.

## Task IDs

| Form | Example | When |
|---|---|---|
| Slug (default) | `#solana-retry` | Memorable, descriptive — default choice. |
| Numeric | `#042` | Quick throwaway tasks where naming is overhead. |
| Hybrid | `#042-solana-retry` | When a sequence number matters AND name helps. |

**Rules:**
- `#` followed only by lowercase ASCII alphanumerics and hyphens.
- Spaces in task names → hyphens.
- No two open tasks may share an ID. (Closed tasks may reuse if context makes it unambiguous, but prefer not to.)
- ID = filename stem (when a file exists): `#solana-retry` → `tasks/solana-retry.md`.
- **Sub-items of an existing task do not get their own task ID.** If something is a scope item, follow-up, or sub-component of an existing in-flight task (e.g. "fix the missing tag on the payment history table" relative to the payment-history task), don't spin off a new `#slug` for it. Mention it in the parent task's journal `[NOTE  ]` lines, and — if the parent has a task file — capture it in the parent's `## Notes` or a `## Scope items` section. Spinning off separate IDs for sub-items fragments the tracking, hides the parent–child relationship, and clutters the Active list with items that the team would never read as standalone work. Promote a sub-item to its own task only if it later grows scope beyond the parent (e.g. it becomes a cross-cutting refactor, gets its own PR independent of the parent, or someone else owns it).

## Priority

Three levels: `HIGH`, `NORMAL` (default), `LOW`. Set only when the user explicitly asks; otherwise the task is `NORMAL` and the priority field is omitted from the Active list line.

**Storage — `## Active` list.** Priority lives between the state and the title as a dash-separated field. `NORMAL` is implicit (no marker):

```
- DOING - HIGH - Stripe webhook prod fix (#stripe-webhook-prod)
- DOING - Some normal task (#some-normal-task)
- TODO - LOW - Polish onboarding copy (#onboarding-copy-polish)
```

**Ordering inside a state group.** Within each state in the Active list, sort `HIGH` first, then `NORMAL`, then `LOW`. Within a priority bucket, order by recency (most recent first) — same as before.

**Changing priority.** Log it with a `[NOTE  ]` line so the change is grep-able, and update the Active line:

```
- `2026-05-06 14:30` [NOTE  ] #foo — priority changed: NORMAL → LOW
```

**Emergencies (`!!!`) are independent of priority.** `!!!` still marks production-down / drop-everything situations and can decorate any priority. A HIGH-priority task is *not* automatically `!!!`; conversely a NORMAL task can be `!!!` if it's an emergency. Use `!!!` inline as before:

- In task file H1 (if file exists): `# !!! #stripe-webhook-prod — production down`
- In the `## Active` list: `- TODO - HIGH - !!! Stripe webhook prod down (#stripe-webhook-prod)`
- Optionally in journal lines: include `!!!` after the em-dash so `grep '!!!' journal.md` surfaces firefighting history.

No `Deadline:` or `Deps:` fields. Write them as prose in the task file's `## Notes` section if the task has a file, or as a `[NOTE  ]` line in the journal if not.

## tasks/&lt;id&gt;.md — optional context files

**Default: no task file.** Most tasks are short-lived efforts that need no context beyond a single journal line. Don't create a task file for them.

**Create a task file only when there is real *information or knowledge* to record** — something that would be lost if it lived only in the chronological journal. Specifically:
- An inbound request (Slack/email) needs to be quoted verbatim.
- A non-trivial decision, design choice, or trade-off is being captured.
- Scope, code snippets, technical findings, links/resources, or open questions are accumulating.
- Multi-paragraph or multi-bullet content that would clutter the journal.

**Do NOT create a task file just because:**
- A status update is being logged (paused, blocked, resumed, "will continue tomorrow", "PR is huge", etc.) — these are journal `[NOTE  ]` lines, nothing more.
- A short single-sentence comment is being added explaining or qualifying the current state.
- A PR link or external URL is mentioned in passing — PR links live inline in the journal anyway (see Editing rules), and a single URL is not "accumulated resources".
- Creating a file feels "tidier" — it isn't, if there's nothing in the file beyond what already exists in the journal.

The rule of thumb: **does this note record information / knowledge, or does it just describe the current status?** Information → file. Status → journal-only. When unsure, lean toward journal-only; the file can always be created later, the moment something file-worthy actually appears.

If a task starts file-less and later accumulates real context (per the criteria above), create the file at that point — append a Notes bullet for what you know, then carry on.

```markdown
# #user-profile-page — User profile page  `#frontend` `#dashboard`

- **Created:** 2026-04-28 14:22
- **Source:**  Slack DM from <name>

## Summary
One paragraph of what this is.

## Notes
- `2026-04-28 11:11` Free-form bullets, each prefixed with the timestamp
  matching the corresponding journal entry. Deadlines, dependencies,
  links to other tasks, decisions, milestones, anything goes here as prose.

## Open questions
- Things to clarify before / during work.

## Original message
> Verbatim quote of the inbound request. Never paraphrase. Code blocks
> from the source go in fenced blocks below or inside the blockquote.
```

Canonical fields are only `Created` and `Source`. **No `Status:` field** — status lives in the journal's `## Active` list and in the chronological event lines, not duplicated here.

Tags after the H1 in inline code spans (`` `#tag` ``).

## meetings/YYYY-MM-DD-&lt;slug&gt;.md

Free text. Transcript, notes, action items — no required structure. Linked from journal as `[[meetings/YYYY-MM-DD-slug]]`.

## howto.md — personal cheatsheet

A single flat file at the project root for commands, recipes, tutorials, and reference snippets the user wants to recall later. **Not** tied to a specific task or person — content here is general, look-it-up-again material that outlives any one task.

```markdown
## kubectl — read pod logs
_added: 2026-05-01_

```sh
kubectl config get-contexts
kubectl config use-context <your-context>
...
```

## (next entry title)
_added: ...
```

**Structure:**
- One `## Title` per entry. Title should be short and lookup-friendly — the user will scan or `grep '^## ' howto.md` to find it later. Lead with the tool/topic when sensible (`kubectl — …`, `git — …`, `psql — …`).
- First line under the heading: `_added: YYYY-MM-DD_` in italics.
- Body: free-form — prose, fenced code blocks, links, whatever fits. Code goes in fenced blocks with the right language tag.

**When to add:** only when the user explicitly asks ("save to howto", "remember this", "add this as a guide", or similar). Don't autonomously file notes here. Task-specific notes still go in `tasks/<id>.md`; per-day events still go in `journal.md`.

**Append, don't reorder.** New entries go at the bottom of the file. If an existing entry is corrected or extended, edit it in place and bump its `_added:` date to the revision date. Don't delete entries unless the user asks.

**No journal entry needed.** Adding to `howto.md` is a reference action, not a task event — it does not need a `[WORK  ]` line in the journal unless the user asks.

## Common workflows

### Start a task

User: "I'm starting on the Solana retry"

1. Append to journal: `` - `<NOW>` [START ] #solana-retry — <optional kickoff note> ``
2. Update the `## Active` list at the top of the journal — add `- DOING - Solana retry (#solana-retry)` (with `→ [[tasks/solana-retry]]` only if the file exists). If transitioning from PAUSED/BLOCKED/REVIEW, use `[RESUME]` instead of `[START ]` and just change the state on the existing Active line.
3. Do **not** create a task file by default — only if the task already has substantial context (inbound message, scope, etc.).

### Log an ad-hoc activity (no task)

User mentions in passing that they did or are doing something that **isn't already in their task list** — a quick one-off effort, a small chore, a brief investigation, a casing fix, a short manual op, helping someone debug, etc. These came up suddenly and are gone almost as fast.

**Default: don't open a task for it.** No `[NEW   ]` + `[DONE  ]` pair, no slug, no Active-list entry. Just append a single `[WORK  ]` line (no `#task-id`) recording what happened:

```
- `11:04` [WORK  ] fixed `Foobar` → `FooBar` brand casing in the admin frontend
- `14:18` [WORK  ] manually rotated the staging Postgres password
- `14:42` [WORK  ] helped a teammate reproduce the date picker glitch on Safari
```

**Promote to a real task only if the same activity is referenced again.** If the user later adds a follow-up note, asks for its status, or mentions the same thing a second time, that's the signal it's not a one-off — pick a slug at that point, append a `[NEW   ]` line with the chosen ID (plus whatever current-state verb fits: `[DONE  ]`, `[REVIEW]`, etc.), and add it to the Active list if it isn't already terminal. The original `[WORK  ]` line stays put — the journal is append-only.

**Override:** if the user explicitly frames it as a task ("save this as a task", "track this", "open #foo for …"), skip the `[WORK  ]` shortcut and create the task normally with `[NEW   ]`.

### Mentions of small work in passing

If the user mentions in passing that they worked on / are working on something small — without explicitly framing it as a task ("save this as a task", "track this", "open #foo for …") — treat it as **completed**, not in-progress. Don't open a new task, don't add it to the Active list, and don't list it in *Next:* of the daily report as still-open. The in-passing framing ("I worked on …", "I'm working on …") is the signal that the user does *not* want it tracked as an open item.

- **Sub-item of an existing task** → append `` - `<NOW>` [NOTE  ] #<parent> — <sub-item> done `` on the parent task.
- **Standalone, unrelated to any current task** → append a single `[WORK  ]` line per *Log an ad-hoc activity (no task)* above.

In the daily report, mention the work under *Done today* (it's real work that happened that day) and **never** under *Next:* (it isn't still open) — even though the user's wording may have sounded in-progress. If the user later explicitly frames the same item as a task ("save this as a task", "track this"), promote it to a real task with `[NEW   ]` per the normal flow.

### Log a working note

User: "Quick note: Ádám said use exponential backoff"

1. Append: `` - `<NOW>` [NOTE  ] #<current-task> — Ádám: exponential backoff ``
2. If the task file exists, append a timestamped bullet to its `## Notes` section.
3. If the task file doesn't exist, **only create one when the note records actual information or knowledge** (a decision, a finding, a design choice, accumulated technical detail) — not when the note is merely a status update or status explanation ("paused, will resume tomorrow", "PR is huge, partial review only", "blocked on access"). Status notes belong in the journal alone. See `tasks/<id>.md — optional context files` above for the full rule.

### Pause / resume

Pause: `` - `<NOW>` [PAUSE ] #<task> ``, then change the Active list line: `DOING - …` → `PAUSED - …`.
Resume: `` - `<NOW>` [RESUME] #<task> ``, then change the Active list line back to `DOING - …`.

### Finish a task

User: "Done, fix is merged"

1. Append: `` - `<NOW>` [DONE  ] #<task> — fix merged, tests green ``
2. **Remove the task from the `## Active` list** (DONE tasks aren't active).
3. If the task file exists, append a timestamped bullet to `## Notes` recording the completion.

(Same flow for `[CANCEL]`.)

### Save an inbound Slack/email request as task

User pastes a message and says "save this as a task".

1. Pick a slug from the request's intent (`#user-profile-page`, `#stripe-webhook-prod`).
2. Create `tasks/<id>.md` with:
   - `Created`, `Source` fields (no `Status`)
   - `## Summary` — one paragraph paraphrase
   - `## Original message` — verbatim blockquote of the user's pasted text. **Never paraphrase the original; quote it word-for-word**, including code blocks.
   - `## Open questions` — anything ambiguous in the request that needs clarification before work starts.
   - `## Notes` — empty initially, will accumulate timestamped bullets.
3. Append to journal: `` - `<NOW>` [NEW   ] #<id> — <one-line gist> → [[tasks/<id>]] ``
4. Add to the `## Active` list as `- TODO - <Human-readable name> (#<id>) → [[tasks/<id>]]`.
5. If user wants to start it now, log a separate `[START ]` line at the same minute and change the Active line state from TODO to DOING.

### Generate a daily standup report

User: "csinálj standup riportot" / "what did I do yesterday"

Compose from the journal:

- **Yesterday** (or "last working day"): all `[DONE  ]`, `[REVIEW]`, and substantive `[NOTE  ]` lines from the previous working day. Group by `#task-id`.
- **`[NEW   ]` lines never appear in *Done today*.** Creating a task is pipeline, not activity. Two cases:
    - If the NEW item is a follow-up surfaced while working on another in-flight task X (e.g. issues noticed while reviewing PR #N for task X), fold it into task X's *Done today* line — `"surfaced two follow-ups off PR #N, now queued: …"`. Don't give it a separate line, and never use a generic *"backlog grooming"* bucket.
    - If the NEW item is genuinely standalone (not tied to today's work), surface it only in *Next:* if it's planned for upcoming work — never in *Done today:*. If it isn't worth mentioning in *Next:*, leave it out entirely; the Status footer already lists open TODOs.
- **In-passing small work mentions are *Done today*, never *Next:*.** See *Mentions of small work in passing* above. When the user mentions in passing that they did or are doing something small without framing it as a task, treat it as completed: surface under *Done today* (folded into the parent task's line if it's a sub-item, otherwise as its own line) and **omit from *Next:*** even though the in-progress wording may suggest otherwise.
- **Today (planned)**: tasks currently DOING (read from the `## Active` list) plus the day's `**Plan:**` line if present. **Do not list open PRs here** — those belong in their own *Open PRs* section (see below).
- **Open PRs**: every task currently in REVIEW state with a known PR — one line per task, `[PR #N](url)` plus a short label. Include the task even if the PR was opened on an earlier day; the section is a snapshot of what is currently awaiting review, not a daily-activity list. **PRs opened on the day appear in both *Done today* and *Open PRs*** — the same-day opening is reportable activity *and* a current open-PR state, so they show in both. PRs that remain open from earlier days appear only in *Open PRs*, never in *Next:*. Place this section after *Next:* and before *Blockers:*. **Omit the section entirely when no PRs are open** — same rule as *Blockers:*, absence is the signal.
- **Blockers**: every BLOCKED task with reason from the task file or last journal line. **Omit the *Blockers:* line entirely when there are none** — don't write *"Blockers: none"*. Absence of the line *is* the "none" signal.

Keep it short — 3-5 bullets per section. Output in **Slack mrkdwn format, not standard markdown**, so the user can paste it directly into Slack. Slack mrkdwn differs from regular markdown — write the report using these conventions:

- **Bold** uses a single asterisk: `*bold*` — never `**bold**`.
- **Italic** uses underscores: `_italic_` — not single asterisks (single asterisks render as bold in Slack).
- Bullet lists (`-`), code spans (`` ` ``), blockquotes (`>`) and inline code work the same as markdown.
- Headings (`#`, `##`, …) are **not** rendered by Slack; use bold lines for section labels (e.g. `*Done today:*`) instead of `## Done today`.
- Links are written `[text](url)` (markdown style). Slack accepts this form via paste conversion, and the markdown form keeps the journal block readable in any markdown viewer (only the text shows, the URL is hidden behind the link). The native Slack `<url|text>` form is tolerated as a fallback but not preferred — it leaks the raw URL into markdown viewers.
- **Emojis are allowed (and encouraged) in the daily report block** to make scanning easier in Slack — one leading emoji per task line that hints at the outcome (e.g. ✅ merged, 🗑️ deleted, 🔥 in progress, 👀 in review, 🔐 secrets/auth, 📊 data/query, 🛠️ fix/optimization, 👍 approved, 🔎 investigated, 🚧 blocked). This is the **only** place in the system where emoji usage is opt-in for content; journal event lines, Active-list entries, task files, meeting notes, and `howto.md` stay emoji-free. (The Status footer at the end of chat responses is the other emoji-bearing surface, and its emoji set is fixed by its own spec below — don't conflate the two.)

**Use human-readable titles, not raw slug IDs.** The audience is a team Slack, not a grep tool, so derive a clean title for each task from the task file's H1 (the descriptive part after the slug-id) or the Active list. Write it in Slack-bold (`*Title*`, single asterisk). Don't paste `#admin-ui-redesign` in the report — write `*Admin UI redesign*` instead. PR numbers, endpoint paths, and other technical identifiers can stay verbatim.

**Strip insider/private tooling from the report.** The team has visibility into shared things — public PRs, deployed services, well-known endpoints, prod commits — but **not** into the user's local scratch tools, ad-hoc one-off scripts, private repo paths, or local file paths. Don't name them in the Slack output. Describe the *outcome* in team-facing terms instead, and keep the implementation detail in the task file's Notes/Outcome (which is for the user, not the team).

Examples of what to scrub from the report:
- One-off / temp scripts the user wrote locally (e.g. `scripts/fix-cache-perms.sh`) → say "manually applied a permissions fix on the PVC" or similar.
- Personal repo paths or filenames the team wouldn't recognize.
- Internal slugs, ticket IDs from a private tracker, or codenames the team doesn't share.
- **Opaque option/plan/path labels from in-task discussion** (e.g. `Option B chosen`, `went with plan 2`, `applied fix #3`). The label is a back-reference to an enumeration that lives in the task file, which the team has not read — so the bare label gives them nothing and forces them to guess at A and C. Two acceptable shapes when this comes up: (a) **drop the label entirely** and just describe what was chosen — *"chose hourly S3 snapshot from prod + `initContainer` on PR pods"*; or (b) **keep the label only if you spell it out inline** — *"the S3-snapshot path (option B in the writeup)"*. Never the bare *"Option B chosen"* form.

What stays: PR links, public service/endpoint names, deployed commits, well-known config (Helm charts, k8s objects), CVE/incident IDs, and anything else the team already sees in the same channels.

**After composing, append the report to `journal.md`** under today's `## YYYY-MM-DD` section as a sub-heading: `### Daily report` — **never include a time** in the heading (no `— HH:MM`, no timestamp anywhere in the heading). Place it after all the day's event-line bullets, separated by a blank line. The journal version uses the **exact same Slack mrkdwn formatting** as the version pasted into Slack — do not "upgrade" it to standard markdown (no double-asterisk bolds) just because it lives in a `.md` file. The whole point is that the journal block is copy-paste ready for Slack.

**Why no time on the heading:** the daily report block is *regenerated* whenever new events are logged after it (see below). Putting a time on it implies it's a point-in-time snapshot, which it isn't — it's the end-of-day summary, always reflecting the latest known state of the day. Any time-of-creation already lives in the chronological event lines above it.

**One report per day, always at the bottom.** A given `## YYYY-MM-DD` section contains at most one `### Daily report` sub-heading. If new event lines or updates are added after a daily report already exists for the day:

1. Append the new event lines below the existing report first (so the chronological log stays intact during the edit).
2. Regenerate the report content from the now-complete day (incorporating the new events).
3. Move the `### Daily report` block to the very end of the day's section. (No time to bump — the heading stays exactly `### Daily report`.)

Net result: the day always ends with exactly one up-to-date report block, and the event lines above it cover the full day chronologically.

## Searching

| Query | Pattern |
|---|---|
| Full lifecycle of one task | `grep '#solana-retry' journal.md` |
| All completions | `grep '\[DONE  \]' journal.md` |
| All meetings | `grep '\[MEET  \]' journal.md` |
| All emergencies / firefights | `grep '!!!' journal.md` |
| Task lifecycle, notes only | `grep '#solana-retry' journal.md \| grep '\[NOTE  \]'` |
| Everything on a date | `awk '/^## 2026-04-28/,/^## /' journal.md` |
| Currently active tasks | `awk '/^## Active/,/^---$/' journal.md` |
| List all how-to entries | `grep -n '^## ' howto.md` |

## Editing rules for AI agents

- **Time only in journal lines:** use bare `` `HH:MM` `` in event-line backticks. The date is already in the day's `## YYYY-MM-DD` header, so do **not** repeat it. Full `YYYY-MM-DD HH:MM` is reserved for `## Notes` bullets in task files (and similar subsections), which don't sit under a day header.
- **Always pad the verb** to the 6-char width inside brackets. Never `[NEW]` — always `[NEW   ]`.
- **External URLs live in the task file; journal points to the task-file section, not the external URL.** When you record a resource (Figma, Notion, Slack message, Google Doc, ticket, dashboard) tied to a task that has a file, put the actual URL inside `tasks/<id>.md` — usually as a bullet under `## Notes`, or in `Source:` / `## Original message` for inbound requests — wrapped as `[descriptive text](https://...)`. In the journal line that records the addition, write a **markdown local link** to the section anchor where the URL was placed: `[Figma link](tasks/<id>.md#notes) added (Design System)`. Heading anchors follow GitHub-style slugification: `## Notes` → `#notes`, `## Original message` → `#original-message`. **Exceptions where direct external URLs in the journal are allowed:**
    - **PR links** — short, stable, frequently referenced. Write `[PR #N](https://github.com/.../pull/N)` directly in the journal line, typically on `[REVIEW]` (PR opened) and `[DONE  ]` (PR merged) entries. Optionally also keep the link in the task file's `## Notes` as the canonical record, but it is not required if the journal carries it.
    - **Non-task lines** (`[WORK  ]`, `[MEET  ]`) — there is no task file to link into, so wrap any URL inline as `[text](https://...)` directly in the journal.
    - **Tasks without a file** — if a task has no `tasks/<id>.md` (default for short tasks), URLs go inline in journal entries as `[text](https://...)`. If the task later acquires a file, future references should follow the local-link rule.
- **Never paraphrase user-quoted inbound text.** Paste verbatim into `Original message` blockquotes. Code blocks stay code blocks.
- **Don't invent fields** in task files. Only `Created` and `Source`. Everything else goes in `## Notes` as prose.
- **No `Status:` field in task files.** Status lives only in the journal's `## Active` list and the chronological event lines.
- **Default: no task file.** Only create when there's substantial context (inbound message, accumulated notes/decisions/open questions, scope, code, external resources). 5-minute tasks with no info to capture stay file-less.
- **Timestamp every bullet in `## Notes`** (and similar event-tracking subsections like `## Review feedback`). Prefix each bullet with the full timestamp in backticks: `` - `YYYY-MM-DD HH:MM` <content> ``. The timestamp should match the corresponding journal entry that triggered the addition, so the journal timeline and the per-task chronology align. This makes the task file a self-contained, grep-able history of notes for that task. One event = one timestamped bullet; do not retroactively edit an existing bullet to record a later state change — append a new bullet instead.
- **Don't backdate journal lines** unless the user explicitly asks. New entries get the current timestamp from the environment.
- **Never delete or mutate past journal lines.** If a state was wrong, append a correction: `` [NOTE  ] #foo — correction: previous PAUSE at HH:MM was actually a CANCEL ``.
- **Active list is mutable.** It's not a journal entry; it reflects current state. Edit it directly when state changes (add, remove, change state). The chronological event lines are the audit trail; the Active list is the current snapshot.
- **Stop and ask when ambiguous.** If "done" is said but two tasks are in DOING, ask which. If a slug isn't obvious from the request, propose one and confirm.
- **English everywhere — chat responses and file content alike.** Every journal entry, task file, Active list line, meeting note, **and every chat response back to the user** is written in English, regardless of the language the user chats in. If the user writes in Hungarian (or any other language), still answer in English. The only exception is verbatim quotes — e.g., the contents of a `## Original message` blockquote, or a meeting transcript — which preserve the original language. Surrounding structure (headings, fields, prose, summaries, paraphrased notes, and the assistant's chat output) stays English.
- **One day per `## H2`.** Don't create multiple `## YYYY-MM-DD` headers for the same date. Append under the existing one.
- **This SKILL.md is company-independent.** It must not contain any specific company, product, brand, internal codename, or repository name from the user's workplace — not in examples, not in Active-list samples, not in the quick-reference card, and not even in the body of this very rule (so the rule's wording can't itself be the exception). All examples use generic placeholders only: invented brand strings (`FooBar`, `Acme`), generic feature names ("the admin frontend", "the docs site", "user profile page"), or public/abstract third-party names that are not the user's workplace. If you notice a workplace-specific name slipping in anywhere, replace it with a generic equivalent.

## Response format — Status footer

End every response with a **Status** block summarizing what is currently being worked on and what is in the pipeline. **Each task goes on its own line as a nested bullet** under its state — never comma-separate multiple task IDs on one line. Format:

```
**Status**
- 🔥 DOING
  - ⬆️ `#high-prio-task`
  - `#normal-prio-task`
  - ⬇️ `#low-prio-task`
- ⏸ PAUSED
  - `#task-id`
- 🚧 BLOCKED
  - `#task-id` (reason)
- 👀 REVIEW
  - ⬆️ `#high-prio-review`
  - `#task-id`
- ⏳ TODO
  - `#task-id`
  - ⬇️ `#low-prio-todo`
```

Rules:
- **One task per line.** Always render task IDs as nested bullets under the state header — never `🔥 DOING — #a, #b, #c` on a single line, even when the state has only one task. Consistency matters more than compactness.
- **Sort by priority within each state group.** Order: `HIGH` first, then `NORMAL`, then `LOW`. Prefix `HIGH` tasks with ⬆️ and `LOW` tasks with ⬇️; `NORMAL` tasks have no prefix.
- Show only rows that have at least one task. Skip empty states entirely.
- **Do not display elapsed times or durations.** The system does not clock work; only the task IDs go in the footer.
- Read the current state and priority from the journal's `## Active` list (top of the file).
- If nothing is in any open state, render `**Status:** idle (no open tasks)`.
- If the response is a pure factual lookup whose answer already contains the state, the footer may be omitted to avoid duplication — use judgment.

## Quick reference card

Event lines (under a `## YYYY-MM-DD` day header — time only):
```
- `09:15` [START ] #foo — kickoff note
- `09:30` [NOTE  ] #foo — interim note
- `10:45` [PAUSE ] #foo
- `11:00` [WORK  ] non-task activity
- `11:30` [MEET  ] meeting → [[meetings/...]]
- `13:00` [RESUME] #foo
- `14:30` [DONE  ] #foo — outcome
- `15:00` [NEW   ] #bar — !!! urgent → [[tasks/bar]]
- `15:30` [BLOCK ] #bar — waiting on legal
- `16:00` [REVIEW] #foo — PR #123 to Tom
- `17:00` [CANCEL] #baz — out of scope after discussion
```

Active list:
```
## Active

- DOING - Solana retry (#solana-retry) → [[tasks/solana-retry]]
- REVIEW - Admin frontend polish (#admin-frontend-polish)
- TODO - Quick CSS tweak (#quick-css-tweak)
```

States: TODO · DOING · PAUSED · BLOCKED · REVIEW · DONE · CANCELED
Verbs:  NEW · START · PAUSE · RESUME · BLOCK · REVIEW · DONE · CANCEL · NOTE · MEET · WORK
