MKGEN_SRCSBIN_TESTGRAPH := _build/src/bt/avl.cmo _build/src/bt/ftmap.cmo _build/src/graph/ftgraph.cmo _build/src/test/graph/main.cmo

_build/src/bt/avl.cmo : src/bt/avl.ml | _build/src/bt/
_build/src/bt/avl.cmx : src/bt/avl.ml | _build/src/bt/
_build/src/bt/ftmap.cmo : src/bt/ftmap.ml | _build/src/bt/
_build/src/bt/ftmap.cmx : src/bt/ftmap.ml | _build/src/bt/
_build/src/graph/ftgraph.cmi : src/graph/ftgraph.mli _build/src/graph/ftgraph_intf.cmi | _build/src/graph/
_build/src/graph/ftgraph.cmo : src/graph/ftgraph.ml _build/src/bt/avl.cmo _build/src/bt/ftmap.cmo _build/src/graph/ftgraph.cmi _build/src/graph/ftgraph_intf.cmi | _build/src/graph/
_build/src/graph/ftgraph.cmx : src/graph/ftgraph.ml _build/src/bt/avl.cmx _build/src/bt/ftmap.cmx _build/src/graph/ftgraph.cmi _build/src/graph/ftgraph_intf.cmi | _build/src/graph/
_build/src/graph/ftgraph_intf.cmi : src/graph/ftgraph_intf.mli | _build/src/graph/
_build/src/test/graph/main.cmo : src/test/graph/main.ml _build/src/graph/ftgraph.cmi _build/src/graph/ftgraph_intf.cmi | _build/src/test/graph/
_build/src/test/graph/main.cmx : src/test/graph/main.ml _build/src/graph/ftgraph.cmx _build/src/graph/ftgraph_intf.cmi | _build/src/test/graph/
