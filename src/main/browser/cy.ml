(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   cy.ml                                              :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/18 09:07:33 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/18 12:05:45 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make (Graph : Shared_intf.Graph_impl_intf)
       : (Browser_intf.Cy_intf
          with type vertex = Graph.V.t
          with type edge = Graph.E.t) =
  struct

    module Kwarg =
      struct

        class type c =
          object
            method container : Dom_html.element Js.t Js.readonly_prop
          end

        let create : Dom_html.element Js.t -> c Js.t = fun elt ->
          object%js (self)
            val container = elt
          end

      end

    (* module Kwarg_vertex = *)
    (*   struct *)



    (*     class type c = *)
    (*       object *)
    (*         method group : Js.js_string Js.t Js.readonly_prop *)
    (*         method data : Data.t Js.t Js.readonly_prop *)

    (*       end *)

    (*     let create : string -> c Js.t = fun elt -> *)
    (*       object%js (self) *)
    (*         val container = elt *)
    (*       end *)

    (*   end *)

    class type c =
      object
        method width : int Js.meth
        method add : Js.Unsafe.any Js.t -> unit Js.meth
      end

    type t = c Js.t
    type vertex = Graph.V.t
    type edge = Graph.E.t

    (* module StrSet = Avl.Make(struct *)
    (*                           type t = string *)
    (*                           let compare = compare *)
    (*                         end) *)

    (* let req_fields = ["width"] *)

    (* let validate_fields_err elt = *)
    (*   Js.object_keys elt *)
    (*   |> Js.to_array *)
    (*   |> Array.fold_left (fun acc k -> *)
    (*          if StrSet.mem k acc *)
    (*          then StrSet.remove k acc *)
    (*          else acc *)
    (*        ) (StrSet.of_list req_fields) *)
    (*   |> (fun set -> *)
    (*     if StrSet.is_empty set *)
    (*     then Ok elt *)
    (*     else Error "missing fields in elt") *)


    let log msg =
      ignore (Js.Unsafe.fun_call (Js.Unsafe.js_expr "console.log")
                                 [| Js.Unsafe.inject msg |])

    let of_dom_element_err elt =
      let c : (Kwarg.c Js.t -> c Js.t) Js.constr =
        Js.Unsafe.global##.cytoscape
      in
      let kwarg = Kwarg.create elt in
      match new%js c kwarg with
      | exception _ ->
         Error (Printf.sprintf "Could not construct `cytoscape` instance")
      | elt ->
         Ok elt

    let of_eltid_err eltid =
      match Dom_html.getElementById eltid with
      | exception _ ->
         Error (Printf.sprintf "Could not retreive `%s` in DOM" eltid)
      | elt -> of_dom_element_err elt

    let new_vertex v cy =
      let id = Graph.V.label v |> Graph.Vlabel.to_string ~color:false in
      Ftlog.lvl 2;
      Ftlog.outnl "Cy.new_vertex(%s)" id;
      let kwarg : Js.Unsafe.any Js.t =
        object%js (self)
          val group = Js.string "nodes"
          val data = object%js (self)
                       val id = Js.string id
                     end
        end
        |> Js.Unsafe.coerce
      in
      log kwarg;
      (* Printf.eprintf "%d\n%!" ; *)
      (* let cy' : c Js.t = cy in *)
      cy##add kwarg;
      cy

    let new_edge v cy =
      Ftlog.lvl 2;
      Ftlog.outnl "Cy.new_edge()";
      cy

  end
