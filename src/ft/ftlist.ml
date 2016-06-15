(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   ftlist.ml                                          :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/14 11:34:51 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/15 07:54:04 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* signature from core's Core_list *)
let reduce : 'a list -> f:('a -> 'a -> 'a) -> 'a option = fun l ~f ->
  match l with
  | [] -> None
  | hd::tl -> Some (List.fold_left f hd tl)

(* signature from core's Core_list *)
let reduce_exn : 'a list -> f:('a -> 'a -> 'a) -> 'a = fun l ~f ->
  match l with
  | [] -> Invalid_argument "[Ftlist.reduce_exn] empty list" |> raise
  | hd::tl -> List.fold_left f hd tl

(* signature from core's Core_list *)
let find_map : 'a list -> f:('a -> 'b option) -> 'b option = fun l ~f ->
  let rec aux = function
    | [] -> None
    | hd::tl -> Ftopt.value_opt_thunk (f hd) ~f:(fun () -> aux tl)
  in
  aux l

(* signature from core's Core_list *)
let find_mapi : 'a list -> f:(int -> 'a -> 'b option) -> 'b option = fun l ~f ->
  let rec aux i = function
    | [] -> None
    | hd::tl -> Ftopt.value_opt_thunk (f i hd) ~f:(fun () -> aux (i + 1) tl)
  in
  aux 0 l

(* extension of find_map for 2 lists, Raise Invalid_argument if the two lists
 * are determined to have different lengt *)
let find_map2 : 'a list -> 'b list -> f:('a -> 'b -> 'c option)
                -> 'c option = fun l l' ~f ->
  let rec aux l l' = (* shadowing l, l' *)
    match l, l' with
    | [], [] ->
       None
    | [], _ | _, [] ->
       Invalid_argument "[Ftlist.find_map2] different length" |> raise
    | hd::tl, hd'::tl' ->
       Ftopt.value_opt_thunk (f hd hd') ~f:(fun () -> aux tl tl')
  in
  aux l l'

(* extension of find_mapi for 2 lists, Raise Invalid_argument if the two lists
 * are determined to have different lengt *)
let find_map2i : 'a list -> 'b list -> f:(int -> 'a -> 'b -> 'c option)
                 -> 'c option = fun l l' ~f ->
  let rec aux i l l' = (* shadowing l, l' *)
    match l, l' with
    | [], [] ->
       None
    | [], _ | _, [] ->
       Invalid_argument "[Ftlist.find_map2i] different length" |> raise
    | hd::tl, hd'::tl' ->
       Ftopt.value_opt_thunk (f i hd hd') ~f:(fun () -> aux (i + 1) tl tl')
  in
  aux 0 l l'

(* signature from core's Core_list *)
let filteri : 'a t -> f:(int -> 'a -> bool) -> 'a t = fun l ~f ->
  let rec aux acc i = function
    | [] -> acc
    | hd::tl -> aux ((f i hd)::acc) (i + 1) tl
  in
  aux [] 0 l
  |> List.rev
