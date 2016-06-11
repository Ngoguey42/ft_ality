(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   graph_impl.ml                                      :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/10 12:46:24 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/11 18:18:38 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make : Shared_intf.Make_graph_intf =
  functor (Key : Shared_intf.Key_intf) ->
  struct

    type key = Key.t
    module KeySet = Avl.Make(Key)

    let string_of_keyset kset =
      KeySet.fold (fun e acc ->
          (Key.to_string e)::acc
        ) kset []
      |> String.concat "; "
      |> Printf.sprintf "\027[33m<%s>\027[0m"

    module Vlabel =
      struct
        type state = Step | Spell of string
        type t = {
            cost : KeySet.t list
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
            ~f:(fun kset acc -> (string_of_keyset kset)::acc) ~init:[] cost
          |> String.concat "; "
          |> Printf.sprintf "%s[ %s ]" t
      end

    module Elabel =
      struct
        type t = KeySet.t

        let compare a b =
          0

        let default = KeySet.empty

        let to_string = string_of_keyset

      end

    include Ftgraph.Make_PersistentDigraphAbstractLabeled(Vlabel)(Elabel)
  end
