MKGEN_SRCSBIN_TESTAVL := _build/src/bt/avl.cmx _build/src/test/test_avl/main.cmx

_build/src/bt/avl.cmo : src/bt/avl.ml | _build/src/bt/
_build/src/bt/avl.cmx : src/bt/avl.ml | _build/src/bt/
_build/src/test/test_avl/main.cmo : src/test/test_avl/main.ml _build/src/bt/avl.cmo | _build/src/test/test_avl/
_build/src/test/test_avl/main.cmx : src/test/test_avl/main.ml _build/src/bt/avl.cmx | _build/src/test/test_avl/
