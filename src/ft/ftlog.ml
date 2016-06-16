(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   ftlog.ml                                           :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/16 08:29:28 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/16 08:40:58 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let lvl_ref = ref 0

let lvl v =
  if v >= 0
  then lvl_ref := v

let out : ('a, out_channel, unit) format -> 'a = fun fmt ->
  Printf.printf ("%s" ^^ fmt ^^ "%!") (String.make !lvl_ref ' ')

let outnl : ('a, out_channel, unit) format -> 'a = fun fmt ->
  Printf.printf ("%s" ^^ fmt ^^ "\n%!") (String.make !lvl_ref ' ')
