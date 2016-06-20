(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   fterr.ml                                           :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/20 07:39:07 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/20 07:44:14 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let try_2expr p1 p2 =
  match p1 with
  | Error msg -> Error msg
  | Ok v1 -> p2 v1

let try_3expr p1 p2 p3 =
  match p1 with
  | Error msg -> Error msg
  | Ok v1 ->
     match p2 v1 with
     | Error msg -> Error msg
     | Ok v2 -> p3 v1 v2

let try_4expr p1 p2 p3 p4 =
  match p1 with
  | Error msg -> Error msg
  | Ok v1 ->
     match p2 v1 with
     | Error msg -> Error msg
     | Ok v2 ->
        match p3 v1 v2 with
        | Error msg -> Error msg
        | Ok v3 -> p4 v1 v2 v3
