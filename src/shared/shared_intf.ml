(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   shared_intf.ml                                     :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/02 11:34:11 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/03 18:21:19 by Ngo              ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module type Algo_intf =
  sig
    type t
    type key

    val create : in_channel -> t
    val on_key_press : key -> t -> t
  end

module type Display_intf =
  sig
    type key

    val declare_key : key -> unit
    val declare_vertex : Vertex.t -> unit
    val focus_vertex : Vertex.t -> unit
    val run : unit -> unit
  end

module type Key_intf =
  sig
    type t

    val of_string : string -> t
    val equal : t -> t -> bool
  end
(*
module type Make_display_intf =
  functor (Algo : Algo_intf) ->
  Display_intf

module type Make_algo_intf =
  functor (Key : Key_intf) ->
  functor (Display : Display_intf
           with type key = Key.t) ->
  Algo_intf
 *)
