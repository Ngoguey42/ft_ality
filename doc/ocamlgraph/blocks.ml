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

(** Common implementation to persistent and imperative graphs. *)

open Sig

module OTProduct(X: ORDERED_TYPE)(Y: ORDERED_TYPE) = struct
  type t = X.t * Y.t
  let compare (x1, y1) (x2, y2) =
    let cv = X.compare x1 x2 in
    if cv != 0 then cv else Y.compare y1 y2
end

let first_value_for_cpt_vertex = 0
let cpt_vertex = ref first_value_for_cpt_vertex
(* global counter for abstract vertex *)

(* ************************************************************************* *)
(** {2 Association table builder} *)
(* ************************************************************************* *)

(** Common signature to an imperative/persistent association table *)
module type HM = sig
  type 'a return
  type 'a t
  type key
  val create : ?size:int -> unit -> 'a t
  val create_from : 'a t -> 'a t
  val empty : 'a return
  val clear: 'a t -> unit
  val is_empty : 'a t -> bool
  val add : key -> 'a -> 'a t -> 'a t
  val remove : key -> 'a t -> 'a t
  val mem : key -> 'a t -> bool
  val find : key -> 'a t -> 'a
  val find_and_raise : key -> 'a t -> string -> 'a
  (** [find_and_raise k t s] is equivalent to [find k t] but
      raises [Invalid_argument s] when [find k t] raises [Not_found] *)
  val iter : (key -> 'a -> unit) -> 'a t -> unit
  val map : (key -> 'a -> key * 'a) -> 'a t -> 'a t
  val fold : (key -> 'a -> 'b -> 'b) -> 'a t -> 'b -> 'b
  val copy : 'a t -> 'a t
end

module type TBL_BUILDER =
  functor(X: COMPARABLE) ->
  HM
  with type key = X.t

(** [HM] implementation using map *)
module Make_Map(X: COMPARABLE) = struct
  include Map.Make(X)
  type 'a return = 'a t
  let is_empty m = (m = empty)
  let create ?size:_ () = assert false
  (* never call and not visible for the user thank's to
     signature constraints *)
  let create_from _ = empty
  let copy m = m
  let map f m = fold (fun k v m -> let k, v = f k v in add k v m) m empty
  let find_and_raise k h s = try find k h with Not_found -> invalid_arg s
  let clear _ = assert false
  (* never call and not visible for the user thank's to
     signature constraints *)
end

(* ************************************************************************* *)
(** {2 Blocks builder} *)
(* ************************************************************************* *)

(** Common implementation to all (directed) graph implementations. *)
module Minimal(S: Set.S)(HM: HM) = struct

  type vertex = HM.key

  let is_directed = true
  let empty = HM.empty
  let create = HM.create
  let is_empty = HM.is_empty
  let copy = HM.copy
  let clear = HM.clear

  let nb_vertex g = HM.fold (fun _ _ -> succ) g 0
  let nb_edges g = HM.fold (fun _ s n -> n + S.cardinal s) g 0
  let out_degree g v =
    S.cardinal
      (try HM.find v g with Not_found -> invalid_arg "[ocamlgraph] out_degree")

  let mem_vertex g v = HM.mem v g

  let unsafe_add_vertex g v = HM.add v S.empty g
  let unsafe_add_edge g v1 v2 = HM.add v1 (S.add v2 (HM.find v1 g)) g

  let add_vertex g v = if HM.mem v g then g else unsafe_add_vertex g v

  let iter_vertex f = HM.iter (fun v _ -> f v)
  let fold_vertex f = HM.fold (fun v _ -> f v)

end

(** All the predecessor operations from the iterators on the edges *)
module Pred
    (S: sig
       module PV: COMPARABLE
       module PE: EDGE with type vertex = PV.t
       type t
       val mem_vertex : PV.t -> t -> bool
       val iter_edges : (PV.t -> PV.t -> unit) -> t -> unit
       val fold_edges : (PV.t -> PV.t -> 'a -> 'a) -> t -> 'a -> 'a
       val iter_edges_e : (PE.t -> unit) -> t -> unit
       val fold_edges_e : (PE.t -> 'a -> 'a) -> t -> 'a -> 'a
     end) =
struct

  open S

  let iter_pred f g v =
    if not (mem_vertex v g) then invalid_arg "[ocamlgraph] iter_pred";
    iter_edges (fun v1 v2 -> if PV.equal v v2 then f v1) g

  let fold_pred f g v =
    if not (mem_vertex v g) then invalid_arg "[ocamlgraph] fold_pred";
    fold_edges (fun v1 v2 a -> if PV.equal v v2 then f v1 a else a) g

  let pred g v = fold_pred (fun v l -> v :: l) g v []

  let in_degree g v =
    if not (mem_vertex v g) then invalid_arg "[ocamlgraph] in_degree";
    fold_pred (fun _ n -> n + 1) g v 0

  let iter_pred_e f g v =
    if not (mem_vertex v g) then invalid_arg "[ocamlgraph] iter_pred_e";
    iter_edges_e (fun e -> if PV.equal v (PE.dst e) then f e) g

  let fold_pred_e f g v =
    if not (mem_vertex v g) then invalid_arg "[ocamlgraph] fold_pred_e";
    fold_edges_e (fun e a -> if PV.equal v (PE.dst e) then f e a else a) g

  let pred_e g v = fold_pred_e (fun v l -> v :: l) g v []

end

(** Common implementation to all the labeled (directed) graphs. *)
module Labeled(V: COMPARABLE)(E: ORDERED_TYPE)(HM: HM with type key = V.t) =
struct

  module VE = OTProduct(V)(E)
  module S = Set.Make(VE)

  module E = struct
    type vertex = V.t
    type label = E.t
    type t = vertex * label * vertex
    let src (v, _, _) = v
    let dst (_, _, v) = v
    let label (_, l, _) = l
    let create v1 l v2 = v1, l, v2
    module C = OTProduct(V)(VE)
    let compare (x1, x2, x3) (y1, y2, y3) =
      C.compare (x1, (x3, x2)) (y1, (y3, y2))
  end
  type edge = E.t

  let mem_edge g v1 v2 =
    try S.exists (fun (v2', _) -> V.equal v2 v2') (HM.find v1 g)
    with Not_found -> false

  let mem_edge_e g (v1, l, v2) =
    try
      let ve = v2, l in
      S.exists (fun ve' -> VE.compare ve ve' = 0) (HM.find v1 g)
    with Not_found ->
      false

  exception Found of edge
  let find_edge g v1 v2 =
    try
      S.iter
        (fun (v2', l) -> if V.equal v2 v2' then raise (Found (v1, l, v2')))
        (HM.find v1 g);
      raise Not_found
    with Found e ->
      e

  let find_all_edges g v1 v2 =
    try
      S.fold
        (fun (v2', l) acc ->
           if V.equal v2 v2' then (v1, l, v2') :: acc else acc)
        (HM.find v1 g)
        []
    with Not_found ->
      []

  let unsafe_remove_edge g v1 v2 =
    HM.add
      v1
      (S.filter (fun (v2', _) -> not (V.equal v2 v2')) (HM.find v1 g))
      g

  let unsafe_remove_edge_e g (v1, l, v2) =
    HM.add v1 (S.remove (v2, l) (HM.find v1 g)) g

  let remove_edge g v1 v2 =
    if not (HM.mem v2 g) then invalid_arg "[ocamlgraph] remove_edge";
    HM.add
      v1
      (S.filter
         (fun (v2', _) -> not (V.equal v2 v2'))
         (HM.find_and_raise v1 g "[ocamlgraph] remove_edge"))
      g

  let remove_edge_e g (v1, l, v2) =
    if not (HM.mem v2 g) then invalid_arg "[ocamlgraph] remove_edge_e";
    HM.add
      v1
      (S.remove (v2, l) (HM.find_and_raise v1 g "[ocamlgraph] remove_edge_e"))
      g

  let iter_succ f g v =
    S.iter (fun (w, _) -> f w) (HM.find_and_raise v g "[ocamlgraph] iter_succ")
  let fold_succ f g v =
    S.fold (fun (w, _) -> f w) (HM.find_and_raise v g "[ocamlgraph] fold_succ")

  let iter_succ_e f g v =
    S.iter
      (fun (w, l) -> f (v, l, w))
      (HM.find_and_raise v g "[ocamlgraph] iter_succ_e")

  let fold_succ_e f g v =
    S.fold
      (fun (w, l) -> f (v, l, w))
      (HM.find_and_raise v g "[ocamlgraph] fold_succ_e")

  let succ g v = fold_succ (fun w l -> w :: l) g v []
  let succ_e g v = fold_succ_e (fun e l -> e :: l) g v []

  let map_vertex f =
    HM.map
      (fun v s -> f v, S.fold (fun (v, l) s -> S.add (f v, l) s) s S.empty)

  module I = struct
    type t = S.t HM.t
    module PV = V
    module PE = E
    let iter_edges f = HM.iter (fun v -> S.iter (fun (w, _) -> f v w))
    let fold_edges f = HM.fold (fun v -> S.fold (fun (w, _) -> f v w))
    let iter_edges_e f =
      HM.iter (fun v -> S.iter (fun (w, l) -> f (v, l, w)))
    let fold_edges_e f =
      HM.fold (fun v -> S.fold (fun (w, l) -> f (v, l, w)))
  end
  include I

  include Pred(struct include I let mem_vertex = HM.mem end)

end

module Make_Abstract
    (G: sig
       module HM: HM
       module S: Set.S
       include G with type t = S.t HM.t and type V.t = HM.key
       val remove_edge: t -> vertex -> vertex -> t
       val remove_edge_e: t -> edge -> t
       val unsafe_add_vertex: t -> vertex -> t
       val unsafe_add_edge: t -> vertex -> S.elt -> t
       val unsafe_remove_edge: t -> vertex -> vertex -> t
       val unsafe_remove_edge_e: t -> edge -> t
       val create: ?size:int -> unit -> t
       val clear: t -> unit
     end) =
struct

  module I = struct
    type t = { edges : G.t; size : int }

    type vertex = G.vertex
    type edge = G.edge

    module PV = G.V
    module PE = G.E

    let iter_edges f g = G.iter_edges f g.edges
    let fold_edges f g = G.fold_edges f g.edges
    let iter_edges_e f g = G.iter_edges_e f g.edges
    let fold_edges_e f g = G.fold_edges_e f g.edges
    let mem_vertex v g = G.mem_vertex g.edges v
    let create ?size () = { edges = G.create ?size (); size = 0 }
    let clear g = assert false
  end
  include I

  include Pred(I)

  (* optimisations *)

  let is_empty g = g.size = 0
  let nb_vertex g = g.size

  (* redefinitions *)
  module V = G.V
  module E = G.E
  module HM = G.HM
  module S = G.S

  let unsafe_add_edge = G.unsafe_add_edge
  let unsafe_remove_edge = G.unsafe_remove_edge
  let unsafe_remove_edge_e = G.unsafe_remove_edge_e
  let is_directed = G.is_directed

  let remove_edge g = G.remove_edge g.edges
  let remove_edge_e g = G.remove_edge_e g.edges

  let out_degree g = G.out_degree g.edges
  let in_degree g = G.in_degree g.edges

  let nb_edges g = G.nb_edges g.edges
  let succ g = G.succ g.edges
  let mem_vertex g = G.mem_vertex g.edges
  let mem_edge g = G.mem_edge g.edges
  let mem_edge_e g = G.mem_edge_e g.edges
  let find_edge g = G.find_edge g.edges
  let find_all_edges g = G.find_all_edges g.edges

  let iter_vertex f g = G.iter_vertex f g.edges
  let fold_vertex f g = G.fold_vertex f g.edges
  let iter_succ f g = G.iter_succ f g.edges
  let fold_succ f g = G.fold_succ f g.edges
  let succ_e g = G.succ_e g.edges
  let iter_succ_e f g = G.iter_succ_e f g.edges
  let fold_succ_e f g = G.fold_succ_e f g.edges
  let map_vertex f g = { g with edges = G.map_vertex f g.edges }

  (* reimplementation *)

  let copy g =
    let h = HM.create () in
    let vertex v =
      try
        HM.find v h
      with Not_found ->
        let v' = V.create (V.label v) in
        let h' = HM.add v v' h in
        assert (h == h');
        v'
    in
    map_vertex vertex g

end

(** Build persistent (resp. imperative) graphs from a persistent (resp.
    imperative) association table *)
module Make(F : TBL_BUILDER) = struct

  module Digraph = struct

    module AbstractLabeled(V: VERTEX)(E: ORDERED_TYPE_DFT) = struct
      module G = struct
        module V = V
        module HM = F(V)
        include Labeled(V)(E)(HM)
        include Minimal(S)(HM)
      end
      include Make_Abstract(G)
    end

  end

end
