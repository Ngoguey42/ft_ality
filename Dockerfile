
FROM ocaml/opam:debian
RUN echo 'eval `opam config env`' >> .bashrc
RUN sudo apt-get install ack-grep tree rlwrap -y

RUN opam switch 4.03.0
RUN eval `opam config env`

RUN opam install -y js_of_ocaml
RUN opam install -y ocamlgraph curses

# RUN opam depext ocamlsdl.0.9.1
# RUN opam install -y ocamlsdl

# RUN git clone https://github.com/Ngoguey42/mkgen #helllorr
# RUN echo 'export "PATH=$HOME/mkgen:$PATH"' >> .bashrc
