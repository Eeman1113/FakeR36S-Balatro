# FakeR36S-Balatro: Balatro on a fake R36S

Balatro on the fake R36S / GA36-MB handheld (Allwinner A23, 32-bit ARM, Mali-400, 512 MB) under [FakeR36S-OS](https://github.com/Eeman1113/FakeR36S-OS). Balatro is a [LÖVE](https://love2d.org) game, and FakeR36S-OS ships LÖVE 11.5 (LuaJIT, OpenGL ES 2), so the game runs as it is, with [PortMaster](https://portmaster.games)'s handheld patches on top: a layout made for small screens, performance tweaks, controller fixes and a particle leak fix.

- **`balatro-port.sh`** fetches PortMaster's Balatro patches pinned to one commit, runs their own patch script unchanged on a copy of your game on your computer, and puts the result on the card with a menu entry.
- **`port/run.sh`** is the launcher on the handheld: OpenGL ES 2, 30 fps to start, full CPU while playing, Select+Start quits.

**No game files are included.** You need your own Balatro: the Mac `Balatro.app`, `Balatro.love`, or the Windows `Balatro.exe` from Steam. It also needs FakeR36S-OS with LÖVE (any build from November 2026 on).

## Install

With the card's HOME partition mounted on your computer:

```sh
git clone https://github.com/Eeman1113/FakeR36S-Balatro
cd FakeR36S-Balatro
./balatro-port.sh /Applications/Balatro.app /Volumes/HOME     # or Balatro.love / Balatro.exe
```

Your original game isn't touched; the patched copy (about 57 MB) goes to `ports/balatro/` with a **Balatro** entry in **Ports**. Needs bash, python3, curl and GNU sed (on macOS: `brew install gnu-sed`). Nothing is uploaded.

## Playing

It starts at 30 fps with the CRT effect off; both can be changed in the game's Settings. **Select+Start** quits. Saves stay in `ports/balatro/saves`, and the log is `.config/fakers36s/balatro.log`.

## Credits

- **LocalThunk** and **Playstack** for Balatro. Buy it, it's wonderful.
- **[PortMaster](https://portmaster.games)** and the authors of its **[Balatro port](https://github.com/PortsMaster/PortMaster-New/tree/main/ports/balatro)** (MIT): the handheld patches and patch script are theirs, applied unchanged. The Nunito font is under the SIL Open Font License.
- **[LÖVE](https://love2d.org)** and its contributors (zlib license).

The scripts in this repo are MIT licensed.
