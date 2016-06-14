(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   key.ml                                             :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Ngo <ngoguey@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/03 16:34:22 by Ngo               #+#    #+#             *)
(*   Updated: 2016/06/14 16:05:59 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type t = Escape of char list | Char of char

(* Internal *)

let code_of_string_err = function
  | "left" -> Ok (Escape ['['; 'D'])
  | "right" -> Ok (Escape ['['; 'C'])
  | "down" -> Ok (Escape ['['; 'B'])
  | "up" -> Ok (Escape ['['; 'A'])
  | s when String.length s = 1 -> Ok (Char (String.get s 0))
  | s -> Error (Printf.sprintf "Unknown key \"%s\"" s)

let string_of_char c =
  Printf.sprintf "'%s'" (Char.escaped c)


(* Exposed *)

let default = Char 'c'

let of_string_err str =
  Printf.eprintf "\t\tKey.of_string((\"%s\"))\n%!" str;
  code_of_string_err str

let to_string = function
  | Char c ->
     string_of_char c
  | Escape l ->
     ListLabels.fold_right
       ~f:(fun c acc -> string_of_char c::acc) l ~init:[]
     |> String.concat "; "
     |> Printf.sprintf "[\\e; %s]"

let compare a b =
  match a, b with
  | Escape _, Char _ -> -1
  | Char _, Escape _ -> 1
  | Char c, Char c' -> compare c c'
  | Escape l, Escape l' -> compare l l'

let of_char c =
  Char c

let of_sequence l =
  assert (List.length l > 0);
  Escape l
