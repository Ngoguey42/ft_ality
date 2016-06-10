(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   graph_intf.ml                                      :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/06 16:33:13 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/10 07:30:43 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* Implementation of graphs, matching interfaces from lri's OcamlGraph
 * Aim is to only implement a Persistent+Digraph+Abstract+Labeled graph
 * http://ocamlgraph.lri.fr/doc/Persistent.S.html
 *)

(* Available Persistent+Digraph:
 * https://github.com/backtracking/ocamlgraph/blob/master/src/persistent.ml
 * Digraph.Concrete
 * Digraph.ConcreteLabeled
 * Digraph.ConcreteBidirectional
 * Digraph.ConcreteBidirectionalLabeled
 * Digraph.Abstract
 * Digraph.AbstractLabeled
 *)


(* ************************************************************************** *)
(* http://ocamlgraph.lri.fr/doc/Sig.ANY_TYPE.html *************************** *)
module type Any_type_intf =
  sig
    type t
  end


(* ************************************************************************** *)
(* http://ocamlgraph.lri.fr/doc/Sig.ORDERED_TYPE.html *********************** *)
module type Ordered_type_intf =
  sig
    type t
    val compare : t -> t -> int
  end


(* ************************************************************************** *)
(* http://ocamlgraph.lri.fr/doc/Sig.ORDERED_TYPE_DFT.html ******************* *)
module type Ordered_type_dft_intf =
  sig
    include Ordered_type_intf
    val default : t
  end


(* ************************************************************************** *)
(* http://ocamlgraph.lri.fr/doc/Sig.COMPARABLE.html ************************* *)
module type Comparable_intf =
  sig
    type t
    (* val hash : t -> int *)
    (* val equal : t -> t -> bool *)
    val compare : t -> t -> int
  end


(* ************************************************************************** *)
(* http://ocamlgraph.lri.fr/doc/Sig.VERTEX.html ***************************** *)
module type Vertex_intf =
  sig
    type t
    include Comparable_intf
            with type t := t

    type label
    val create : label -> t
    val label : t -> label
  end


(* ************************************************************************** *)
(* http://ocamlgraph.lri.fr/doc/Sig.EDGE.html ******************************* *)
module type Edge_intf =
  sig
    type t
    (* In my implementation:
     * Always comparing label before src and dst
     * Enables label-directed search in binary_find_succ_e
     *)
    val compare : t -> t -> int

    type vertex
    val src : t -> vertex
    val dst : t -> vertex

    type label
    val create : vertex -> label -> vertex -> t
    val label : t -> label
  end


(* ************************************************************************** *)
(* http://ocamlgraph.lri.fr/doc/Sig.G.html ********************************** *)
module type G_intf =
  sig
    type t
    module V : Vertex_intf
    type vertex = V.t
    module E : (Edge_intf
               with type vertex = V.t)
    type edge = E.t
    (* val is_directed : bool *)

    val is_empty : t -> bool
    val nb_vertex : t -> int
    (* val nb_edges : t -> int *)
    (* val out_degree : t -> vertex -> int *)
    (* val in_degree : t -> vertex -> int *)

    val mem_vertex : t -> vertex -> bool
    (* val mem_edge : t -> vertex -> vertex -> bool *)
    (* val mem_edge_e : t -> edge -> bool *)
    (* val find_edge : t -> vertex -> vertex -> edge *)
    (* val find_all_edges : t -> vertex -> vertex -> edge list *)

    (* val succ : t -> vertex -> vertex list *)
    (* val pred : t -> vertex -> vertex list *)
    (* val succ_e : t -> vertex -> edge list *)
    (* val pred_e : t -> vertex -> edge list *)

    val iter_vertex : (vertex -> unit) -> t -> unit
    val fold_vertex : (vertex -> 'a -> 'a) -> t -> 'a -> 'a
    (* val iter_edges : (vertex -> vertex -> unit) -> t -> unit *)
    (* val fold_edges : (vertex -> vertex -> 'a -> 'a) -> t -> 'a -> 'a *)
    (* val iter_edges_e : (edge -> unit) -> t -> unit *)
    (* val fold_edges_e : (edge -> 'a -> 'a) -> t -> 'a -> 'a *)
    (* val map_vertex : (vertex -> vertex) -> t -> t *)

    (* val iter_succ : (vertex -> unit) -> t -> vertex -> unit *)
    (* val iter_pred : (vertex -> unit) -> t -> vertex -> unit *)
    (* val fold_succ : (vertex -> 'a -> 'a) -> t -> vertex -> 'a -> 'a *)
    (* val fold_pred : (vertex -> 'a -> 'a) -> t -> vertex -> 'a -> 'a *)

    (* val iter_succ_e : (edge -> unit) -> t -> vertex -> unit *)
    (* val fold_succ_e : (edge -> 'a -> 'a) -> t -> vertex -> 'a -> 'a *)
    (* val iter_pred_e : (edge -> unit) -> t -> vertex -> unit *)
    (* val fold_pred_e : (edge -> 'a -> 'a) -> t -> vertex -> 'a -> 'a *)


    (* Not Present in OcamlGraph *)
    val binary_find_succ_e : (E.label -> int) -> t -> vertex -> edge option

    val invariants : t -> bool
  end


(* ************************************************************************** *)
(* http://ocamlgraph.lri.fr/doc/Persistent.S.AbstractLabeled.html *********** *)
module type PersistentDigraphAbstractLabeled_intf =
  sig
    include G_intf

    val empty : t

    (* silently fails if vertex already binded *)
    val add_vertex : t -> vertex -> t

    (* silently fails if vertex not binded *)
    val remove_vertex : t -> vertex -> t

    (* val add_edge : t -> vertex -> vertex -> t *)

    (* add both vertices if not aleady binded
     * replace previous binding of edge if already binded *)
    val add_edge_e : t -> edge -> t

    (* removes all edges v1->v2 (0 or more), no matter the label
     * does nothing if v1 is not in graph
     * does nothing if v2 is not in graph *)
    val remove_edge : t -> vertex -> vertex -> t

    (* removes 0 or 1 edge v1->v2, with respect to label
     * does nothing if v1 is not in graph
     * does nothing if v2 is not in graph *)
    val remove_edge_e : t -> edge -> t
  end

module type Make_PersistentDigraphAbstractLabeled_intf =
  functor (V : Any_type_intf) ->
  functor (E : Ordered_type_dft_intf) ->
  PersistentDigraphAbstractLabeled_intf
  with type V.label = V.t
   and type E.label = E.t
