

- page 3 : moves and combos from fighting games
- page 3 : You will implement, train and run an automaton to recognise such moves from the list of key combinations
- page 3 : in the same way words are made with symbols, combos are made with keys
- page 3 : you will recreate a fighting game’s training mode

<BR>
- page 4 : set yourself up with an efficient workflow with external libraries

<BR>
- page 5 : files and stdout format to define yourself
- page 5 : only listed modules

<BR>
- page 6 : No coding stype is enforced
- page 6 : Makefile to build your entire project

<BR>
- page 7 : 2 parts: training the automaton, and running it

<BR>
- page 8 : Your automaton will be built at runtime, using grammar files that contain the moves to be learnt by the automaton
- page 8 : The file path of one grammar will be given in command line arguments.
- page 8 : you have to do is split (i.e. tokenize) your rule to get a list of tokens, and then give it to the automaton which will generate transitions for each token in succession.

<BR>
- bonus page 9 : tail recursions
- bonus page 9 : do not store previous inputs
- bonus page 9 : short and nested functions
- bonus page 9 : good mli files
- bonus page 10 : avoid exceptions, une options
- bonus page 10 : avoid imperative types
- bonus page 10 : graphical interface
- bonus page 10 : gamepad
- bonus page 10 : debug mode (aka graphical interface?)

<BR>
- page 12 : you are afforded some liberty to infer and interpret details from the subject, whichever way you see fit
- page 12 : include grammar files with your work, you are free to format them the way you want

<BR>
- video : implementer un mode d'entrainement dans un jeu de combat
- video : fichier grammaire avec paires Nom/Sequence

### Useful links

<BR>
> Theory of Computation by Harry H. Porter III
> - https://www.youtube.com/playlist?list=PLbtzT1TYeoMjNOGEiaRmm_vMIwUAidnQz
> - Lectures 1 to 12

<BR>
> Algorithms, Part I by Robert Sedgewick
> - https://www.youtube.com/playlist?list=PLqD_OdMOd_6YixsHkd9f4sNdof4IhIima
> - Lectures 44 to 48


#### `at school` from `docker quickstart terminal` run docker with shared volume
```sh
cd /Users/Shared
git clone https://github.com/Ngoguey42/tmp_ftality
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

#### `in docker -i` compile project
```sh
cd tmp_ftality
make
```
