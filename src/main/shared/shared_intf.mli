(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   shared_intf.mli                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/02 11:34:11 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/14 16:07:39 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* Most modules define types, a module may use a type from an other module in
 *  its signature if it is defined below in the hierarchy.
 * Modules hierarchy:
 * - Key
 * - Key_containers
 * - Graph
 * - Display, Algo
 *)

(* Modules are instanciated in main.ml *)

(* Module Key (Specific to display) *)
module type Key_intf =
  sig
    type t

    val default : t
    val of_string_err : string -> (t, string) result
    val to_string : t -> string
    val compare : t -> t -> int

  end

(* Module Key container (Common to all displays) *)
module type Key_container_intf =
  sig
    type key

    module Set : sig
      include Avl.S
              with type elt = key

      val to_string : t -> string
    end

    module BidirDict : sig
      type t

      val empty : t
      val add : t -> string -> key -> t
      val key_of_action : t -> string -> key option
      val action_of_key : t -> key -> string option
    end
  end

(* Module Graph (Common to all displays) *)
module type Graph_intf =
  sig
    type key
    type keyset

    (* Vertex Label (attached to Graph.V.t) *)
    module Vlabel : sig
      type state = Step | Spell of string
      type t = {
          cost : keyset list
        ; state : state
        }

      val create_spell : keyset list -> string -> t
      val create_step : keyset list -> t
      val to_string : t -> string
    end

    (* Edge Label (attached to Graph.E.t) *)
    module Elabel : sig
      type t = keyset

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
    val key_of_action : t -> string -> key option
    val action_of_key : t -> key -> string option
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
