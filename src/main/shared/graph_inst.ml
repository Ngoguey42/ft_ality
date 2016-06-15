(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   graph_inst.ml                                      :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/14 13:59:02 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/15 11:53:44 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make (KeyPair : Shared_intf.KeyPair_intf)
       : (Shared_intf.Graph_impl_intf
          with type kpset = KeyPair.Set.t) =
  struct
    type kpset = KeyPair.Set.t

    module Vlabel =
      struct
        type state = Step | Spell of string
        type t = {
            cost : kpset list
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
            ~f:(fun acc kset -> (KeyPair.Set.to_string kset)::acc) ~init:[] cost
          |> String.concat "; "
          |> Printf.sprintf "\027[35m%s\027[0m[ %s ]" t

        let get_cost {cost} =
          cost
      end

    module Elabel =
      struct
        type t = kpset

        let default = KeyPair.Set.empty

        let to_string = KeyPair.Set.to_string

        let compare = KeyPair.Set.compare
      end

    include Ftgraph.Make_PersistentDigraphAbstractLabeled(Vlabel)(Elabel)
  end
