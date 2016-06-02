MKGEN_SRCSBIN_TERMNAT := _build/src/shared/Key.cmx _build/src/shared/Vertex.cmx _build/src/shared/shared_intf.cmx _build/src/shared/make_algo.cmx _build/src/terminal/make_display.cmx _build/src/terminal/main.cmx

_build/src/shared/Key.cmo : src/shared/Key.ml | _build/src/shared/
_build/src/shared/Key.cmx : src/shared/Key.ml | _build/src/shared/
_build/src/shared/Vertex.cmo : src/shared/Vertex.ml | _build/src/shared/
_build/src/shared/Vertex.cmx : src/shared/Vertex.ml | _build/src/shared/
_build/src/shared/make_algo.cmo : src/shared/make_algo.ml _build/src/shared/Key.cmo _build/src/shared/Vertex.cmo _build/src/shared/shared_intf.cmo | _build/src/shared/
_build/src/shared/make_algo.cmx : src/shared/make_algo.ml _build/src/shared/Key.cmx _build/src/shared/Vertex.cmx _build/src/shared/shared_intf.cmx | _build/src/shared/
_build/src/shared/shared_intf.cmo : src/shared/shared_intf.ml _build/src/shared/Key.cmo _build/src/shared/Vertex.cmo | _build/src/shared/
_build/src/shared/shared_intf.cmx : src/shared/shared_intf.ml _build/src/shared/Key.cmx _build/src/shared/Vertex.cmx | _build/src/shared/
_build/src/terminal/main.cmo : src/terminal/main.ml _build/src/shared/make_algo.cmo _build/src/shared/shared_intf.cmo _build/src/terminal/make_display.cmo | _build/src/terminal/
_build/src/terminal/main.cmx : src/terminal/main.ml _build/src/shared/make_algo.cmx _build/src/shared/shared_intf.cmx _build/src/terminal/make_display.cmx | _build/src/terminal/
_build/src/terminal/make_display.cmo : src/terminal/make_display.ml _build/src/shared/Key.cmo _build/src/shared/shared_intf.cmo | _build/src/terminal/
_build/src/terminal/make_display.cmx : src/terminal/make_display.ml _build/src/shared/Key.cmx _build/src/shared/shared_intf.cmx | _build/src/terminal/
