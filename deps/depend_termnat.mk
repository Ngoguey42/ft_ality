MKGEN_SRCSBIN_TERMNAT := _build/src/bt/avl.cmx _build/src/bt/ftmap.cmx _build/src/graph/ftgraph.cmx _build/src/main/shared/graph_impl.cmx _build/src/main/shared/algo.cmx _build/src/main/terminal/key.cmx _build/src/main/terminal/display.cmx _build/src/main/terminal/main.cmx

_build/src/bt/avl.cmo : src/bt/avl.ml | _build/src/bt/
_build/src/bt/avl.cmx : src/bt/avl.ml | _build/src/bt/
_build/src/bt/ftmap.cmo : src/bt/ftmap.ml | _build/src/bt/
_build/src/bt/ftmap.cmx : src/bt/ftmap.ml | _build/src/bt/
_build/src/graph/ftgraph.cmi : src/graph/ftgraph.mli _build/src/graph/ftgraph_intf.cmi | _build/src/graph/
_build/src/graph/ftgraph.cmo : src/graph/ftgraph.ml _build/src/bt/avl.cmo _build/src/bt/ftmap.cmo _build/src/graph/ftgraph.cmi _build/src/graph/ftgraph_intf.cmi | _build/src/graph/
_build/src/graph/ftgraph.cmx : src/graph/ftgraph.ml _build/src/bt/avl.cmx _build/src/bt/ftmap.cmx _build/src/graph/ftgraph.cmi _build/src/graph/ftgraph_intf.cmi | _build/src/graph/
_build/src/graph/ftgraph_intf.cmi : src/graph/ftgraph_intf.mli | _build/src/graph/
_build/src/main/shared/algo.cmo : src/main/shared/algo.ml _build/src/bt/ftmap.cmo _build/src/main/shared/shared_intf.cmi | _build/src/main/shared/
_build/src/main/shared/algo.cmx : src/main/shared/algo.ml _build/src/bt/ftmap.cmx _build/src/main/shared/shared_intf.cmi | _build/src/main/shared/
_build/src/main/shared/graph_impl.cmo : src/main/shared/graph_impl.ml _build/src/bt/avl.cmo _build/src/graph/ftgraph.cmi _build/src/main/shared/shared_intf.cmi | _build/src/main/shared/
_build/src/main/shared/graph_impl.cmx : src/main/shared/graph_impl.ml _build/src/bt/avl.cmx _build/src/graph/ftgraph.cmx _build/src/main/shared/shared_intf.cmi | _build/src/main/shared/
_build/src/main/shared/shared_intf.cmi : src/main/shared/shared_intf.mli _build/src/bt/avl.cmo _build/src/graph/ftgraph_intf.cmi | _build/src/main/shared/
_build/src/main/terminal/display.cmo : src/main/terminal/display.ml _build/src/main/shared/shared_intf.cmi _build/src/main/terminal/term_intf.cmi | _build/src/main/terminal/
_build/src/main/terminal/display.cmx : src/main/terminal/display.ml _build/src/main/shared/shared_intf.cmi _build/src/main/terminal/term_intf.cmi | _build/src/main/terminal/
_build/src/main/terminal/key.cmi : src/main/terminal/key.mli _build/src/main/terminal/term_intf.cmi | _build/src/main/terminal/
_build/src/main/terminal/key.cmo : src/main/terminal/key.ml _build/src/main/terminal/key.cmi | _build/src/main/terminal/
_build/src/main/terminal/key.cmx : src/main/terminal/key.ml _build/src/main/terminal/key.cmi | _build/src/main/terminal/
_build/src/main/terminal/main.cmo : src/main/terminal/main.ml _build/src/main/shared/algo.cmo _build/src/main/shared/graph_impl.cmo _build/src/main/shared/shared_intf.cmi _build/src/main/terminal/display.cmo _build/src/main/terminal/key.cmi | _build/src/main/terminal/
_build/src/main/terminal/main.cmx : src/main/terminal/main.ml _build/src/main/shared/algo.cmx _build/src/main/shared/graph_impl.cmx _build/src/main/shared/shared_intf.cmi _build/src/main/terminal/display.cmx _build/src/main/terminal/key.cmx | _build/src/main/terminal/
_build/src/main/terminal/term_intf.cmi : src/main/terminal/term_intf.mli _build/src/main/shared/shared_intf.cmi | _build/src/main/terminal/
