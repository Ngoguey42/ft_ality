(**************************************************************************)
(*                                                                        *)
(*  Ocamlgraph: a generic graph library for OCaml                         *)
(*  Copyright (C) 2004-2010                                               *)
(*  Sylvain Conchon, Jean-Christophe Filliatre and Julien Signoles        *)
(*                                                                        *)
(*  This software is free software; you can redistribute it and/or        *)
(*  modify it under the terms of the GNU Library General Public           *)
(*  License version 2.1, with the special exception on linking            *)
(*  described in file LICENSE.                                            *)
(*                                                                        *)
(*  This software is distributed in the hope that it will be useful,      *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                  *)
(*                                                                        *)
(**************************************************************************)

open Sig
open Blocks

module P = Make(Make_Map)

type 'a abstract_vertex = { tag : int; label : 'a }

(* Vertex for the abstract persistent graphs. *)
module AbstractVertex(V: sig type t end) = struct
  type label = V.t
  type t = label abstract_vertex
  let compare x y = Pervasives.compare x.tag y.tag
  let hash x = x.tag
  let equal x y = x.tag = y.tag
  let label x = x.label
  let create l =
    if !cpt_vertex = first_value_for_cpt_vertex - 1 then
      invalid_arg "Too much vertices";
    incr cpt_vertex;
    { tag = !cpt_vertex; label = l }
end

module Digraph = struct

  module AbstractLabeled(V: sig type t end)(Edge: ORDERED_TYPE_DFT) = struct

    include P.Digraph.AbstractLabeled(AbstractVertex(V))(Edge)

    let empty = { edges = G.empty; size = 0 }

    let add_vertex g v =
      if mem_vertex g v then
        g
      else
        { edges = G.unsafe_add_vertex g.edges v;
          size = Pervasives.succ g.size }

    let add_edge_e g (v1, l, v2) =
      let g = add_vertex g v1 in
      let g = add_vertex g v2 in
      { g with edges = G.unsafe_add_edge g.edges v1 (v2, l) }

    let add_edge g v1 v2 = add_edge_e g (v1, Edge.default, v2)

    let remove_vertex g v =
      if HM.mem v g.edges then
        let remove v s =
          S.fold
            (fun (v2, _ as e) s -> if not (V.equal v v2) then S.add e s else s)
            s S.empty
        in
        let edges = HM.remove v g.edges in
        { edges =
            HM.fold (fun k s g -> HM.add k (remove v s) g) edges HM.empty;
          size = Pervasives.pred g.size }
      else
        g

    let remove_edge g v1 v2 = { g with edges = remove_edge g v1 v2 }
    let remove_edge_e g e = { g with edges = remove_edge_e g e }

  end

end
