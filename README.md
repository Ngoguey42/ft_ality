# Project FT_ALITY, Jun 2016
--------
<BR>

# How to:

#### `at school` run docker-machine, docker with shared volume
```sh
zsh --login "/Applications/Docker/Docker Quickstart Terminal.app/Contents/Resources/Scripts/start.sh"
cd /Users/Shared
git clone --recursive https://github.com/Ngoguey42/tmp_ftality
cd tmp_ftality
git pull origin master
docker build -t ftality_img .
docker run -it -v `pwd`:/home/opam/tmp_ftality ftality_img bash
```

#### `at school` from `docker quickstart terminal` repair cert when broken
```sh
docker-machine restart default
eval "$(docker-machine env default)"
```

#### `in docker -i` compile project for browser
```sh
cd tmp_ftality
make BUILD_MODE='browser'
```

#### `in terminal` compile project for terminal (native)
```sh
cd tmp_ftality
make BUILD_MODE='termnat'
```

#### `in terminal` compile project for terminal (bytecode)
```sh
cd tmp_ftality
make BUILD_MODE='termbyte'
```

#### `in docker -i` (re)generate depend_*.mk files
```sh
cd tmp_ftality
./mkgen/mkgenml
```


# Subject goals:

```
- page 3 : moves and combos from fighting games
- page 3 : You will implement, train and run an automaton to recognise such moves from the list of key combinations
- page 3 : in the same way words are made with symbols, combos are made with keys
- page 3 : you will recreate a fighting game’s training mode

- page 4 : set yourself up with an efficient workflow with external libraries

- page 5 : files and stdout format to define yourself
- page 5 : only listed modules

- page 6 : No coding stype is enforced
- page 6 : Makefile to build your entire project

- page 7 : 2 parts: training the automaton, and running it

- page 8 : Your automaton will be built at runtime, using grammar files that contain the moves to be learnt by the automaton
- page 8 : The file path of one grammar will be given in command line arguments.
- page 8 : you have to do is split (i.e. tokenize) your rule to get a list of tokens, and then give it to the automaton which will generate transitions for each token in succession.

- bonus page 9 : tail recursions
- bonus page 9 : do not store previous inputs
- bonus page 9 : short and nested functions
- bonus page 9 : good mli files
- bonus page 10 : avoid exceptions, une options
- bonus page 10 : avoid imperative types
- bonus page 10 : graphical interface
- bonus page 10 : gamepad
- bonus page 10 : debug mode (aka graphical interface?)

- page 12 : you are afforded some liberty to infer and interpret details from the subject, whichever way you see fit
- page 12 : include grammar files with your work, you are free to format them the way you want

- video : implementer un mode d'entrainement dans un jeu de combat
- video : fichier grammaire avec paires Nom/Sequence
```

# Useful links:

<BR>
> Theory of Computation by Harry H. Porter III
> - https://www.youtube.com/playlist?list=PLbtzT1TYeoMjNOGEiaRmm_vMIwUAidnQz
> - Lectures 1 to 12

<BR>
> Algorithms, Part I by Robert Sedgewick
> - https://www.youtube.com/playlist?list=PLqD_OdMOd_6YixsHkd9f4sNdof4IhIima
> - Lectures 44 to 48

<BR>
> Computerphile
> - https://www.youtube.com/watch?v=vhiiia1_hC4
> - https://www.youtube.com/watch?v=RjOCRYdg8BY
> - https://www.youtube.com/watch?v=224plb3bCog

<BR>
> OCaml Curses / NCurses
> - http://www.nongnu.org/ocaml-tmk/doc/Curses.html
> - http://git.savannah.gnu.org/cgit/ocaml-tmk.git/tree/curses.mli

<BR>
> Read char by char with termcap in OCaml
> - http://stackoverflow.com/questions/4130048/recognizing-arrow-keys-with-stdin
> - https://en.wikipedia.org/wiki/ANSI_escape_code

<BR>
> OCaml grammar
> - http://caml.inria.fr/pub/docs/manual-ocaml/language.html

<BR>
> Cytoscape.js, graph rendering in browser with js
> - http://js.cytoscape.org

<BR>
> Mortal kombat combos
> - http://www.eventhubs.com/guides/2012/nov/30/mortal-kombat-9-moves-characters-combos-and-strategy-guides/
