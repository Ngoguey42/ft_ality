(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   make_display.ml                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/02 12:01:27 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/02 14:30:14 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make_display : Shared_intf.Make_display_intf =
  functor (Algo : Shared_intf.Algo_intf) ->
  struct

    let declare_key _ =
      Printf.eprintf "\027[33m%s\027[0m\n%!" __LOC__;
      Printf.eprintf "\t\tDisplay.declare_key()\n%!";
      Printf.eprintf "\t\t  Print key info to terminal\n%!";
      ()

    let declare_vertex _ =
      Printf.eprintf "\027[33m%s\027[0m\n%!" __LOC__;
      Printf.eprintf "\t\tDisplay.declare_vertex()\n%!";
      Printf.eprintf "\t\t  (Do nothing ?)\n%!";
      ()
    let focus_vertex _ =
      Printf.eprintf "\027[33m%s\027[0m\n%!" __LOC__;
      Printf.eprintf "\t\tDisplay.focus_vertex()\n%!";
      Printf.eprintf "\t\t  Print current state info to terminal\n%!";
      ()

    let run () =
      Printf.eprintf "\027[33m%s\027[0m\n%!" __LOC__;
      Printf.eprintf "Display.run()\n%!";
      Printf.eprintf "  if stdin open, pass stdin\n%!";
      Printf.eprintf "  elseif argv[1] can be open, pass file\n%!";
      Printf.eprintf "  else, error print usage\n%!";

      let dat = Algo.create stdin in
      Printf.eprintf "  wait for key_press\n%!";

      Printf.eprintf "**key press**\n%!";
      Printf.eprintf "  convert readen code to Key.t (how ?)\n%!";
      Printf.eprintf "  pass Key.t and Algo.t to Algo.on_key_press()\n%!";
      let dat = Algo.on_key_press {Key.id = 42} dat in
      Printf.eprintf "**key press**\n%!";
      Printf.eprintf "repeat...\n%!";
      ()

  end
