


(*
ocamlfind ocamlc -package curses -linkpkg main.ml && ./a.out
 *)
(* module C = Curses	 *)

let () =
  (* let w = Curses.initscr () in *)

  (* let ch = Curses.getch () in *)
  (* Printf.eprintf "%d\n%!" ch; *)

  Printf.eprintf "Hello world\n%!";
  (* ignore(Curses.endwin()) *)
