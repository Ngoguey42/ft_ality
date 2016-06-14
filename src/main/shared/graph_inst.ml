(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   graph_inst.ml                                      :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/14 13:59:02 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/14 14:16:47 by ngoguey          ###   ########.fr       *)
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
          ListLabels.fold_right
            ~f:(fun kset acc -> (KeyCont.Set.to_string kset)::acc) ~init:[] cost
          |> String.concat "; "
          |> Printf.sprintf "%s[ %s ]" t
      end

    module Elabel =
      struct
        type t = KeyCont.Set.t

        let compare a b =
          KeyCont.Set.compare a b

        let default = KeyCont.Set.empty

        let to_string = KeyCont.Set.to_string

      end

    include Ftgraph.Make_PersistentDigraphAbstractLabeled(Vlabel)(Elabel)
  end
