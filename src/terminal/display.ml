(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   display.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Ngo <ngoguey@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/03 17:26:03 by Ngo               #+#    #+#             *)
(*   Updated: 2016/06/10 14:59:08 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make : Term_intf.Make_display_intf =
  functor (Key : Term_intf.Key_intf) ->
  functor (Graph : Shared_intf.Graph_intf
           with type Elabel.key = Key.t) ->
  functor (Algo : Shared_intf.Algo_intf
           with type key = Key.t) ->
  struct

    type key = Key.t
    type vertex = Graph.V.t
    type edge = Graph.E.t

    let declare_key _ =
      Printf.eprintf "\t\tDisplay.declare_key()\n%!";
      Printf.eprintf "\t\t  Print key info to terminal\n%!";
      ()

    let declare_vertex v =
      Printf.eprintf "\t\tDisplay.declare_vertex(%s)\n%!"
                     (Graph.V.label v |> Graph.Vlabel.to_string);
      ()

    let declare_edge e =
      Printf.eprintf "\t\tDisplay.declare_edge(src:%s label:%s dst:%s)\n%!"
                     (Graph.E.src e |> Graph.V.label |> Graph.Vlabel.to_string)
                     (Graph.E.label e |> Graph.Elabel.to_string)
                     (Graph.E.dst e |> Graph.V.label |> Graph.Vlabel.to_string);
      ()

    let focus_vertex _ =
      Printf.eprintf "\t\tDisplay.focus_vertex()\n%!";
      Printf.eprintf "\t\t  Print current state info to terminal\n%!";
      ()

    let run () =
      Printf.eprintf "Display.run()\n%!";
      Printf.eprintf "  if stdin open, pass stdin\n%!";
      Printf.eprintf "  elseif argv[1] can be open, pass file\n%!";
      Printf.eprintf "  else, error print usage\n%!";

      let dat, keys = Algo.create stdin in
      Printf.eprintf "  wait for key_press\n%!";

      Printf.eprintf "**key press**\n%!";
      Printf.eprintf "  Convert 1 (or more) byte(s) read to a Key.t\n%!";
      let k = Key.of_bytes "" in
      Printf.eprintf "  pass Key.t and Algo.t to Algo.on_key_press()\n%!";

      let dat = Algo.on_key_press k dat in
      Printf.eprintf "**key press**\n%!";
      Printf.eprintf "repeat...\n%!";
      ()

  end
