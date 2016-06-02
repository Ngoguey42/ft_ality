
set -e

ocamlfind ocamlc $@
printf "\033[32m%s\033[0m (from '%s')\n" $2 $0
js_of_ocaml -o $2.js $2
printf "\033[32m%s\033[0m (from '%s')\n" $2.js $0
