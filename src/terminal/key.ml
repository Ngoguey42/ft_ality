(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   key.ml                                             :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Ngo <ngoguey@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/03 16:34:22 by Ngo               #+#    #+#             *)
(*   Updated: 2016/06/03 18:31:45 by Ngo              ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type t = {
    id : int
  }

let of_string _ =
  Printf.eprintf "\t\tKey.of_string()\n%!";
  {id = 42}

let equal a b =
  a = b

(* TODO: use ncurse or sdl instead? *)
(* Bytes read in terminal are converted to t *)
let of_bytes _ =
  Printf.eprintf "\tKey.of_bytes()\n%!";
  {id = 42}
