(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   algo.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Ngo <ngoguey@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/03 17:26:21 by Ngo               #+#    #+#             *)
(*   Updated: 2016/06/10 11:40:21 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make : Shared_intf.Make_algo_intf =
  functor (Key : Shared_intf.Key_intf) ->
  functor (Graph : Shared_intf.Graph_intf
           with type Elabel.t = Key.t) ->
  functor (Display : Shared_intf.Display_intf
           with type key = Key.t
           with type vertex = Graph.V.t) ->
  struct
    type t = {
        tamere : int
      }
    type key = Key.t

    let create chan =
      Printf.eprintf "\tAlgo.create()\n%!";
      Printf.eprintf "\t  Read channel and init self data\n%!";
      Printf.eprintf "\t  Create a graph representing the FSA\n%!";
      Printf.eprintf "\t  foreach shortcuts: call Key.of_string() + Display.declare_key()\n%!";
      let k = Key.of_string "" in
      Display.declare_key k;
      Printf.eprintf "\t  foreach vertices: call Display.declare_vertex()\n%!";
      let v = Graph.V.create Graph.Vlabel.Step in
      Display.declare_vertex v;
      Printf.eprintf "\t  foreach edges: call Display.declare_edge()\n%!";
      Printf.eprintf "\t  Return inner state saved in type t for later use\n%!";
      {tamere = 42}

    let on_key_press k env =
      Printf.eprintf "\tAlgo.on_key_press()\n%!";
      Printf.eprintf "\t  update inner states and notify Display for vertex focus\n%!";
      (* Display.focus_vertex {Vertex.id = 42}; *)
      Printf.eprintf "\t  Return inner state saved in type t for later use\n%!";
      env

  end
