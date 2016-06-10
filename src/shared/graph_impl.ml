(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   graph_impl.ml                                      :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/10 12:46:24 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/10 14:58:04 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make : Shared_intf.Make_graph_intf =
  functor (Key : Shared_intf.Key_intf) ->
  struct
    module Vlabel =
      struct
        type combo = {
            name : string
          }
        type t = Step of string | Combo of combo

        let of_combo_name name =
          Combo {name}

        let to_string = function
          | Step name -> Printf.sprintf "step`%s`" name
          | Combo {name} -> Printf.sprintf "combo`%s`" name

      end

    module Elabel =
      struct
        type key = Key.t
        module KeySet = Avl.Make(Key)
        type t = KeySet.t

        let compare a b =
          0

        let default = KeySet.empty

        let of_key_list lst =
          KeySet.of_list lst

        let to_string label =
          KeySet.fold (fun e acc ->
              (Key.to_string e)::acc
            ) label []
          |> String.concat "; "
          |> Printf.sprintf "[%s]"

      end

    include Ftgraph.Make_PersistentDigraphAbstractLabeled(Vlabel)(Elabel)

  end
