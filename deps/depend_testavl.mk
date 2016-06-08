MKGEN_SRCSBIN_TESTAVL := _build/src/bt/avl.cmx _build/src/bt/ftmap.cmx _build/src/test/avl/main.cmx

_build/src/bt/avl.cmo : src/bt/avl.ml | _build/src/bt/
_build/src/bt/avl.cmx : src/bt/avl.ml | _build/src/bt/
_build/src/bt/ftmap.cmo : src/bt/ftmap.ml | _build/src/bt/
_build/src/bt/ftmap.cmx : src/bt/ftmap.ml | _build/src/bt/
_build/src/test/avl/main.cmo : src/test/avl/main.ml _build/src/bt/avl.cmo | _build/src/test/avl/
_build/src/test/avl/main.cmx : src/test/avl/main.ml _build/src/bt/avl.cmx | _build/src/test/avl/
