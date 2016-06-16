(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   algo.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Ngo <ngoguey@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/03 17:26:21 by Ngo               #+#    #+#             *)
(*   Updated: 2016/06/16 09:22:10 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make (Key : Shared_intf.Key_intf)
            (GameKey : Shared_intf.GameKey_intf)
            (KeyPair : Shared_intf.KeyPair_intf
             with type key = Key.t
             with type gamekey = GameKey.t)
            (Graph : Shared_intf.Graph_impl_intf
             with type kpset = KeyPair.Set.t)
            (Display : Shared_intf.Display_intf
             with type keypair = KeyPair.t
             with type vertex = Graph.V.t
             with type edge = Graph.E.t)
       : (Shared_intf.Algo_intf
          with type key = Key.t
          with type keypair = KeyPair.t
          with type kpset = KeyPair.Set.t) =
  struct

    type t = {
        g : Graph.t
      ; state : Graph.V.t
      ; orig : Graph.V.t
      ; dicts : KeyPair.BidirDict.t
      }
    type key = Key.t
    type keypair = KeyPair.t
    type kpset = KeyPair.Set.t

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

          (* `keypair` of `str` from `dicts` *)
          let kp_of_str str =
            match GameKey.of_string_err str with
            | Error _ -> assert false
            | Ok gk -> match KeyPair.BidirDict.keypair_of_gamekey dicts gk with
                       | None -> assert false
                       | Some kp -> kp
          in

          (* `keypair set` of `str list` *)
          let kpset_of_strll l =
            ListLabels.map ~f:kp_of_str l
            |> KeyPair.Set.of_list
          in

          (* `vertex list` of `kpset list` + (`graph` | `create`) *)
          let find_vertex_or_create g kset_l =
            let is_vertex v =
              let kset_l' =
                Graph.V.label v
                |> Graph.Vlabel.get_cost
              in
              List.length kset_l = List.length kset_l'
              && ListLabels.for_all2
                   ~f:(fun a b ->
                     KeyPair.Set.compare a b = 0
                   ) kset_l kset_l'
            in
            match Graph.find_vertex is_vertex g with
            | None -> Graph.Vlabel.create_step kset_l
                      |> Graph.V.create
            | Some v -> v
          in

          (* `vertex list` of `str list list + `name` *)
          let vertices_of_strll_name g strll name =
            assert (List.length strll > 0);
            let rec aux (kset_l, verts) = function
              | hd::[] -> Graph.Vlabel.create_spell (hd::kset_l) name
                          |> Graph.V.create
                          |> flip List.cons verts
              | hd::tl -> let kset_l = hd::kset_l in
                          let v = find_vertex_or_create g kset_l in
                          aux (kset_l, v::verts) tl
              | [] -> assert false
            in
            ListLabels.map ~f:kpset_of_strll strll
            |> aux ([], [])
            |> List.rev
          in

          (* `new-edge list` of `vertex list` *)
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

          (* `graph` of `graph` + `stringified combo` *)
          let add_combo strll name g =
            vertices_of_strll_name g strll name
            |> List.cons orig
            |> edges_of_vertices g
            |> ListLabels.fold_left ~f:Graph.add_edge_e ~init:g
          in

          (* `graph` of `graph` + `stringified comboS` *)
          let add_combos combos g =
            ListLabels.fold_left
              ~f:(fun g (strll, name) ->
                add_combo strll name g) ~init:g combos
          in
          (* ; ("[BK]", "s") 4 *)
          (* ; ("[BP]", "d") 2 *)
          (* ; ("[FK]", "z") 3 *)
          (* ; ("[FP]", "x") 1 *)
          let moves =
            [
              ([["Right"; "[BP]"]; ["[BK]"]], "Horror Show")
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
      Ftlog.lvl 6;
      Ftlog.outnl "read bindings from file";
      Ftlog.lvl 8;
      Ftlog.outnl "build a (Key.t list) to return to Display";
      Ftlog.outnl "build both dictionaries ((string * Key.t) Ftmap.t) ((Key.t * string) Ftmap.t) for future use";
      Ftlog.outnl "foreach shortcuts: call Key.of_string()";
      let rec aux dicts = function
        | [] ->
           Ok dicts
        | (gamekey, key)::tl ->
           match KeyPair.of_strings_err gamekey key with
           | Error msg -> Error msg
           | Ok kp -> match KeyPair.BidirDict.add_err dicts kp with
                      | Error msg -> Error msg
                      | Ok dicts -> aux dicts tl
      in
      aux KeyPair.BidirDict.empty Debug.keylist

    let of_channel_and_keys_err chan dicts =
      let g = Graph.empty in
      Ftlog.lvl 6;
      Ftlog.outnl "read fsa from file and build graph";
      Ftlog.lvl 8;
      Ftlog.outnl "add an origin vertex to graph";
      let orig = Graph.V.create (Graph.Vlabel.create_step []) in
      let g = Graph.add_vertex g orig in

      Ftlog.outnl "foreach combos:";
      Ftlog.lvl 10;
      Ftlog.outnl "foreach simultaneous presses required by combo";
      Ftlog.lvl 12;
      Ftlog.outnl "insert a vertex (if missing)";
      Ftlog.lvl 14;
      Ftlog.outnl "if last key: tag vertex as Combo";
      Ftlog.outnl "else: tag vertex as Step";
      Ftlog.lvl 12;
      Ftlog.outnl "create an edge to this vertex";
      Ftlog.lvl 14;
      Ftlog.outnl "label containing Keys (set of simultaneous keys to be pressed)";
      Ftlog.outnl "if first key: link src with origin";
      Ftlog.outnl "else: link src previous Step";

      let g = Debug.fill_graph orig g dicts in
      Ftlog.lvl 8;
      Ftlog.outnl "declare all vertices with Display.declare_vertex()";
      Graph.iter_vertex (fun v ->
          Display.declare_vertex v;
        ) g;
      Ftlog.outnl "declare all edges with Display.declare_edge()";
      Graph.iter_vertex (fun v ->
          Graph.iter_succ_e (fun e ->
              Display.declare_edge e
            ) g v
        ) g;
      Ok {g; state = orig; orig; dicts}


    (* Exposed *)

    let create_err chan =
      Ftlog.lvl 4;
      Ftlog.outnl "Algo.create()";
      Ftlog.lvl 6;
      Ftlog.outnl "Read channel and init self data";
      match keys_of_channel_err chan with
      | Error msg ->
         Error msg
      | Ok kmap ->
         match of_channel_and_keys_err chan kmap with
         | Error msg ->
            Error msg
         | Ok dat ->
            Ftlog.lvl 6;
            Ftlog.outnl "Return inner state saved in type t for later use";
            Ok dat

    let on_key_press_err ({g; state; orig} as dat) kset =
      Ftlog.lvl 4;
      assert (Graph.mem_vertex g state);
      Ftlog.out "Algo.on_key_press(%s)"
      @@ KeyPair.Set.to_string kset;

      let state =
        match Graph.binary_find_succ_e (Graph.Elabel.compare kset) g state with
        | None -> orig
        | Some e -> Graph.E.dst e
      in
      Graph.fold_succ_e (fun e acc ->
          let s = Graph.E.label e
                  |> Graph.Elabel.to_string
          in
          s::acc
        ) g state []
      |> String.concat "; "
      |> Ftlog.out_raw " succ_e(%s)%!\n";
      match Display.focus_vertex_err state with
      | Ok () ->
         Ftlog.outnl "";
         Ok {dat with state}
      | Error msg -> Error msg

    let keypair_of_key {dicts} key =
      KeyPair.BidirDict.keypair_of_key dicts key
  end
