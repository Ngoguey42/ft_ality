(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   p_graph_intf.ml                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/06 18:09:40 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/06 18:15:35 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type 'a abstract_vertex = {
    tag : int
  ; label : 'a
  }

module type AbstractVertex_intf =
  sig
    type label
    type t = label abstract_vertex
    val compare : t -> t -> int
    (* val hash : 'a abstract_vertex *)
    (* val equal : 'a abstract_vertex -> 'a abstract_vertex -> bool *)
    val label : t -> 'a
    val create : label -> t
  end

module type Make_AbstractVertex_intf =
  functor (V : Graph_intf.Any_type_intf) ->
  AbstractVertex_intf
  with type label = V.t
