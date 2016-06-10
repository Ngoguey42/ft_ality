(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   graph_impl.ml                                      :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/10 12:46:24 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/10 13:47:45 by ngoguey          ###   ########.fr       *)
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
        type t = Step | Combo of combo
      end

    module Elabel =
      struct
        type key = Key.t
        module KeySet = Avl.Make(Key)

        type t = KeySet.t


        let compare a b =
          0
        let default =
          KeySet.empty
          (* [Key.default] *)
      end

    include Ftgraph.Make_PersistentDigraphAbstractLabeled(Vlabel)(Elabel)

  end
