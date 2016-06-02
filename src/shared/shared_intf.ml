(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   shared_intf.ml                                     :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/02 11:34:11 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/02 14:21:40 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module type Algo_intf =
  sig
    type t

    val create : in_channel -> t
    val on_key_press : Key.t -> t -> t
  end

module type Display_intf =
  sig
    val declare_key : Key.t -> unit
    val declare_vertex : Vertex.t -> unit
    val focus_vertex : Vertex.t -> unit
    val run : unit -> unit
  end

module type Make_display_intf =
  functor (Algo : Algo_intf) ->
  Display_intf

module type Make_algo_intf =
  functor (Display : Display_intf) ->
  Algo_intf
