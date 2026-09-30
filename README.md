# Chairflow

A calm, minimal appointment book for a small family-run hair salon. See `lode/summary.md` for what it is and its current status, and `lode/lode-map.md` for the rest of the project documentation.

## Running it

Everything runs through Docker; no local Ruby/Node install is required.

```sh
just up      # dev server at http://localhost:3000, detached
just logs    # follow its output
just down    # stop it
```

## Testing and checks

```sh
just ci        # everything: setup, rubocop, security audits, full test suite (incl. system tests)
just test      # just the test suite
just lint      # rubocop
just security  # brakeman
```

`just console` opens a Rails console in the dev container; `just sh` opens a shell. Run `just` with no arguments to list all recipes.
