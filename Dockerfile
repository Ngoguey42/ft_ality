
FROM ocaml/opam:debian

RUN opam install -y js_of_ocaml

RUN sudo apt-get install ack-grep tree -y

RUN git clone https://github.com/Ngoguey42/mkgen #hell
RUN echo 'export "PATH=$HOME/mkgen:$PATH"' >> .bashrc
