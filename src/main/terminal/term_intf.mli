(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   term_intf.mli                                      :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/10 08:39:51 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/13 07:20:09 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module type Key_intf =
  sig
    include Shared_intf.Key_intf

    val of_curses_code : int -> t
  end

module type Make_display_intf =
  functor (Key : Key_intf) ->
  functor (Graph : Shared_intf.Graph_intf
           with type key = Key.t) ->
  functor (Algo : Shared_intf.Algo_intf
           with type key = Key.t) ->
  (Shared_intf.Display_intf
   with type key = Key.t
   with type vertex = Graph.V.t
   with type edge = Graph.E.t)
