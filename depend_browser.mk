MKGEN_SRCSBIN_BROWSER := _build/src/shared/bar.cmo _build/src/browser/main.cmo

_build/src/browser/main.cmo : src/browser/main.ml _build/src/shared/bar.cmo | _build/src/browser/
_build/src/browser/main.cmx : src/browser/main.ml _build/src/shared/bar.cmx | _build/src/browser/
_build/src/shared/bar.cmo : src/shared/bar.ml | _build/src/shared/
_build/src/shared/bar.cmx : src/shared/bar.ml | _build/src/shared/
