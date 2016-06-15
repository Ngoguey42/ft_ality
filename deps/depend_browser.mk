MKGEN_SRCSBIN_BROWSER := _build/src/main/shared/gamekey.cmo _build/src/main/browser/main.cmo _build/src/bt/avl.cmo _build/src/bt/ftmap.cmo _build/src/graph/ftgraph.cmo _build/src/main/shared/keypair.cmo _build/src/main/shared/graph_inst.cmo _build/src/main/shared/algo.cmo

_build/src/bt/avl.cmo : src/bt/avl.ml | _build/src/bt/
_build/src/bt/avl.cmx : src/bt/avl.ml | _build/src/bt/
_build/src/bt/ftmap.cmo : src/bt/ftmap.ml | _build/src/bt/
_build/src/bt/ftmap.cmx : src/bt/ftmap.ml | _build/src/bt/
_build/src/graph/ftgraph.cmi : src/graph/ftgraph.mli _build/src/graph/ftgraph_intf.cmi | _build/src/graph/
_build/src/graph/ftgraph.cmo : src/graph/ftgraph.ml _build/src/bt/avl.cmo _build/src/bt/ftmap.cmo _build/src/graph/ftgraph.cmi _build/src/graph/ftgraph_intf.cmi | _build/src/graph/
_build/src/graph/ftgraph.cmx : src/graph/ftgraph.ml _build/src/bt/avl.cmx _build/src/bt/ftmap.cmx _build/src/graph/ftgraph.cmi _build/src/graph/ftgraph_intf.cmi | _build/src/graph/
_build/src/graph/ftgraph_intf.cmi : src/graph/ftgraph_intf.mli | _build/src/graph/
_build/src/main/browser/main.cmo : src/main/browser/main.ml | _build/src/main/browser/
_build/src/main/browser/main.cmx : src/main/browser/main.ml | _build/src/main/browser/
_build/src/main/shared/algo.cmo : src/main/shared/algo.ml _build/src/main/shared/shared_intf.cmi | _build/src/main/shared/
_build/src/main/shared/algo.cmx : src/main/shared/algo.ml _build/src/main/shared/shared_intf.cmi | _build/src/main/shared/
_build/src/main/shared/gamekey.cmo : src/main/shared/gamekey.ml | _build/src/main/shared/
_build/src/main/shared/gamekey.cmx : src/main/shared/gamekey.ml | _build/src/main/shared/
_build/src/main/shared/graph_inst.cmo : src/main/shared/graph_inst.ml _build/src/graph/ftgraph.cmi _build/src/main/shared/shared_intf.cmi | _build/src/main/shared/
_build/src/main/shared/graph_inst.cmx : src/main/shared/graph_inst.ml _build/src/graph/ftgraph.cmx _build/src/main/shared/shared_intf.cmi | _build/src/main/shared/
_build/src/main/shared/keypair.cmo : src/main/shared/keypair.ml _build/src/bt/avl.cmo _build/src/main/shared/shared_intf.cmi | _build/src/main/shared/
_build/src/main/shared/keypair.cmx : src/main/shared/keypair.ml _build/src/bt/avl.cmx _build/src/main/shared/shared_intf.cmi | _build/src/main/shared/
_build/src/main/shared/shared_intf.cmi : src/main/shared/shared_intf.mli _build/src/bt/avl.cmo _build/src/graph/ftgraph_intf.cmi | _build/src/main/shared/
