(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   shared_intf.mli                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/02 11:34:11 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/13 11:58:58 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* TODO: move result to Fterror.ml file OR switch to ocaml 4.03.0 *)
type ('a, 'b) result =
  | Ok of 'a
  | Error of 'b

(* Modules are instanciated in main.ml *)

(* Module Graph (Common to all displays) *)
module type Graph_intf =
  sig
    type key
    module KeySet : Avl.S
           with type elt = key

    val string_of_keyset : KeySet.t -> string

    (* Vertex Label (attached to G.V.t) *)
    module Vlabel : sig
      type state = Step | Spell of string
      type t = {
          cost : KeySet.t list
        ; state : state
        }

      val create_spell : KeySet.t list -> string -> t
      val create_step : KeySet.t list -> t
      val to_string : t -> string
    end

    (* Edge Label (attached to G.E.t) *)
    module Elabel : sig
      type t = KeySet.t

      val compare : t -> t -> int
      val default : t
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
    type keyset

    val create_err : in_channel -> ((t * key list), string) result
    val on_key_press_err : keyset -> t -> (t, string) result
  end

(* Module Display (Specific to display) *)
module type Display_intf =
  sig
    type key
    type vertex
    type edge

    val declare_vertex : vertex -> unit
    val declare_edge : edge -> unit
    val focus_vertex_err : vertex -> (unit, string) result
    val run_err : unit -> (unit, string) result
  end

(* Module Key (Specific to display) *)
module type Key_intf =
  sig
    type t

    val default : t
    val of_string_err : string -> (t, string) result
    val to_string : t -> string
    val compare : t -> t -> int

  end

module type Make_algo_intf =
  functor (Key : Key_intf) ->
  functor (Graph : Graph_intf
           with type key = Key.t) ->
  functor (Display : Display_intf
           with type key = Key.t
           with type vertex = Graph.V.t
           with type edge = Graph.E.t) ->
  Algo_intf
  with type key = Key.t
  with type keyset = Graph.KeySet.t

module type Make_graph_intf =
  functor (Key : Key_intf) ->
  Graph_intf
  with type key = Key.t
