(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   jsobj.mli                                          :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/21 13:37:48 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/21 14:01:29 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

class type cynode =
  object
    method addClass : Js.js_string Js.t -> unit Js.t Js.meth
    method removeClass : Js.js_string Js.t -> unit Js.t Js.meth

    (* `id()` declared as `Js.Optdef.t` to detect
     * `cy##getElementById()` return value correctness *)
    method id : int Js.Optdef.t Js.meth
  end

class type cy =
  object
    method width : int Js.meth
    method destroy : unit Js.meth
    method container : Dom_html.element Js.t Js.meth

    (* Always return an object, use `Node##id` to check correctness *)
    method getElementById : int -> cynode Js.t Js.meth
  end

class type cyglobal =
  object
    method stylesheet : < .. > Js.t Js.meth
  end
