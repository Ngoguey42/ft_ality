(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   algo.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Ngo <ngoguey@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/03 17:26:21 by Ngo               #+#    #+#             *)
(*   Updated: 2016/06/11 18:14:11 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make : Shared_intf.Make_algo_intf =
  functor (Key : Shared_intf.Key_intf) ->
  functor (Graph : Shared_intf.Graph_intf
           with type key = Key.t) ->
  functor (Display : Shared_intf.Display_intf
           with type key = Key.t
           with type vertex = Graph.V.t
           with type edge = Graph.E.t) ->
  struct
    type t = {
        g : Graph.t
      }
    type key = Key.t
    module StrKeyMap = Ftmap.Make(struct
                                   type t = string
                                   let compare = compare
                                 end)

    let keys_of_channel chan =
      Printf.eprintf "\t  read bindings from file\n%!";
      Printf.eprintf "\t    build a (Key.t list) to return to Display\n%!";
      Printf.eprintf "\t    build a ((string * Key.t) Map) temporary\n%!";
      Printf.eprintf "\t    foreach shortcuts: call Key.of_string()\n%!";
      let l =  [ ("Left", "left")
               ; ("[BK]", "s")
               ; ("[FK]", "w")]
      in
      (* val fold_left : ('a -> 'b -> 'a) -> 'a -> 'b list -> 'a *)
      List.fold_left (fun (lst, map) ((action, key) as dat) ->
          let k = Key.of_strings dat in
          k::lst, StrKeyMap.add action k map
        ) ([], StrKeyMap.empty) l


    let graph_of_channel_and_keys chan kmap =
      let g = Graph.empty in
      Printf.eprintf "\t  EXEMPLE WITH: Super Punch:[BK],[FK]+Left\n%!";
      Printf.eprintf "\t  read fsa from file and build graph\n%!";
      Printf.eprintf "\t    add an origin vertex to graph\n%!";
      let orig = Graph.V.create (Graph.Vlabel.create_step []) in
      let g = Graph.add_vertex g orig in

      Printf.eprintf "\t    foreach combos:\n%!";
      Printf.eprintf "\t      foreach simultaneous presses required by combo\n%!";
      Printf.eprintf "\t        insert a vertex (if missing)\n%!";
      Printf.eprintf "\t          if last key: tag vertex as Combo\n%!";
      Printf.eprintf "\t          else: tag vertex as Step\n%!";
      Printf.eprintf "\t        create an edge to this vertex\n%!";
      Printf.eprintf "\t          label containing Keys (set of simultaneous keys to be pressed)\n%!";
      Printf.eprintf "\t          if first key: link src with origin\n%!";
      Printf.eprintf "\t          else: link src previous Step\n%!";

      let bk_kset = Graph.KeySet.of_list [
                        StrKeyMap.find_exn "[BK]" kmap] in
      let fkleft_kset = Graph.KeySet.of_list [
                            StrKeyMap.find_exn "[FK]" kmap
                          ; StrKeyMap.find_exn "Left" kmap] in

      let v1 = Graph.V.create
               @@ Graph.Vlabel.create_step [bk_kset]
      in
      let v2 = Graph.V.create
               @@ Graph.Vlabel.create_spell [fkleft_kset; bk_kset] "Super Punch"
      in

      let e1 = Graph.E.create orig bk_kset v1 in
      let e2 = Graph.E.create v1 fkleft_kset v2 in

      let g = Graph.add_edge_e g e1 in
      let g = Graph.add_edge_e g e2 in

      Printf.eprintf "\t    declare all vertices with Display.declare_vertex()\n%!";
      Graph.iter_vertex (fun v ->
          Display.declare_vertex v;
        ) g;
      Printf.eprintf "\t    declare all edges with Display.declare_edge()\n%!";
      Graph.iter_vertex (fun v ->
          Graph.iter_succ_e (fun e ->
              Display.declare_edge e
            ) g v
        ) g;
      g

    let create chan =
      Printf.eprintf "\tAlgo.create()\n%!";
      Printf.eprintf "\t  Read channel and init self data\n%!";
      let klst, kmap = keys_of_channel chan in
      let g = graph_of_channel_and_keys chan kmap in
      Printf.eprintf "\t  Return inner state saved in type t for later use\n%!";
      {g}, []

    let on_key_press k env =
      Printf.eprintf "\tAlgo.on_key_press()\n%!";
      Printf.eprintf "\t  update inner states and notify Display for vertex focus\n%!";
      (* Display.focus_vertex {Vertex.id = 42}; *)
      Printf.eprintf "\t  Return inner state saved in type t for later use\n%!";
      env

  end
