(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   key.ml                                             :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Ngo <ngoguey@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/03 16:34:22 by Ngo               #+#    #+#             *)
(*   Updated: 2016/06/19 15:09:12 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type t = Identifier of string | Code of int

(* Internal *)

let code_of_string_err = function
  | "left" -> Ok (Identifier "Left")
  | "right" -> Ok (Identifier "Right")
  | "down" -> Ok (Identifier "Down")
  | "up" -> Ok (Identifier "Up")
  | s when String.length s = 1 -> Ok (Code (String.get s 0
                                            |> Char.uppercase_ascii
                                            |> int_of_char))
  | s -> Error (Printf.sprintf "Unknown key \"%s\"" s)

(* Exposed *)

let default = Code 0

let of_string_err str =
  Ftlog.lvl 8;
  Ftlog.outnl "Key.of_string((\"%s\"))" str;
  code_of_string_err str

let to_string = function
  | Identifier s -> s
  | Code c -> char_of_int c |> String.make 1

let compare a b =
  Pervasives.compare a b

let of_dom_event de =
  match de##.keyIdentifier |> Js.Optdef.to_option with
  | None -> Code de##.keyCode
  | Some jki ->  let ki = Js.to_string jki in
                 if String.length ki < 4
                 then Identifier ki
                 else match String.sub ki 0 2 with
                      | "U+" -> Code de##.keyCode
                      | _ -> Identifier ki
