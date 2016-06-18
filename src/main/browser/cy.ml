(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   cy.ml                                              :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/18 09:07:33 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/18 10:20:57 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

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

class type c =
  object
    method width : int Js.meth
  end

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


let of_dom_element_err : Dom_html.element Js.t
                         -> (c Js.t, string) result = fun elt ->
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
