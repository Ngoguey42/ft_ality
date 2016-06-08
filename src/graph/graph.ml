(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   graph.ml                                           :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/08 11:23:29 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/08 12:55:40 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let v_counter = ref 0

(* type 'a abstract_vertex = { *)
(*     tag : int *)
(*   ; label : 'a *)
(*   } *)

(* module type AbstractVertex_intf = *)
(*   sig *)
(*     type label *)
(*     type t = label abstract_vertex *)
(*     val compare : t -> t -> int *)
(*     (\* val hash : 'a abstract_vertex *\) *)
(*     (\* val equal : 'a abstract_vertex -> 'a abstract_vertex -> bool *\) *)
(*     val label : t -> 'a *)
(*     val create : label -> t *)
(*   end *)

(* module type Make_AbstractVertex_intf = *)
(*   functor (V : Graph_intf.Any_type_intf) -> *)
(*   AbstractVertex_intf *)
(*   with type label = V.t *)

module Make_PercistentDigraphAbstractLabeled :
Graph_intf.Make_PercistentDigraphAbstractLabeled_intf =
  functor (V : Graph_intf.Any_type_intf) ->
  functor (E : Graph_intf.Ordered_type_dft_intf) ->
  struct

    module V : Graph_intf.Vertex_intf =
      struct
        type label = V.t
        type t = {
            tag : int
          ; label : label
          }

        let compare {tag=a} {tag=b} =
          b - a

        let label {label} =
          label

        let create label =
          let tag = !v_counter in
          incr v_counter;
          {tag ; label}
      end
    type vertex = V.t

    module E : Graph_intf.Edge_intf =
      struct
        type label = E.t
        type vertex = V.t
        type t = {
            src : vertex
          ; dst : vertex
          ; label : label
          }

        let compare {src=srca ; dst=dsta ; label=labela}
                    {src=srcb ; dst=dstb ; label=labelb} =
          V.compare srca srcb
          |> (function | 0 -> V.compare dsta dstb
                       | res -> res)
          |> (function | 0 -> E.compare labela labelb
                       | res -> res)

        let dst {dst} =
          dst

        let src {src} =
          src

        let create src label dst =
          {src ; label ; dst}

        let label {label} =
          label
      end
    type edge = E.t

    module VertexSet = Avl.Make(V)
    module VertexMap = Ftmap.Make(V)

    type t = {
        size : int
      ; vertices : VertexSet.t VertexMap.t
      }

  end
