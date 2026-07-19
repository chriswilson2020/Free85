# Free85 graph screen goldens

Each approved case has two synchronized files:

- `.lcd`: the exact 1,024-byte packed 128x64 LCD framebuffer.
- `.png`: a lossless 4x rendering for human inspection.

The tests never update these files automatically. On a mismatch they write
expected, actual, and red/blue diff PNGs to `test-results/free85-visual/`.
Inspect those images before intentionally accepting a renderer change with:

```sh
npm run update:free85:goldens
```

Red pixels in a diff exist only in the new output. Blue pixels are missing from
the new output. A golden must not be accepted solely because a checksum changed.

