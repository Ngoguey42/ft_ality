(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   make_algo.ml                                       :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/02 11:50:40 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/02 14:30:01 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make_algo : Shared_intf.Make_algo_intf =
  functor (Display : Shared_intf.Display_intf) ->
  struct
    type t = {
        tamere : int
      }

    let create chan =
      Printf.eprintf "\027[33m%s\027[0m\n%!" __LOC__;
      Printf.eprintf "\tAlgo.create()\n%!";
      Printf.eprintf "\t  Read channel and init self data\n%!";
      Printf.eprintf "\t  Call Display.declare_key for each keys\n%!";
      Display.declare_key {Key.id = 42};
      Printf.eprintf "\t  Call Display.declare_vertex for each vertices\n%!";
      Display.declare_vertex {Vertex.id = 42};
      Printf.eprintf "\t  Call Display.declare_edge for each edges\n%!";
      Printf.eprintf "\t  Return inner state saved in type t for later use\n%!";
      {tamere = 42}

    let on_key_press k env =
      Printf.eprintf "\027[33m%s\027[0m\n%!" __LOC__;
      Printf.eprintf "\tAlgo.on_key_press()\n%!";
      Printf.eprintf "\t  update inner states and notify Display for vertex focus\n%!";
      Display.focus_vertex {Vertex.id = 42};
      Printf.eprintf "\t  Return inner state saved in type t for later use\n%!";
      env

  end
