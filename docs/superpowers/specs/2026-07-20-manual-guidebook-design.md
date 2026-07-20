# Free85 Manual and Guidebook — Design

Date: 2026-07-20
Status: approved

## Goal

Produce original, clean-room user documentation for Free85: a short Getting
Started Manual and a full reference Guidebook, delivered as Markdown in the
repository and as typeset PDFs. All prose is written from scratch; no TI
guidebook text is copied or paraphrased closely. Structure follows the
functional chapter topics already tracked in
`spec/free85/guidebook-coverage.yaml`.

## Scope decisions (user-approved)

- **Format:** Markdown in the repo, plus generated PDFs.
- **Structure:** two documents — Getting Started Manual and reference
  Guidebook.
- **Feature scope:** document behaviour implemented today (1.0 complete plus
  2.0 through Phase 14.2) as fact. Partial or missing features get a
  consistent, clearly marked planned-feature callout sourced from
  `guidebook-coverage.yaml` and `v2-parity-gaps.yaml`.
- **Chapters:** mirror the ~19-chapter topic structure in
  `guidebook-coverage.yaml`, keeping chapter-level traceability intact.

## Deliverables

### 1. Getting Started Manual — `docs/manual/Free85-Manual.md`

A short user manual (~15–25 typeset pages):

- What Free85 is; the clean-room boundary and licensing story.
- Ways to run it: browser app (GitHub Pages deployment), local dev server
  (`npm run dev`), terminal framebuffer preview (`npm run run:free85`).
- The machine: Z80, 128×64 LCD, 49-key matrix plus ON.
- Keyboard tour: key layout, 2ND and ALPHA modifiers, lowercase alpha,
  soft-function keys F1–F5 and menu pages.
- Screen layout: home screen, status indicators, editors, menus.
- First calculations: arithmetic, scientific functions, ANS, previous
  entries, editing.
- Modes overview: display (AUTO/SCI/ENG/FIX), angle, number base.
- Pointers into the Guidebook for everything else.

### 2. Guidebook — `docs/guidebook/`

One Markdown file per chapter, numbered for ordering, e.g.
`01-operating-the-calculator.md` … `19-linking.md`, plus `00-front-matter.md`
(title, notices, how to read the book) and appendices. Chapter topics mirror
`guidebook-coverage.yaml`:

1. Operating the calculator: operation, modes, editing, previous entries
2. Variables and stored data (typed object store, reserved names)
3. Mathematics, calculus and comparisons
4. Cartesian graphing, drawing, formats and persistence
5. Polar graphing — stub: planned (work package 14.5)
6. Parametric graphing — stub: planned (work package 14.5)
7. Differential-equation graphing — stub: planned (work package 14.5)
8. Physical and user constants plus conversions
9. Strings and characters
10. Number bases and Boolean operations
11. Complex numbers
12. Lists
13. Matrices and vectors
14. Equation, polynomial and simultaneous solving
15. Statistics and statistical plots
16. Programming
17. Worked application examples
18. Memory management
19. Linking (hardware-dependent status noted)

Appendices (generated — see Deliverable 4):

- Appendix A: command and function catalog, from
  `guidebook-command-ledger.yaml` and `features.yaml`.
- Appendix B: complete key map, from `keymap.yaml`.
- Appendix C: error messages, from the firmware error model.
- Appendix D: feature status and 2.0 gap table, from
  `guidebook-coverage.yaml` and `v2-parity-gaps.yaml`.

Gap flagging convention: a consistent callout block, e.g.
`> ⚠ **Planned:** … (Free85 2.0, work package 14.x)`, wherever a documented
area has `partial`/`missing` status. `hardware-dependent` items state what
works in the emulator versus what awaits hardware validation.

### 3. Screenshot generator — `scripts/guidebook-screens.js`

Modeled on `scripts/update-free85-graph-goldens.js`: boots `Free85Harness`,
taps scripted key sequences, renders the LCD, and writes deterministic PNGs
to `docs/guidebook/images/` using the existing `test/helpers/lcd-visual.js`
encoder. Each screenshot used in the book is defined here as a named case, so
the whole image set regenerates with one command. npm script:
`build:guidebook:screens`.

### 4. Appendix generators — `scripts/build-guidebook-appendices.js`

Reads the YAML/JSON contracts listed above and emits the four appendix
Markdown files. Regenerable via npm script `build:guidebook:appendices` so
reference tables cannot drift from the contracts.

### 5. PDF build — `scripts/build-guidebook-pdf.js`

`npm run build:guidebook` pipeline:

1. pandoc (already installed) concatenates the Markdown into standalone HTML
   with embedded print CSS (page size, headers, chapter breaks, monospace
   LCD-style styling for key sequences and screen captures).
2. Headless Chrome (`--headless --print-to-pdf`) renders
   `Free85-Manual.pdf` and `Free85-Guidebook.pdf` into `dist/guidebook/`
   (git-ignored; PDFs are build artifacts, not committed).

No LaTeX toolchain required.

### 6. Traceability check — `scripts/check-guidebook-traceability.js`

Asserts every ledger item with status `equivalent` is mentioned in at least
one guidebook chapter, and that every chapter in `guidebook-coverage.yaml`
has a corresponding file. Extends the existing Phase 13 traceability story.
Wired into a standalone npm script (`test:guidebook`); it does not join the
default `npm test` in this work (the user can promote it later).

## Content production method

- Prose is written chapter-by-chapter from `docs/Free85-specification.md`,
  `spec/free85/features.yaml`, `spec/free85/keymap.yaml`, and the firmware
  source — never from TI documentation.
- Every worked example and documented key sequence is executed against the
  real ROM via `Free85Harness` before it enters the book; the harness
  signature/framebuffer confirms the described behaviour.
- Screenshots in the book are real LCD captures from the generator script.

## Error handling and edge cases

- Chapters for missing workflows are honest stubs, not fabricated docs.
- Where emulator behaviour differs from the documented target (found during
  verification), the book documents actual behaviour and the discrepancy is
  reported to the user rather than papered over.
- Generated appendices carry a "do not edit by hand" header.

## Testing

- `check-guidebook-traceability.js` (Deliverable 6).
- Screenshot generation is deterministic: re-running the generator must be
  byte-identical (same guarantee as existing goldens).
- PDF build verified by running it and inspecting output.

## Non-goals

- No changes to firmware, emulator, or existing tests.
- No TI text, page scans, artwork, or near-paraphrase; headings and prose are
  original expression organized by functional topic.
- No localization (English only, for now).
