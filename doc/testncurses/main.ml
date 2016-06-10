


(*
ocamlfind ocamlc -package curses -linkpkg main.ml && ./a.out
 *)
(* module C = Curses	 *)

let () =
  let w = Curses.initscr () in

  Printf.eprintf "Hello world\n%!";

  let ch = Curses.getch () in
  Printf.eprintf "Code: `%d`\n%!" ch;

  Printf.eprintf "Hello world\n%!";
  ignore(Curses.endwin())
