(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   shared_intf.ml                                     :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/02 11:34:11 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/10 15:04:50 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* Modules are instanciated in main.ml *)

(* Module Graph (Common to all displays) *)
module type Graph_intf =
  sig
    (* Vertex Label (attached to G.V.t) *)
    module Vlabel : sig
      type combo = {
          name : string
        }
      type t = Step of string | Combo of combo

      val of_combo_name : string -> t
      val to_string : t -> string
    end

    (* Edge Label (attached to G.E.t) *)
    module Elabel : sig
      type key
      module KeySet : Avl.S
             with type elt = key
      type t = KeySet.t

      val of_key_list : key list -> t
      val to_string : t -> string
    end

    (* Graph implementation *)
    include Ftgraph_intf.PersistentDigraphAbstractLabeled_intf
            with type V.label = Vlabel.t
            with type E.label = Elabel.t
  end

(* Module Algo (Common to all displays) *)
module type Algo_intf =
  sig
    type t
    type key

    val create : in_channel -> t * key list
    val on_key_press : key -> t -> t
  end

(* Module Display (Specific to display) *)
module type Display_intf =
  sig
    type key
    type vertex
    type edge

    val declare_key : key -> unit
    val declare_vertex : vertex -> unit
    val declare_edge : edge -> unit
    val focus_vertex : vertex -> unit
    val run : unit -> unit
  end

(* Module Key (Specific to display) *)
module type Key_intf =
  sig
    type t

    val default : t
    val of_strings : string * string -> t
    val to_string : t -> string
    val compare : t -> t -> int

  end

module type Make_algo_intf =
  functor (Key : Key_intf) ->
  functor (Graph : Graph_intf
           with type Elabel.key = Key.t) ->
  functor (Display : Display_intf
           with type key = Key.t
           with type vertex = Graph.V.t
           with type edge = Graph.E.t) ->
  Algo_intf
  with type key = Key.t

module type Make_graph_intf =
  functor (Key : Key_intf) ->
  Graph_intf
  with type Elabel.key = Key.t
