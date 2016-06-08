MKGEN_SRCSBIN_TERMNAT := _build/src/shared/shared_intf.cmx _build/src/graph/graph.cmx _build/src/terminal/key.cmx _build/src/terminal/display.cmx _build/src/shared/algo.cmx _build/src/terminal/main.cmx

_build/src/graph/graph.cmi : src/graph/graph.mli _build/src/graph/graph_intf.cmi | _build/src/graph/
_build/src/graph/graph.cmo : src/graph/graph.ml _build/src/graph/graph.cmi _build/src/graph/graph_intf.cmi | _build/src/graph/
_build/src/graph/graph.cmx : src/graph/graph.ml _build/src/graph/graph.cmi _build/src/graph/graph_intf.cmi | _build/src/graph/
_build/src/graph/graph_intf.cmi : src/graph/graph_intf.mli | _build/src/graph/
_build/src/shared/algo.cmo : src/shared/algo.ml _build/src/shared/shared_intf.cmo | _build/src/shared/
_build/src/shared/algo.cmx : src/shared/algo.ml _build/src/shared/shared_intf.cmx | _build/src/shared/
_build/src/shared/shared_intf.cmo : src/shared/shared_intf.ml | _build/src/shared/
_build/src/shared/shared_intf.cmx : src/shared/shared_intf.ml | _build/src/shared/
_build/src/terminal/display.cmo : src/terminal/display.ml _build/src/shared/shared_intf.cmo _build/src/terminal/key.cmi | _build/src/terminal/
_build/src/terminal/display.cmx : src/terminal/display.ml _build/src/shared/shared_intf.cmx _build/src/terminal/key.cmx | _build/src/terminal/
_build/src/terminal/key.cmi : src/terminal/key.mli _build/src/shared/shared_intf.cmo | _build/src/terminal/
_build/src/terminal/key.cmo : src/terminal/key.ml _build/src/terminal/key.cmi | _build/src/terminal/
_build/src/terminal/key.cmx : src/terminal/key.ml _build/src/terminal/key.cmi | _build/src/terminal/
_build/src/terminal/main.cmo : src/terminal/main.ml _build/src/shared/algo.cmo _build/src/shared/shared_intf.cmo _build/src/terminal/display.cmo _build/src/terminal/key.cmi | _build/src/terminal/
_build/src/terminal/main.cmx : src/terminal/main.ml _build/src/shared/algo.cmx _build/src/shared/shared_intf.cmx _build/src/terminal/display.cmx _build/src/terminal/key.cmx | _build/src/terminal/
