MKGEN_SRCSBIN_TESTGRAPH := _build/src/graph/p_graph_intf.cmx _build/src/test/graph/main.cmx

_build/src/graph/graph_intf.cmi : src/graph/graph_intf.mli | _build/src/graph/
_build/src/graph/p_graph_intf.cmo : src/graph/p_graph_intf.ml _build/src/graph/graph_intf.cmi | _build/src/graph/
_build/src/graph/p_graph_intf.cmx : src/graph/p_graph_intf.ml _build/src/graph/graph_intf.cmi | _build/src/graph/
_build/src/test/graph/main.cmo : src/test/graph/main.ml | _build/src/test/graph/
_build/src/test/graph/main.cmx : src/test/graph/main.ml | _build/src/test/graph/
