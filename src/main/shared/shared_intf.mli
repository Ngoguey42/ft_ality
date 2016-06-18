(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   shared_intf.mli                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/02 11:34:11 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/18 13:45:47 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* Most modules define types, a module may use a type from an other module in
 *  its signature if it is defined below in the hierarchy.
 * Modules hierarchy:
 * - Key, GameKey
 * - GameKey_container
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

(* Module GameKey (Common to all displays) *)
module type GameKey_intf =
  sig
    type t

    val default : t
    val of_string_err : string -> (t, string) result
    val to_string : t -> string
    val compare : t -> t -> int
  end

(* Module GameKey container (Common to all displays) *)
module type KeyPair_intf =
  sig
    type key
    type gamekey
    type t

    val default : t
    val of_strings_err : string -> string -> (t, string) result
    val of_key : key -> t
    val to_string : t -> string
    val compare : t -> t -> int

    module Set : sig
      include Avl.S
              with type elt = t

      val to_string : ?color:bool -> t -> string
    end

    module BidirDict : sig
      type elt = t
      type t

      val empty : t
      val add_err : t -> elt -> (t, string) result
      val keypair_of_gamekey : t -> gamekey -> elt option
      val keypair_of_key : t -> key -> elt option
    end
  end

(* Module Graph (Common to all displays) *)
module type Graph_impl_intf =
  sig
    type kpset

    (* Vertex Label (attached to Graph.V.t) *)
    module Vlabel : sig
      type state = Step | Spell of string
      type t = {
          cost : kpset list
        ; state : state
        }

      val create_spell : kpset list -> string -> t
      val create_step : kpset list -> t
      val to_string : ?color:bool -> t -> string
      val get_cost : t -> kpset list
    end

    (* Edge Label (attached to Graph.E.t) *)
    module Elabel : sig
      type t = kpset

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
    type keypair
    type kpset
    type vertex
    type edge

    val create_err : in_channel -> (t, string) result
    val on_key_press_err : t -> kpset -> (t, string) result
    val keypair_of_key : t -> key -> keypair option

    val origin_vertex : t -> vertex
    val fold_keypair : (keypair -> 'a -> 'a) -> t -> 'a -> 'a
    val fold_vertex : (vertex -> 'a -> 'a) -> t -> 'a -> 'a
    val fold_edge : (edge -> 'a -> 'a) -> t -> 'a -> 'a
  end

(* Module Display (Specific to display) *)
module type Display_intf =
  sig
    (* type keypair *)
    (* type vertex *)
    (* type edge *)

    (* val declare_keypair : keypair -> unit *)
    (* val declare_vertex : vertex -> unit *)
    (* val declare_edge : edge -> unit *)
    (* val focus_vertex_err : vertex -> (unit, string) result *)
    val run_err : unit -> (unit, string) result
  end
