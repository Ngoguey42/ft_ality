(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   key.ml                                             :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Ngo <ngoguey@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/03 16:34:22 by Ngo               #+#    #+#             *)
(*   Updated: 2016/06/13 09:02:15 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type t = {
    code : int
  }


(* Internal *)

let ok p =
  Shared_intf.Ok p

let error p =
  Shared_intf.Error p

let code_of_string_err = function
  | "left" -> ok Curses.Key.left
  | "right" -> ok Curses.Key.right
  | "down" -> ok Curses.Key.down
  | "up" -> ok Curses.Key.up
  | s when String.length s = 1 -> String.get s 0 |> int_of_char |> ok
  | s -> Printf.sprintf "Unknown key \"%s\"" s |> error

(* Exposed *)

let default = {code = -1}

let of_string_err key =
  Printf.eprintf "\t\tKey.of_string((\"%s\"))\n%!" key;
  match code_of_string_err key with
  | Shared_intf.Ok code -> ok {code}
  | Shared_intf.Error msg -> error msg

let to_string {code} =
  string_of_int code

let compare a b =
  a.code - b.code

let of_curses_code kcode =
  Printf.eprintf "\tKey.of_curses_code(%d)\n%!" kcode;
  {code = kcode}
