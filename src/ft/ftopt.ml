(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   ftopt.ml                                           :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/14 11:54:19 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/14 12:33:09 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* signature from core's Core_list *)
let value : 'a option -> default:'a -> 'a = fun opt ~default ->
  match opt with
  | None -> default
  | Some v -> v

(* same as `value` but get default from a call to f *)
let value_thunk : 'a option -> f:(unit -> 'a) -> 'a = fun opt ~f ->
  match opt with
  | None -> f ()
  | Some v -> v

(* same as `value` but returns an option *)
let value_opt : 'a option -> default:'a option
                -> 'a option = fun opt ~default ->
  match opt with
  | None -> default
  | v -> v

(* same as `value_thunk` but returns an option *)
let value_opt_thunk : 'a option -> f:(unit -> 'a option)
                      -> 'a option = fun opt ~f ->
  match opt with
  | None -> f ()
  | v -> v
