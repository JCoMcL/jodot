# AGENTS.md

Guidance for AI agents working in this repository.

## What this is

`jodot` is a **Godot editor plugin** (Godot 4.7, GL Compatibility) of general-purpose
utilities, meant to be shared and updated independently of any single game project.
Scripts live at the repo root as autoload-style `Node`s, with `effects/`, `transition/`,
and `ui/` holding self-contained feature modules.

Everything is `@tool` — these scripts run inside the editor, so they must not assume
game-loop context, and must guard editor-only paths with `Engine.is_editor_hint()`.

## Engine API reference is vendored in `.docs/`

`.docs/` holds a dump of the engine API for **exactly** the engine version this project
uses (`4.7.stable.official.5b4e0cb0f`). Treat it as the source of truth for API
questions instead of recalling signatures from memory or guessing from web docs.

Layout mirrors the engine source tree:

| Path | Contents |
| --- | --- |
| `.docs/doc/classes/` | 810 core classes — the bulk of it |
| `.docs/modules/*/doc_classes/` | Module classes (`gdscript`, `multiplayer`, `visual_shader`, `gltf`, `openxr`, ...) |
| `.docs/platform/*/doc_classes/` | Per-platform export plugins (`web`, `android`, `windows`, ...) |

One XML file per class, named after the class. To look up a known class, just read the
file directly — it is small and there is no need to search first:

```
read .docs/doc/classes/Area2D.xml
read .docs/doc/classes/@GlobalScope.xml   # global functions, constants, enums
```

To find which class exposes a given method, property, or signal, grep the `name="…"`
attributes:

```
rg -l 'name="intersect_shape"' .docs --glob '*.xml'
```

Each entry gives exact return type, parameter names, types, and default values, plus
the `inherits="…"` chain — enough to write a correct call the first time.

### Known limitation: the dump has signatures but no prose

Every `<description>` element in `.docs/` is **empty** (12,851 of them). Godot's
official release binaries ship with the documentation text stripped, so `--doctool`
emits the API *surface* only. Concretely:

- **You get:** class names, inheritance chains, method/param names, types, defaults,
  properties, signals, constants, enum values.
- **You do not get:** explanations, behaviour notes, examples, warnings.

So `.docs/` can answer *"what is the signature of `Tween.tween_property`?"* but never
*"what does it do?"*. For semantics, fall back to the project's own usage and comments
first, then online docs (`https://docs.godotengine.org/en/4.7/classes/`). Never present
an empty `<description>` as if it were documentation.

Regenerate with `make .docs`, which replaces the directory contents:

```
make .docs
```

## Conventions

Match the surrounding file rather than generic Godot style:

- **Tabs** for indentation, `: ` with no space before the colon in type hints
  (`func f(v: Vector2) -> Rect2:`).
- Sections delimited by `# --- name ---` comment banners.
- `##` for doc comments on public API.
- Godot-flavoured operators (`!` for `not`, `||`, `&&`) are normal here.
- Keep helpers terse and self-contained; most are pure functions on geometry and
  collision with no state beyond a module-level `rng`.
- Physics helpers take an optional `world: World2D = null` and fall back to
  `get_viewport().get_world_2d()` when unset — preserve that default so callers can
  stay agnostic.

## Before committing

- `make trim-whitespace` strips trailing whitespace from all `.gd` files.
- `make build` cross-exports Web, Windows, and Linux via the Godot CLI.
- There is no test suite and no linter configured; verification is opening the project
  in the editor or running `godot --headless` and watching for parse errors.

## Testing with the Godot CLI

There is no test suite or linter, so every check is a headless run. The golden rule:
**a test run should rarely need more than 10 seconds and never more than 30.** Bound
every run with `timeout`.

### Run the project / a scene

The default harness is just:

```
timeout 10 godot --headless > /tmp/log.txt 2>&1
```

This runs the project's `<main_scene>` from `project.godot`. When iterating on one
scene, set `run/main_scene` to it (by UID) so this one-liner is all you ever need.

- Run a specific scene instead: `timeout 10 godot --headless res://dir/scene.tscn`.
- Run a single main-loop iteration to smoke-test "does it boot without parse errors":
  `godot --headless --quit`.
- Run from any cwd against a project: `godot --path /abs/path/to/project --headless`.
- Run a scene-free logic probe with an `extends SceneTree` script (no window, no
  scene, exits with your chosen code via `quit(0)`):
  ```
  timeout 10 godot --headless --script res://tests/probe.gd
  ```
- Parse-gate a script / whole project (exit 0 = clean, 1 = errors):
  `godot --headless --check-only --script res://file.gd`

### stdout vs stderr (the #1 gotcha)

- `print()` and the version banner go to **stdout**.
- `printerr()`, `push_error()`, `push_warning()`, and every engine `ERROR:`/`WARNING:`
  go to **stderr** — this includes C++ hard errors like `Can't add child ... already
  has a parent`, which in the editor only surface in the Debugger pane. In headless,
  `print()` alone will silently miss them.

Always capture both: `2>&1` (or split with `> out 2> err` to keep prints separate from
diagnostics). When merged to one file, stdout is block-buffered and stderr is not, so
interleaving order is unreliable — match on stable markers, never on line position.

### Time and pacing (verified on this box)

- Headless runs **uncapped** at ~100–150 fps. `--quit-after N` counts main-loop
  iterations, *not* seconds: with `--quit-after 2000` expect roughly 10–20 s of game
  time. It is only a safety deadline, not a wall-clock.
- `--fixed-fps` is **not** a headless pace-knob — in testing it made the loop spin to
  ~100k iterations/s. Don't use it to time runs.
- Prefer wall-clock logic *inside* the scene: have `_process` check
  `Time.get_ticks_msec()` and call `get_tree().quit()` once the assertion window
  passes, then bound the whole thing with `timeout` anyway.

### Exit codes

- In-script `quit(code)` → that code.
- `--check-only`: 0 clean, 1 on parse error.
- `timeout` killing a hung run → 124.

### Pitfalls

- **Unbounded output fills the disk.** A runaway bug prints a backtrace every frame; a
  real incident produced 1.5 GB in under two minutes and filled `/tmp`. Always redirect
  to a file and keep test scenes print-bounded (greppable stable markers).
- **Count, don't eyeball.** After a run, `grep -cE 'SCRIPT ERROR|^ERROR' /tmp/log.txt`
  is a regression signal; `grep -c '^returning'` counts pool returns, etc.
- **A run with no `--quit-after`/`--quit`/in-script `quit()` never exits** — `timeout`
  is mandatory, treat 124 as "hung, investigate".
- Final visual/UX confirmation still happens in the editor; the CLI is for logic,
  regressions, and "does it parse and run clean".
