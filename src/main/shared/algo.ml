(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   algo.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Ngo <ngoguey@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/03 17:26:21 by Ngo               #+#    #+#             *)
(*   Updated: 2016/06/14 14:19:22 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make (Key : Shared_intf.Key_intf)
            (KeyCont : Shared_intf.Key_container_intf
             with type key = Key.t)
            (Graph : Shared_intf.Graph_intf
             with type key = Key.t
             with type keyset = KeyCont.Set.t)
            (Display : Shared_intf.Display_intf
             with type key = Key.t
             with type vertex = Graph.V.t
             with type edge = Graph.E.t)
       : (Shared_intf.Algo_intf
          with type key = Key.t
          with type keyset = KeyCont.Set.t) =
  struct

    type t = {
        g : Graph.t
      ; state : Graph.V.t
      ; orig : Graph.V.t
      ; dicts : KeyCont.BidirDict.t
      }
    type key = Key.t
    type keyset = KeyCont.Set.t


    (* Internal *)

    let keys_of_channel_err chan =
      Printf.eprintf "\t  read bindings from file\n%!";
      Printf.eprintf "\t    build a (Key.t list) to return to Display\n%!";
      Printf.eprintf "\t    build both dictionaries ((string * Key.t) Ftmap.t) ((Key.t * string) Ftmap.t) for future use\n%!";
      Printf.eprintf "\t    foreach shortcuts: call Key.of_string()\n%!";
      let l =  [ ("Left", "left")
               ; ("[BK]", "s")
               ; ("[FK]", "w")]
      in
      let rec aux klst dicts = function
        | [] ->
           Ok (klst, dicts)
        | (action, key)::tl ->
           match Key.of_string_err key with
           | Error msg -> Error msg
           | Ok k -> aux (k::klst) (KeyCont.BidirDict.add dicts action k) tl
      in
      aux [] KeyCont.BidirDict.empty l

    let of_channel_and_keys_err chan dicts =
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

      let k_of_a str =
        match KeyCont.BidirDict.key_of_action dicts str with
        | None -> assert false
        | Some v -> v
      in

      let bk_kset = KeyCont.Set.of_list [k_of_a "[BK]"] in
      let fkleft_kset = KeyCont.Set.of_list [k_of_a "[FK]"; k_of_a "Left"] in

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
      Ok {g; state = orig; orig; dicts}


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
      @@ KeyCont.Set.to_string kset;
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

    let key_of_action {dicts} key =
      KeyCont.BidirDict.key_of_action dicts key

    let action_of_key {dicts} action =
      KeyCont.BidirDict.action_of_key dicts action

  end
