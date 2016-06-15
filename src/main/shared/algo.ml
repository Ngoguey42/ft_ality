(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   algo.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Ngo <ngoguey@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/03 17:26:21 by Ngo               #+#    #+#             *)
(*   Updated: 2016/06/15 10:12:08 by ngoguey          ###   ########.fr       *)
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

    module Debug =
      struct
        let keylist =
          [
            ("Block", "q")
          ; ("Down", "down")
          ; ("Flip Stance", "w")
          ; ("Left", "left")
          ; ("Right", "right")
          ; ("Tag", "e")
          ; ("Throw", "a")
          ; ("Up", "up")
          ; ("[BK]", "4")
          ; ("[BP]", "2")
          ; ("[FK]", "3")
          ; ("[FP]", "1")
          ]

        let flip f b a =
          f a b

        let fill_graph orig g dicts =

          (* Key of action from dicts *)
          let k_of_a str =
            match KeyCont.BidirDict.key_of_action dicts str with
            | None -> assert false
            | Some v -> v
          in

          (* Key set action list *)
          let ks_of_al l =
            ListLabels.map ~f:k_of_a l
            |> KeyCont.Set.of_list
          in

          (* Vertex of graph or creation *)
          let find_vertex_or_create g kset_l =
            let is_vertex v =
              let kset_l' =
                Graph.V.label v
                |> Graph.Vlabel.get_cost
              in
              List.length kset_l = List.length kset_l'
              && ListLabels.for_all2
                   ~f:(fun a b ->
                     KeyCont.Set.compare a b = 0
                   ) kset_l kset_l'
            in
            match Graph.find_vertex is_vertex g with
            | None -> Graph.Vlabel.create_step kset_l
                      |> Graph.V.create
            | Some v -> v
          in

          (* Vertex list of action list list + name *)
          let vert_of_all_name g ll name =
            assert (List.length ll > 0);
            let rec aux (kset_l, verts) = function
              | hd::[] -> Graph.Vlabel.create_spell (hd::kset_l) name
                          |> Graph.V.create
                          |> flip List.cons verts
              | hd::tl -> let kset_l = hd::kset_l in
                          let v = find_vertex_or_create g kset_l in
                          aux (kset_l, v::verts) tl
              | [] -> assert false
            in
            ListLabels.map ~f:ks_of_al ll
            |> aux ([], [])
            |> List.rev
          in

          (* New edge list of vertex list *)
          let edges_of_vertices g vl =
            assert (List.length vl > 1);
            let rec aux acc = function
              | src::dst::tl when Graph.mem_edge g src dst ->
                 aux acc (dst::tl)
              | src::dst::tl ->
                 let kset = Graph.V.label dst |> Graph.Vlabel.get_cost |> List.hd in
                 let e = Graph.E.create src kset dst in
                 aux (e::acc) (dst::tl)
              | [] -> assert false
              | [_] -> acc
            in
            aux [] vl
          in

          (* graph of graph + combo *)
          let add_combo kll name g =
            vert_of_all_name g kll name
            |> List.cons orig
            |> edges_of_vertices g
            |> ListLabels.fold_left ~f:Graph.add_edge_e ~init:g
          in

          (* graph of graph + combos *)
          let add_combos combos g =
            ListLabels.fold_left
              ~f:(fun g (kll, name) ->
                add_combo kll name g) ~init:g combos
          in
          (* ; ("[BK]", "s") 4 *)
          (* ; ("[BP]", "d") 2 *)
          (* ; ("[FK]", "z") 3 *)
          (* ; ("[FP]", "x") 1 *)
          let moves =
            [
              ([["Left"; "[BP]"]; ["[BK]"]], "Horror Show")
            ; ([["Right"; "[BP]"]; ["[BP]"]], "Outworld Bash")
            ; ([["Left"; "[FK]"]; ["[FK]"]], "Tarkatan Blows")
            ; ([["Left"; "[FK]"]; ["[FP]"]; ["Right"; "[FP]"]], "Open Wound")
            ; ([["Left"; "[FK]"]; ["[BP]"]; ["[BP]"]], "Easy Kill")
            ; ([["Right"; "[BK]"]; ["[BK]"]], "Doom Kicks")
            ]
          in
          add_combos moves g

      end

    let keys_of_channel_err chan =
      Printf.eprintf "\t  read bindings from file\n%!";
      Printf.eprintf "\t    build a (Key.t list) to return to Display\n%!";
      Printf.eprintf "\t    build both dictionaries ((string * Key.t) Ftmap.t) ((Key.t * string) Ftmap.t) for future use\n%!";
      Printf.eprintf "\t    foreach shortcuts: call Key.of_string()\n%!";
      let rec aux klst dicts = function
        | [] ->
           Ok (klst, dicts)
        | (action, key)::tl ->
           match Key.of_string_err key with
           | Error msg -> Error msg
           | Ok k -> aux (k::klst) (KeyCont.BidirDict.add dicts action k) tl
      in
      aux [] KeyCont.BidirDict.empty Debug.keylist

    let of_channel_and_keys_err chan dicts =
      let g = Graph.empty in
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

      let g = Debug.fill_graph orig g dicts in
      Printf.eprintf "\t    declare all vertices with Display.declare_vertex()\n%!";
      Graph.iter_vertex (fun v ->
          Display.declare_vertex v;
        ) g;
      Printf.eprintf "\t    declare all edges with Display.declare_edge()\n%!";
      Graph.iter_vertex (fun v ->
          Printf.eprintf "\t    Vert:\n%!";
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
      Printf.eprintf "\tAlgo.on_key_press(%s)%!"
      @@ KeyCont.Set.to_string kset;

      Graph.fold_succ_e (fun e acc ->
          let s = Graph.E.label e
                  |> Graph.Elabel.to_string
          in
          s::acc
        ) g state []
      |> String.concat "; "
      |> Printf.eprintf " succ_e(%s)\n%!";

      let state =
        match Graph.binary_find_succ_e (Graph.Elabel.compare kset) g state with
        | None -> orig
        | Some e -> Graph.E.dst e
      in
      match Display.focus_vertex_err state with
      | Ok () ->
         Printf.eprintf "\n%!";
         Ok {dat with state}
      | Error msg -> Error msg

    let key_of_action {dicts} key =
      KeyCont.BidirDict.key_of_action dicts key

    let action_of_key {dicts} action =
      KeyCont.BidirDict.action_of_key dicts action

  end
