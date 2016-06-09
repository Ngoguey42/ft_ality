
let () =
  Printf.eprintf "keyboard state: %b\n%!" @@ Sdlevent.get_state Sdlevent.KEYDOWN_EVENT;
  Sdl.init [`JOYSTICK; `TIMER; `EVENTTHREAD];
  Printf.eprintf "keyboard state: %b\n%!" @@ Sdlevent.get_state Sdlevent.KEYDOWN_EVENT;
  Sdlevent.enable_events Sdlevent.all_events_mask;;
  Printf.eprintf "keyboard state: %b\n%!" @@ Sdlevent.get_state Sdlevent.KEYDOWN_EVENT;

  let rec aux _ =
    (* Printf.eprintf "aux begin\n%!"; *)
    (* let _ = Sdlevent.wait () in *)
    Printf.eprintf "App state length: %d \n%!" @@ List.length (Sdlevent.get_app_state ());

    if Sdlevent.has_event () then (

      Printf.eprintf "Has event\n%!";

    ) else (

      Printf.eprintf "Has no event\n%!";

    );
    Unix.sleep 1;
    aux ()
  in
  aux ();
  ()
