
FROM ocaml/opam:debian

RUN opam install -y js_of_ocaml

RUN sudo apt-get install ack-grep tree rlwrap -y

# RUN git clone https://github.com/Ngoguey42/mkgen #helllorr
# RUN echo 'export "PATH=$HOME/mkgen:$PATH"' >> .bashrc
