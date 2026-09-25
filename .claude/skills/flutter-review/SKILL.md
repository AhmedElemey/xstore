---
name: flutter-review
description: Team-lead review checklist and accumulated lessons for xStore Flutter code. Use BEFORE writing or modifying any Dart code in this repo, and AFTER completing a change to self-review it. Also use when a review finding or user correction produces a new lesson to record, or after merging a pull request to dev (see "Post-Merge Audit").
---

# xStore Flutter Review — Team Lead Skill

Three jobs:
1. **Before writing Dart code**: grep `lessons.md` (next to this file) for the feature, file, endpoint, or widget you're about to touch, read the matching entries, and apply them. Don't load the whole log — it's a reference, not a preamble.
2. **After a review finding or user correction**: record the lesson (see "Recording a lesson").
3. **After merging a pull request into `dev`**: run the codebase audit below (see "Post-Merge Audit").

The base rules (disposal, Riverpod lifecycles, mounted checks, rebuild storms, over-engineering bans) live in the project CLAUDE.md — this skill holds what we learn on top of them.

## Post-Merge Audit

A `PostToolUse` hook on `mcp__github__merge_pull_request` (see `.claude/settings.json`) injects a reminder into context right after any PR merge completes. When that reminder appears (or when the user directly asks to "run the audit"/"check for dead code"), and the merge target was `dev`:

1. Confirm the merge actually landed on `dev` (not `main` or another branch) before proceeding — the hook fires on every merge regardless of target, since the merge tool doesn't report the base branch.
2. Run this review as a senior software engineer performing a code quality and maintainability review, split across parallel Explore agents so no single agent's context overflows (four passes works: orphaned files/unused deps, duplicate UI/logic, legacy code markers, redundant API calls/dead routes):

   > Act as a senior software engineer performing a code quality and maintainability review.
   >
   > Analyze the entire codebase and identify:
   >
   > 1. Dead code (unused functions, files, components, routes, APIs, variables, imports, and dependencies)
   > 2. Duplicate logic that should be consolidated
   > 3. Unused UI components
   > 4. Overly complex implementations that can be simplified
   > 5. Legacy code that is no longer needed
   > 6. Redundant database queries or API calls
   > 7. Files that appear abandoned or disconnected from the application
   > 8. Opportunities to reduce technical debt
   >
   > For each issue:
   >
   > * Explain why it is unnecessary
   > * Estimate the impact of removing it
   > * Identify any risks before deletion
   > * Provide a recommended cleanup plan
   >
   > Be aggressive but safe. Assume the goal is to simplify the codebase, improve maintainability, and remove anything that does not provide value.

3. If a prior audit's findings are still in this skill file's memory (recent conversation, or a prior report), re-verify each one against the CURRENT code before repeating it — don't pad the new report with stale findings (see the 2026-09-11 "audit is a snapshot" lesson in `lessons.md`), and don't silently skip re-checking just because a finding was reported once.
4. **Before recommending any deletion, verify it doesn't break the build** — a symbol can have a live reference the grep pass missed (a deleted route constant with one missed reference has broken `dev` before). If you executed deletions from a previous run of this audit, grep one more time across the whole `lib/` and `test/` trees for anything on the delete list before considering the pass done.
5. Report the findings to the user and ask how they'd like to proceed (report only, or open a cleanup PR) — unless this specific conversation already told you to auto-apply confirmed-safe deletions, in which case do that on a fresh branch off `dev` and open a PR. This section only guarantees the audit itself runs on schedule; it doesn't authorize skipping the user's say on what happens with the results.

## Recording a lesson

Add to `lessons.md` whenever any of these happen and the lesson isn't already covered by CLAUDE.md's rules or an existing entry:
- The review hook or your own self-review catches a real issue in your change.
- The user corrects your approach, style, or a design decision.
- You discover a repo-specific pattern the hard way (an API quirk, a widget that must be used a certain way, a backend contract detail).

Format — one entry, newest last:

```
### YYYY-MM-DD — <short title stating the rule>
- **Rule:** <the generalized do/don't to apply next time, one or two sentences, with the reason>
- **Where it applies:** <file/feature/pattern scope — this is what future greps match on>
```

Rules for the log:
- Generalize: record the *rule*, not the incident. "Dispose PageControllers in carousel widgets" not "fixed banner_carousel.dart".
- No duplicates: if a lesson already covers it, sharpen that entry instead of adding a new one. When a new finding contradicts an entry (a backend contract changed, a diagnosis was wrong), rewrite or delete the old entry — never append a correction next to it and leave both.
- Keep entries short (under ~600 characters) — the incident story belongs in the commit message, not here.
- If a lesson is important enough to be a hard requirement for every change, promote it into CLAUDE.md's rules section and remove it from here.
