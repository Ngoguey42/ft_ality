(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   shared_intf.mli                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/02 11:34:11 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/21 15:36:29 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* Modules hierarchy:
 * - Key, GameKey
 * - KeyPair
 * - Graph_inst
 * - Algo
 * - Display
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
    type t
    type key
    module GK : GameKey_intf

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
      val keypair_of_gamekey : t -> GK.t -> elt option
      val keypair_of_key : t -> key -> elt option
    end
  end

(* Module Graph (Common to all displays) *)
module type Graph_inst_intf =
  sig
    module KP : KeyPair_intf

    (* Vertex Label (attached to Graph.V.t) *)
    module Vlabel : sig
      type state = Step | Spell of string
      type t = {
          cost : KP.Set.t list
        ; state : state
        }

      val create_spell : KP.Set.t list -> string -> t
      val create_step : KP.Set.t list -> t
      val to_string : ?color:bool -> t -> string
      val get_cost : t -> KP.Set.t list
      val is_spell : t -> bool
    end

    (* Edge Label (attached to Graph.E.t) *)
    module Elabel : sig
      type t = KP.Set.t

      val compare : t -> t -> int
      val default : t
      val to_string : ?color:bool -> t -> string
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
    module KP : KeyPair_intf
    module G : Graph_inst_intf

    val create_err : in_channel -> (t, string) result
    val on_key_press_err : t -> KP.Set.t -> (t * G.V.t option, string) result
    val keypair_of_key : t -> key -> KP.t option

    val origin_vertex : t -> G.V.t
    val fold_keypair : (KP.t -> 'a -> 'a) -> t -> 'a -> 'a
    val fold_vertex : (G.V.t -> 'a -> 'a) -> t -> 'a -> 'a
    val fold_edge : (G.E.t -> 'a -> 'a) -> t -> 'a -> 'a
    val focus : t -> G.V.t
  end

(* Module Display (Specific to display) *)
module type Display_intf =
  sig
    val run_err : unit -> (unit, string) result
  end
