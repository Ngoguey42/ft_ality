MKGEN_SRCSBIN_TERMBYTE := _build/src/bt/avl.cmo _build/src/bt/ftmap.cmo _build/src/graph/ftgraph.cmo _build/src/shared/shared_intf.cmo _build/src/shared/graph_impl.cmo _build/src/shared/algo.cmo _build/src/terminal/key.cmo _build/src/terminal/display.cmo _build/src/terminal/main.cmo

_build/src/bt/avl.cmo : src/bt/avl.ml | _build/src/bt/
_build/src/bt/avl.cmx : src/bt/avl.ml | _build/src/bt/
_build/src/bt/ftmap.cmo : src/bt/ftmap.ml | _build/src/bt/
_build/src/bt/ftmap.cmx : src/bt/ftmap.ml | _build/src/bt/
_build/src/graph/ftgraph.cmi : src/graph/ftgraph.mli _build/src/graph/ftgraph_intf.cmi | _build/src/graph/
_build/src/graph/ftgraph.cmo : src/graph/ftgraph.ml _build/src/bt/avl.cmo _build/src/bt/ftmap.cmo _build/src/graph/ftgraph.cmi _build/src/graph/ftgraph_intf.cmi | _build/src/graph/
_build/src/graph/ftgraph.cmx : src/graph/ftgraph.ml _build/src/bt/avl.cmx _build/src/bt/ftmap.cmx _build/src/graph/ftgraph.cmi _build/src/graph/ftgraph_intf.cmi | _build/src/graph/
_build/src/graph/ftgraph_intf.cmi : src/graph/ftgraph_intf.mli | _build/src/graph/
_build/src/shared/algo.cmo : src/shared/algo.ml _build/src/shared/shared_intf.cmo | _build/src/shared/
_build/src/shared/algo.cmx : src/shared/algo.ml _build/src/shared/shared_intf.cmx | _build/src/shared/
_build/src/shared/graph_impl.cmo : src/shared/graph_impl.ml _build/src/bt/avl.cmo _build/src/graph/ftgraph.cmi _build/src/shared/shared_intf.cmo | _build/src/shared/
_build/src/shared/graph_impl.cmx : src/shared/graph_impl.ml _build/src/bt/avl.cmx _build/src/graph/ftgraph.cmx _build/src/shared/shared_intf.cmx | _build/src/shared/
_build/src/shared/shared_intf.cmo : src/shared/shared_intf.ml _build/src/bt/avl.cmo _build/src/graph/ftgraph_intf.cmi | _build/src/shared/
_build/src/shared/shared_intf.cmx : src/shared/shared_intf.ml _build/src/bt/avl.cmx _build/src/graph/ftgraph_intf.cmi | _build/src/shared/
_build/src/terminal/display.cmo : src/terminal/display.ml _build/src/shared/shared_intf.cmo _build/src/terminal/term_intf.cmi | _build/src/terminal/
_build/src/terminal/display.cmx : src/terminal/display.ml _build/src/shared/shared_intf.cmx _build/src/terminal/term_intf.cmi | _build/src/terminal/
_build/src/terminal/key.cmi : src/terminal/key.mli _build/src/terminal/term_intf.cmi | _build/src/terminal/
_build/src/terminal/key.cmo : src/terminal/key.ml _build/src/terminal/key.cmi | _build/src/terminal/
_build/src/terminal/key.cmx : src/terminal/key.ml _build/src/terminal/key.cmi | _build/src/terminal/
_build/src/terminal/main.cmo : src/terminal/main.ml _build/src/shared/algo.cmo _build/src/shared/graph_impl.cmo _build/src/shared/shared_intf.cmo _build/src/terminal/display.cmo _build/src/terminal/key.cmi | _build/src/terminal/
_build/src/terminal/main.cmx : src/terminal/main.ml _build/src/shared/algo.cmx _build/src/shared/graph_impl.cmx _build/src/shared/shared_intf.cmx _build/src/terminal/display.cmx _build/src/terminal/key.cmx | _build/src/terminal/
_build/src/terminal/term_intf.cmi : src/terminal/term_intf.mli _build/src/shared/shared_intf.cmo | _build/src/terminal/
