(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   ftlog.ml                                           :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/16 08:29:28 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/19 11:18:14 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let lvl_ref = ref 0
let status_ref = ref true

(* TODO: custom outchannel *)

let enable () =
  status_ref := true

let disable () =
  status_ref := false

let lvl v =
  if v >= 0
  then lvl_ref := v

(* print with indentation + flush *)
let out : ('a, 'b, 'c) format -> 'a = fun fmt ->
  if !status_ref then
    Printf.printf ("%s" ^^ fmt ^^ "%!") (String.make !lvl_ref ' ')
  else
    Printf.ifprintf stdout fmt

(* print with flush *)
let out_raw : ('a, 'b, 'c) format -> 'a = fun fmt ->
  if !status_ref then
    Printf.printf (fmt ^^ "%!")
  else
    Printf.ifprintf stdout fmt

(* print with indentation + end line + flush *)
let outnl : ('a, out_channel, unit) format -> 'a = fun fmt ->
  if !status_ref then
    Printf.printf ("%s" ^^ fmt ^^ "\n%!") (String.make !lvl_ref ' ')
  else
    Printf.ifprintf stdout fmt

(* print with given indentation + end line + flush *)
let outnllvl : int -> ('a, out_channel, unit) format -> 'a = fun lvl fmt ->
  if !status_ref then
    Printf.printf ("%s" ^^ fmt ^^ "\n%!") (String.make lvl ' ')
  else
    Printf.ifprintf stdout fmt
