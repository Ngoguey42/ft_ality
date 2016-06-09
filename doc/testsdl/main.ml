
(*
ocamlfind ocamlc -package sdl -linkpkg main.ml && ./a.out
 *)

let () =
  Printf.eprintf "keyboard state: %b\n%!" @@ Sdlevent.get_state Sdlevent.KEYDOWN_EVENT;
  Sdl.init [`JOYSTICK; `TIMER; `EVENTTHREAD];
  Printf.eprintf "keyboard state: %b\n%!" @@ Sdlevent.get_state Sdlevent.KEYDOWN_EVENT;
  Sdlevent.enable_events Sdlevent.all_events_mask;;
  Printf.eprintf "keyboard state: %b\n%!" @@ Sdlevent.get_state Sdlevent.KEYDOWN_EVENT;

  let rec aux _ =
    (* Printf.eprintf "aux begin\n%!"; *)
    (* let _ = Sdlevent.wait () in *)
    Printf.eprintf "\n%!";
    Printf.eprintf "App state length: %d %!" @@ List.length (Sdlevent.get_app_state ());
    Printf.eprintf "Is key e pressed: %b%!" @@ Sdlkey.is_key_pressed Sdlkey.KEY_e;
    Printf.eprintf "Is KEY_UNKNOWN pressed: %b%!" @@ Sdlkey.is_key_pressed Sdlkey.KEY_UNKNOWN;
    Printf.eprintf "Modifiers state: %d%!" @@ Sdlkey.get_mod_state ();

    if Sdlevent.has_event () then (

      Printf.eprintf "Has event%!";

    ) else (

      Printf.eprintf "Has no event%!";

    );
    Printf.eprintf "\n%!";
    Unix.sleep 1;
    if true then
      aux ()
    else
      ()
  in
  aux ();
  ()
