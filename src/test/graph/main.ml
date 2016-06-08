(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/06 16:51:20 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/08 15:41:23 by ngoguey          ###   ########.fr       *)
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

module Ftgraph = Ftgraph.Make_PersistentDigraphAbstractLabeled(V)(E)
module Graph = Graph.Persistent.Digraph.AbstractLabeled(V)(E)

let () =
  Printf.eprintf "PASSING!!!\n%!";
