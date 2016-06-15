(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   gamekey.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/15 10:23:15 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/15 13:29:22 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

type t = string

let default =
  "default"

let of_string_err str =
  Ok str

let to_string str =
  str

let compare = Pervasives.compare
