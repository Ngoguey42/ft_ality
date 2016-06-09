
FROM ocaml/opam:debian

RUN opam install -y js_of_ocaml

RUN sudo apt-get install ack-grep tree rlwrap -y

RUN opam install -y ocamlgraph

RUN opam depext ocamlsdl.0.9.1

RUN opam install -y ocamlsdl curses

# RUN git clone https://github.com/Ngoguey42/mkgen #helllorr
# RUN echo 'export "PATH=$HOME/mkgen:$PATH"' >> .bashrc
