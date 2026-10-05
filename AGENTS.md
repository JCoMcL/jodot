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
