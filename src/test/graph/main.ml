(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/06 16:51:20 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/08 16:49:17 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module V =
  struct
    type t = {
        name : string
      }
  end

module E =
  struct
    type t = {
        name : string
      }
    let compare a b =
      0
    let default =
      { name = "dflt" }
  end

module type Sig = Ftgraph_intf.PersistentDigraphAbstractLabeled_intf
module FTG : (Sig
              with type V.label = V.t) =
  Ftgraph.Make_PersistentDigraphAbstractLabeled(V)(E)
module G : (Sig with type V.label = V.t) =
  struct
    include Graph.Persistent.Digraph.AbstractLabeled(V)(E)

    let invariants _ = true
    let binary_find_succ_e _ _ _ = None
  end

module Both =
  struct
    type t = FTG.t * G.t
    type vertex = FTG.vertex * G.vertex

    module V =
      struct
        let create label =
          FTG.V.create label,
          G.V.create label
      end

    (* let iter_vertex f (ftg, g) = *)
    (*   FTG.iter_vertex f ftg, *)
    (*   G.iter_vertex f g *)

    let empty = FTG.empty, G.empty

    let add_vertex (ftg, g) (ftgv, gv) =
      FTG.add_vertex ftg ftgv,
      G.add_vertex g gv


  end

let run g =
  let g = Both.V.create {V.name = "v1"} in
  (* Both.fold_vertex *)
  ()


let () =
  run Both.empty;
  Printf.eprintf "PASSING!!!\n%!";
  ()
