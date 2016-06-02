MKGEN_SRCSBIN_BROWSER := _build/src/shared/shared_intf.cmo _build/src/browser/main.cmo _build/src/shared/make_algo.cmo

_build/src/browser/main.cmo : src/browser/main.ml | _build/src/browser/
_build/src/browser/main.cmx : src/browser/main.ml | _build/src/browser/
_build/src/shared/make_algo.cmo : src/shared/make_algo.ml _build/src/shared/shared_intf.cmo | _build/src/shared/
_build/src/shared/make_algo.cmx : src/shared/make_algo.ml _build/src/shared/shared_intf.cmx | _build/src/shared/
_build/src/shared/shared_intf.cmo : src/shared/shared_intf.ml | _build/src/shared/
_build/src/shared/shared_intf.cmx : src/shared/shared_intf.ml | _build/src/shared/
