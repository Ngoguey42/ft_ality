(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   shared_intf.ml                                     :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/02 11:34:11 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/10 13:47:03 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module type Graph_intf =
  sig
    module Vlabel : sig
      type combo = {
          name : string
        }
      type t = Step | Combo of combo
    end

    module Elabel : sig
      type key

      module KeySet : Avl.S
             with type elt = key

      type t = KeySet.t
    end
    include Ftgraph_intf.PersistentDigraphAbstractLabeled_intf
            with type V.label = Vlabel.t
            with type E.label = Elabel.t
  end

module type Algo_intf =
  sig
    type t
    type key

    val create : in_channel -> t * key list
    val on_key_press : key -> t -> t
  end

module type Display_intf =
  sig
    type key
    type vertex

    val declare_key : key -> unit
    val declare_vertex : vertex -> unit
    val focus_vertex : vertex -> unit
    val run : unit -> unit
  end

module type Key_intf =
  sig
    type t

    val default : t
    val of_strings : string * string -> t
    (* val equal : t -> t -> bool *)
    val compare : t -> t -> int
  end

module type Make_algo_intf =
  functor (Key : Key_intf) ->
  functor (Graph : Graph_intf
           with type Elabel.key = Key.t) ->
  functor (Display : Display_intf
           with type key = Key.t
           with type vertex = Graph.V.t) ->
  Algo_intf
  with type key = Key.t

module type Make_graph_intf =
  functor (Key : Key_intf) ->
  Graph_intf
  with type Elabel.key = Key.t
