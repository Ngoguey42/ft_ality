MKGEN_SRCSBIN_TERMBYTE := _build/src/shared/shared_intf.cmo _build/src/graph/graph_intf.cmo _build/src/graph/p_graph_intf.cmo _build/src/terminal/key.cmo _build/src/terminal/display.cmo _build/src/shared/algo.cmo _build/src/terminal/main.cmo

_build/src/graph/graph_intf.cmo : src/graph/graph_intf.ml | _build/src/graph/
_build/src/graph/graph_intf.cmx : src/graph/graph_intf.ml | _build/src/graph/
_build/src/graph/p_graph_intf.cmo : src/graph/p_graph_intf.ml | _build/src/graph/
_build/src/graph/p_graph_intf.cmx : src/graph/p_graph_intf.ml | _build/src/graph/
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
