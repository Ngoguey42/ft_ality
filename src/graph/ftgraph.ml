(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   graph.ml                                           :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/08 11:23:29 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/10 08:16:49 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let v_counter = ref 0

module Make_PersistentDigraphAbstractLabeled :
Ftgraph_intf.Make_PersistentDigraphAbstractLabeled_intf =
  functor (V : Ftgraph_intf.Any_type_intf) ->
  functor (E : Ftgraph_intf.Ordered_type_dft_intf) ->
  struct

    module V : (Ftgraph_intf.Vertex_intf
               with type label = V.t)=
      struct
        type label = V.t
        type t = {
            tag : int
          ; label : label
          }

        let compare {tag=a} {tag=b} =
          a - b

        let label {label} =
          label

        let create label =
          let tag = !v_counter in
          incr v_counter;
          {tag ; label}
      end
    type vertex = V.t

    module E : (Ftgraph_intf.Edge_intf
                with type vertex = V.t
                 and type label = E.t) =
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
          E.compare labela labelb
          |> (function | 0 -> V.compare srca srcb
                       | res -> res)
          |> (function | 0 -> V.compare dsta dstb
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

    module EdgeSet = Avl.Make(E)
    module VertexMap = Ftmap.Make(V)

    type t = {
        size : int
      ; vertices : EdgeSet.t VertexMap.t
      }

    let is_empty {size} =
      size = 0

    let nb_vertex {size} =
      size

    let mem_vertex {vertices} v =
      VertexMap.mem v vertices

    let iter_vertex f {vertices} =
      VertexMap.iter (fun v _ -> f v) vertices

    let fold_vertex f {vertices} =
      VertexMap.fold (fun v _ acc -> f v acc) vertices

    let iter_succ_e f {vertices} v =
      match VertexMap.find_opt v vertices with
      | None -> invalid_arg "[ftgraph] iter_succ_e"
      | Some eset -> EdgeSet.iter f eset

    let binary_find_succ_e f {vertices} v =
      VertexMap.find_opt v vertices
      |> (function
          | None ->
             None
          | Some eset ->
             EdgeSet.binary_find (fun e -> f (E.label e)) eset
         )

    let invariants g =
      (*
       * Check .size = cardinality map
       * Check vertices.{all vert} = vertices.{all vert}.{all edges}.src
       * Check vertices.*.dst mem vertices
      *)
      true

    let empty =
      {size = 0 ; vertices = VertexMap.empty}

    let add_vertex ({size ; vertices} as g) v =
      if mem_vertex g v
      then g
      else {size = size + 1 ; vertices = VertexMap.add v EdgeSet.empty vertices}

    let remove_vertex ({size ; vertices} as g) v =
      if not (mem_vertex g v)
      then g
      else {size = size - 1 ; vertices = VertexMap.remove v vertices}

    let add_edge_e g e =
      let src = E.src e in
      let dst = E.dst e in
      let g = add_vertex g src in
      let ({vertices} as g) = add_vertex g dst in
      let src_outedges = VertexMap.find_exn src vertices in
      let src_outedges = EdgeSet.add e src_outedges in
      let vertices = VertexMap.add src src_outedges vertices in
      {g with vertices}

    let remove_edge ({vertices} as g) src dst =
      match VertexMap.find_opt src vertices with
      | None -> g
      | Some src_outedges ->
         let is_dst e = V.compare (E.dst e) dst = 0 in
         let src_outedges = EdgeSet.filter is_dst src_outedges in
         let vertices = VertexMap.add src src_outedges vertices in
         {g with vertices}

    let remove_edge_e ({vertices} as g) e =
      let src = E.src e in
      match VertexMap.find_opt src vertices with
      | None -> g
      | Some src_outedges ->
         let src_outedges = EdgeSet.remove e src_outedges in
         let vertices = VertexMap.add src src_outedges vertices in
         {g with vertices}

  end
