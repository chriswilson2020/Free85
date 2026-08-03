# Free85 2.10.0 release notes

Free85 2.10.0 is the stable Phase 14.10 release. It combines the typed object
store, complete numeric and graph modes, collection and linear-algebra tools,
solver and statistics applications, programming language, user constants,
extended characters, typed memory browser, and open Free85 link workflows.

## Persistent-state migration

Persistent RAM schema 13 and object-store schema 1 are frozen for the 2.10.0
release. A calculator carrying schema 12 is migrated transactionally: legacy
A-Z numeric values remain at their existing addresses, the typed directory is
rebuilt, and schema 13 is written only after initialization succeeds. Schema 13
survives warm reset. Unsupported or corrupt headers are initialized safely.

## Reproducibility

`npm run release:free85` builds the ROM and GitHub Pages artifact twice in
independent temporary trees. Both 131,072-byte ROMs must match the checked-in
ROM byte-for-byte, and both Pages directory trees must have the same SHA-256.
The result is recorded in `spec/free85/reproducibility.json`; the release
manifest binds that evidence to the published ROM hash.

## Clean-room provenance

Free85 firmware, font, browser integration, tests, fixtures, and release
artifacts are original project work. Public builds and validation do not read
or require a TI ROM, disassembly, font, artwork, token stream, or proprietary
fixture. A user-owned TI-85 ROM may be supplied only to the optional private
black-box oracle lane; its bytes and derived private captures are excluded from
the repository.

## Compatibility boundary

Free85 provides equivalent calculator workflows but does not promise TI binary
compatibility. TI programs, files, tokens, ROM calls, internal structures, and
proprietary link formats are intentionally unsupported. The open Free85 link
protocol is fully fault-tested between two emulated machines; physical-cable
validation is reported separately.

## Validation result

The stable release passes all 181 public tests, the deterministic performance
budgets, the 10,000-key-event stress run, and the 9,000-frame (180 emulated
second) soak. The optional private clean-room oracle passes all 270 numerical
comparisons and five application-state probes.

The checked-in ROM SHA-256 is
`dc91f6d59ac3ab930216f7642a68284fdb8d6255170934c9c5733b360df160f0`.
The independently rebuilt GitHub Pages tree SHA-256 is
`b227041369e2bfdbf9cb606059897b7e9b4502a3d40320fecc83e70d48a5e92b`.
The machine-readable evidence is in `spec/free85/release.json`,
`spec/free85/reproducibility.json`, and `spec/free85/performance.json`.
