MKGEN_SRCSBIN_TESTGRAPH := _build/src/test/graph/main.cmx _build/src/bt/avl.cmx _build/src/bt/ftmap.cmx _build/src/graph/graph.cmx

_build/src/bt/avl.cmo : src/bt/avl.ml | _build/src/bt/
_build/src/bt/avl.cmx : src/bt/avl.ml | _build/src/bt/
_build/src/bt/ftmap.cmo : src/bt/ftmap.ml _build/src/bt/avl.cmo | _build/src/bt/
_build/src/bt/ftmap.cmx : src/bt/ftmap.ml _build/src/bt/avl.cmx | _build/src/bt/
_build/src/graph/graph.cmi : src/graph/graph.mli _build/src/graph/graph_intf.cmi | _build/src/graph/
_build/src/graph/graph.cmo : src/graph/graph.ml _build/src/bt/avl.cmo _build/src/graph/graph.cmi _build/src/graph/graph_intf.cmi | _build/src/graph/
_build/src/graph/graph.cmx : src/graph/graph.ml _build/src/bt/avl.cmx _build/src/graph/graph.cmi _build/src/graph/graph_intf.cmi | _build/src/graph/
_build/src/graph/graph_intf.cmi : src/graph/graph_intf.mli | _build/src/graph/
_build/src/test/graph/main.cmo : src/test/graph/main.ml | _build/src/test/graph/
_build/src/test/graph/main.cmx : src/test/graph/main.ml | _build/src/test/graph/
