(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   graph_inst.ml                                      :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/14 13:59:02 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/21 15:07:11 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make (KeyPair : Shared_intf.KeyPair_intf)
       : (Shared_intf.Graph_inst_intf
          with module KP = KeyPair) =
  struct
    module KP = KeyPair

    module Vlabel =
      struct
        type state = Step | Spell of string
        type t = {
            cost : KP.Set.t list
          ; state : state
          }

        let create_spell cost name =
          {cost ; state = Spell name}

        let create_step cost =
          {cost; state = Step}

        let to_string ?(color=true) {cost; state} =
          let t = match state with
            | Step -> ""
            | Spell name -> String.concat "" [name; "\n"]
          in
          ListLabels.fold_left
            ~f:(fun acc kset ->
              (KeyPair.Set.to_string ~color kset)::acc) ~init:[] cost
          |> String.concat "\n"
          |> (fun str -> if color
                         then Printf.sprintf "\027[35m%s\027[0m[ %s ]" t str
                         else Printf.sprintf "%s%s" t str)

        let get_cost {cost} =
          cost

        let is_spell {state} =
          match state with
          | Step -> false
          | _ -> true

      end

    module Elabel =
      struct
        type t = KP.Set.t

        let default = KeyPair.Set.empty

        let to_string ?(color=false) v =
          KeyPair.Set.to_string ~color v

        let compare = KeyPair.Set.compare
      end

    include Ftgraph.Make_PersistentDigraphAbstractLabeled(Vlabel)(Elabel)
  end
