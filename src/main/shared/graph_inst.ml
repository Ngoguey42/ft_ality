(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   graph_inst.ml                                      :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/14 13:59:02 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/15 08:52:53 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make (Key : Shared_intf.Key_intf)
            (KeyCont : Shared_intf.Key_container_intf
             with type key = Key.t)
       : (Shared_intf.Graph_intf
          with type key = Key.t
          with type keyset = KeyCont.Set.t) =
  struct
    type key = Key.t
    type keyset = KeyCont.Set.t

    module Vlabel =
      struct
        type state = Step | Spell of string
        type t = {
            cost : KeyCont.Set.t list
          ; state : state
          }

        let create_spell cost name =
          {cost ; state = Spell name}

        let create_step cost =
          {cost; state = Step}

        let to_string {cost; state} =
          let t = match state with
            | Step -> "step"
            | Spell name -> name
          in
          ListLabels.fold_left
            ~f:(fun acc kset -> (KeyCont.Set.to_string kset)::acc) ~init:[] cost
          |> String.concat "; "
          |> Printf.sprintf "\027[35m%s\027[0m[ %s ]" t

        let get_cost {cost} =
          cost
      end

    module Elabel =
      struct
        type t = KeyCont.Set.t

        let default = KeyCont.Set.empty

        let to_string = KeyCont.Set.to_string

        let compare a b =
          (* Printf.eprintf "  Elabel.compare (%s) vs (%s) \n%!" *)
          (*                (to_string a) (to_string b); *)
          KeyCont.Set.compare a b

      end

    include Ftgraph.Make_PersistentDigraphAbstractLabeled(Vlabel)(Elabel)
  end
