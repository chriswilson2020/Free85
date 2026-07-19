# Free85 typed object store

Phase 14.1 introduces the persistent storage contract used by Free85 2.0. It is
an original Free85 format and is not compatible with TI variables, files,
tokens, or ROM internals.

## User workflow

Open the memory browser with `2ND`, `+`. The screen shows the total object
count and the selected object's name, numeric type, and byte size.

- `UP` and `DOWN` select an object.
- `DEL` deletes the selected object. For a reserved A-Z real, deletion clears
  its numeric payload and keeps the reserved directory entry.
- `F1` clears all A-Z values, `F2` clears programs, `F3` resets settings,
  `F4` performs a full reset, and `F5` opens link status.
- `EXIT` returns home.

The type numbers are real 1, complex 2, list 3, matrix 4, vector 5, string 6,
equation 7, program 8, constant 9, graph database 10, and picture 11.

## RAM contract

The v2 header starts at `$9D80`; the 64-entry directory starts at `$9E00`.
Each 16-byte directory record stores a type, flags, name length, an eight-byte
name, payload address, 16-bit payload size, and metadata tag. The compacting
heap occupies `$A200` through `$FAFF`, providing 22,784 payload bytes. The
machine stack remains `$FB00-$FBFF` and the LCD framebuffer remains
`$FC00-$FFFF`.

Names are zero-terminated and limited to eight characters. A used entry may be
external, meaning its payload remains in a legacy fixed address, or internal,
meaning its payload belongs to the compacting heap. The initial directory
contains the 26 reserved real objects A-Z as external entries.

## Firmware API

Bank 7 publishes stable jump-table entries for initialization, validation,
creation, lookup, deletion, resizing, compaction, and selected-object deletion.
Creation accepts a type, name, and 16-bit byte size. It either commits a new
directory entry and advances the heap end or returns carry without changing
accounting. Lookup matches both type and name.

Internal deletion closes the payload gap and subtracts its size from every
later internal address. Resizing moves the complete following tail with
`LDIR`/`LDDR`, updates later addresses, and commits the new heap end only after
the capacity check succeeds. Consequently the heap has no persistent holes;
the compaction entry point validates that invariant and reports exact free
bytes. Directory-full, zero-size, and insufficient-memory requests return
carry and leave the prior store intact.

## Persistence and migration

Schema 13 validates both the Free85 state header and the object-store header on
every reset. A valid store survives warm reset byte-for-byte. If a schema-12
state is found, the firmware preserves all existing fixed data, rebuilds the
typed directory, and writes schema 13 last. If reset or power loss interrupts
that process, the unchanged schema-12 byte causes migration to be retried.

A corrupt object-store header under schema 13 is recovered by rebuilding the
directory adapters; fixed A-Z payloads are still preserved. A full reset from
the memory screen deliberately clears the earlier state and constructs a fresh
schema-13 store.

## Validation

`test/free85/object-store.test.js` invokes the real bank-7 routines through the
emulated Z80 rather than duplicating allocator logic in JavaScript. It checks
all eleven types, lookup, resizing in both directions, address relocation,
payload preservation, compaction, deletion, reset persistence, directory and
heap pressure, migration, and the physical-key browser workflow. The reviewed
browser framebuffer is `test/free85/goldens/graphs/phase14-memory-browser.lcd`,
with a rendered PNG beside it for human inspection.
