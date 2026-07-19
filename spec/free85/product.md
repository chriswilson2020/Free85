# Free85 Product Definition

Free85 is an independently written, open-source scientific graphing calculator
firmware for the TI-85-compatible machine layer in this repository. It runs on
the emulated Z80 and calculator hardware and does not require services from the
original TI firmware.

## Parity target

Every physical key, printed shifted function, alpha entry, and reachable
built-in menu must lead to a meaningful Free85 feature. Free85 does not promise
binary, program, file, token, ROM-call, or internal-data compatibility with TI
software.

## Clean-room boundary

Free85 source, generated artifacts, and public tests must not contain or derive
from TI ROM bytes, disassembly, fonts, artwork, binary tables, or proprietary
fixtures. A lawfully obtained original ROM may only be used as a private,
optional black-box oracle. Mathematical expectations come from independent
reference results.

## Hardware target

- Z80 CPU at the machine layer's 6 MHz cadence.
- Eight 16 KiB ROM pages, producing exactly 131,072 bytes.
- Fixed ROM page at `0x0000-0x3fff`.
- Banked ROM page at `0x4000-0x7fff`.
- 32 KiB RAM at `0x8000-0xffff`.
- 128 by 64 monochrome LCD.
- 49 matrix keys and a separate ON key.

## Delivery sequence

Phase 0 defines the product, complete physical-key inventory, planned feature
surfaces, coverage rules, and build skeleton. Phase 1 creates a bootable open
diagnostic ROM with reset vectors, interrupts, LCD output, original font and
screen assets, keypad scanning, and a visible last-key diagnostic.

Phase 2 adds the event-driven UI kernel, expression editor, cursor, modifier
states, soft-menu pages, and explicit development dialogs for reachable
features that are not implemented yet.

Later phases add the calculator kernel, numeric model, expression language,
scientific functions, graphing, collections, statistics, solvers, strings,
catalog/custom menus, and programming environment. A later integration phase
changes the website default only after the diagnostic firmware is reliable.

## Definition of a complete feature

A feature is complete only when it is reachable through a physical key or
reachable menu, performs a meaningful operation, handles a normal case and an
edge or error case, has automated tests, and is documented. Phase 0 entries are
therefore planned rather than complete.
