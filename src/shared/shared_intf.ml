(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   shared_intf.ml                                     :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/02 11:34:11 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/02 12:29:40 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module type Vertex_intf =
  sig
    type t
  end

module type Key_intf =
  sig
    type t
      (* = { *)
      (*   name : string *)
      (* } *)
  end

module type Algo_intf =
  sig
    type t

    module Key : Key_intf
    module Vertex : Vertex_intf
    val create : in_channel -> t
    val on_key_pressed : Key.t -> t -> t
  end


(* module type Output_intf = *)
(*   sig *)
(*     type vert *)
(*     type edge *)
(*     val vertex : vert -> unit *)
(*   end *)

(* module type Input_intf = *)
(*   sig *)
(*     type key *)
(*     val *)
(*   end *)


module type Display_intf =
  sig
    (* module Output : Output_intf *)
    (* module Input : Input_intf *)
    type key
    type vertex

    val declare_key : key -> unit
    val declare_vertex : vertex -> unit
    val focus_vertex : vertex -> unit
  end

module type Make_display_intf =
  functor (Algo : Algo_intf) ->
  Display_intf with type key = Algo.Key.t
                and type vertex = Algo.Vertex.t

module type Make_algo_intf =
  functor (Display : Display_intf) ->
  Algo_intf
  (* with type Key.t = Display.key *)
  (*            and type Vertex.t = Display.vertex *)
