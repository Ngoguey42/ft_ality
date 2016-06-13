(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   algo.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Ngo <ngoguey@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/03 17:26:21 by Ngo               #+#    #+#             *)
(*   Updated: 2016/06/13 14:02:33 by ngoguey          ###   ########.fr       *)
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
      ; state : Graph.V.t
      ; orig : Graph.V.t
      }
    type key = Key.t
    type keyset = Graph.KeySet.t
    module StrKeyMap = Ftmap.Make(struct
                                   type t = string
                                   let compare = compare
                                 end)


    (* Internal *)

    let keys_of_channel_err chan =
      Printf.eprintf "\t  read bindings from file\n%!";
      Printf.eprintf "\t    build a (Key.t list) to return to Display\n%!";
      Printf.eprintf "\t    build a ((string * Key.t) Map) temporary\n%!";
      Printf.eprintf "\t    foreach shortcuts: call Key.of_string()\n%!";
      let l =  [ ("Left", "left")
               ; ("[BK]", "s")
               ; ("[FK]", "w")]
      in
      let rec aux klst kmap = function
        | [] ->
           Ok (klst, kmap)
        | (action, key)::tl ->
           match Key.of_string_err key with
           | Error msg -> Error msg
           | Ok k -> aux (k::klst) (StrKeyMap.add action k kmap) tl
      in
      aux [] StrKeyMap.empty l

    let of_channel_and_keys_err chan kmap =
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
      Ok {g; state = orig; orig}


    (* Exposed *)

    let create_err chan =
      Printf.eprintf "\tAlgo.create()\n%!";
      Printf.eprintf "\t  Read channel and init self data\n%!";
      match keys_of_channel_err chan with
      | Error msg ->
         Error msg
      | Ok (klst, kmap) ->
         match of_channel_and_keys_err chan kmap with
         | Error msg ->
            Error msg
         | Ok dat ->
            Printf.eprintf "\t  Return inner state saved in type t for later use\n%!";
            Ok (dat, klst)

    let on_key_press_err kset ({g; state; orig} as dat) =
      assert (Graph.mem_vertex g state);
      Printf.eprintf "\tAlgo.on_key_press(%s)\n%!"
      @@ Graph.string_of_keyset kset;
		  Printf.eprintf "\t  update inner states and notify Display for vertex focus\n%!";

      let state =
        match Graph.binary_find_succ_e (Graph.Elabel.compare kset) g state with
        | None -> orig
        | Some e -> Graph.E.dst e
      in
      match Display.focus_vertex_err state with
      | Ok () ->
         Printf.eprintf "\t  Return inner state saved in type t for later use\n%!";
         Ok {dat with state}
      | Error msg -> Error msg

  end
