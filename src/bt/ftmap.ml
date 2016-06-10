(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   ftmap.ml                                           :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/08 11:58:46 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/10 08:05:14 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module type OrderedType =
  sig
    type t
    val compare : t -> t -> int
  end

module type S =
  sig
    (* Interfaces from std Map, same ordering, same prototypes *)

    type key
    type +'a t
    val empty : 'a t
    val is_empty : 'a t -> bool
    val mem : key -> 'a t -> bool
    val add : key -> 'a -> 'a t -> 'a t
    (* val singleton : key -> 'a -> 'a t *)
    val remove : key -> 'a t -> 'a t
    (* val merge : (key -> 'a option -> 'b option -> 'c option) -> *)
    (*             'a t -> 'b t -> 'c t *)
    (* val union : (key -> 'a -> 'a -> 'a option) -> *)
    (*             'a t -> 'a t -> 'a t *)
    (* val compare : ('a -> 'a -> int) -> 'a t -> 'a t -> int *)
    (* val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool *)
    val iter : (key -> 'a -> unit) -> 'a t -> unit
    val fold : (key -> 'a -> 'b -> 'b) -> 'a t -> 'b -> 'b
    (* val for_all : (key -> 'a -> bool) -> 'a t -> bool *)
    (* val exists : (key -> 'a -> bool) -> 'a t -> bool *)
    (* val filter : (key -> 'a -> bool) -> 'a t -> 'a t *)
    (* val partition : (key -> 'a -> bool) -> 'a t -> 'a t * 'a t *)
    val cardinal : 'a t -> int
    (* val bindings : 'a t -> (key * 'a) list *)
    (* val min_binding : 'a t -> key * 'a *)
    (* val max_binding : 'a t -> key * 'a *)
    (* val choose : 'a t -> key * 'a *)
    (* val split : key -> 'a t -> 'a t * 'a option * 'a t *)
    (* val find : key -> 'a t -> 'a *)
    (* val map : ('a -> 'b) -> 'a t -> 'b t *)
    (* val mapi : (key -> 'a -> 'b) -> 'a t -> 'b t *)

    (* Not present in std *)
    (* val find : (key -> bool) -> 'a t -> 'a option *)
    val find_opt : key -> 'a t -> 'a option
    val find_exn : key -> 'a t -> 'a
    val binary_find : (key -> int) -> 'a t -> (key * 'a) option
    val check : 'a t -> bool
  end

(*s Sets implemented as reb-black trees. *)

module type Make_intf =
  functor (Ord : OrderedType) ->
  (S with type key = Ord.t)

module Make : Make_intf =
  functor(Ord : OrderedType) ->
  struct

    type key = Ord.t
    type 'a t = Empty | Node of 'a t * (key * 'a) * 'a t

    let empty = Empty

    let height t =
      let rec aux t acc =
	      match t with
	      | Empty -> acc
	      | Node (a, _, b) -> max (aux a (acc + 1)) (aux b (acc + 1))
      in
      aux t 0

    let is_bst t =
      let rec aux = function
	      | Empty ->
           true
	      | Node(_, (k, _), Node(_, (k', _), _)) when Ord.compare k k' > 0 ->
           false
	      | Node(Node(_, (k', _), _), (k, _), _) when Ord.compare k k' < 0 ->
           false
	      | Node(a, _, b) ->
           (aux a) && (aux b)
      in
      aux t

    (* is_perfect = is_balance with (delta = 0) *)
    let is_perfect t =
      let rec aux = function
	      | Empty -> true
	      | Node(a, _, b) when height a = height b -> (aux a) && (aux b)
	      | _ -> false
      in
      aux t

    let is_balanced t =
      let rec aux = function
	      | Empty -> true
	      | Node(a, _, b)
		         when abs ((height a) - (height b)) > 1	-> false
	      | Node(a, _, b) -> (aux a) && (aux b)
      in
      aux t

    let check t =
      (is_balanced t) && (is_bst t)

    let mem k t =
      let rec aux = function
	      | Empty -> false
	      | Node(_, (k', _), _) when Ord.compare k k' = 0 -> true
	      | Node(a, (k', _), _) when Ord.compare k k' < 0 -> aux a
	      | Node(_, _, b) -> aux b
      in
      aux t

    let is_empty = function Empty -> true | _ -> false

    (* Indentation used to emphasize the ordering of variables in repacking *)
    let balance l ((k, v) as kv) r =
      let diff = (height l) - (height r) in
      let h = height in
      if diff > 1 then
	      match l with
	      | Node(l', kv', r') when h l' - h r' >= 0
	        -> Node(l', kv', Node(r', kv, r))
	      | Node(l', kv', Node(l'', kv'', r''))
	        -> Node(Node(l', kv', l''), kv'', Node(r'', kv, r))
	      | _
	        -> failwith "Balancing failed"
      else if diff < (-1) then
	      match r with
	      | Node(l', kv', r') when h l' - h r' <= 0
	        -> Node(Node(l, kv, l'), kv', r')
	      | Node(Node(l'', kv'', r''), kv', r')
	        -> Node(Node(l, kv, l''), kv'', Node(r'', kv', r'))
	      | _
	        -> failwith "Balancing failed"
      else
	      Node(l, kv, r)

    (* If already present, erase previous binding *)
    let add k v t =
      let rec aux = function
	      | Node(a, (k', _), b) when Ord.compare k k' = 0 ->
           Node(a, (k, v), b)
	      | Node(a, ((k', _) as kv'), b) when Ord.compare k k' < 0 ->
           balance (aux a) kv' b
	      | Node(a, kv', b) ->
           balance a kv' (aux b)
	      | _ ->
           Node(Empty, (k, v), Empty)
      in
      aux t

    (* TODO: test and fail silently if v missing in t *)
    let remove k t =
      let rec min = function
	      | Node(Empty, kv', _) -> kv'
	      | Node(a, _, _) -> min a
	      | _ -> failwith "unreachable"
      and merge a b =
	      match a, b with
	      | Empty, x | x, Empty -> x
	      | _ -> let (kb, _) as minb = min b in
							 balance a minb (aux b kb)
      and aux t k =
	      match t with
	      | Node(Empty, (k', _), Empty) when Ord.compare k k' = 0 ->
           Empty
	      | Node(a, (k', _), b) when Ord.compare k k' = 0 ->
           merge a b
	      | Node(a, ((k', _) as kv'), b) when Ord.compare k k' < 0 ->
           balance (aux a k) kv' b
	      | Node(a, kv', b) ->
           balance a kv' (aux b k)
	      | _ ->
           failwith "doesn't exists"
      in
      aux t k

    let fold f t init =
      let rec aux acc = function
        | Empty -> acc
        | Node(lhs, (k, v), rhs) -> aux (f k v (aux acc lhs)) rhs
      in
      aux init t

    let iter f t =
      let rec aux = function
        | Empty -> ()
        | Node(lhs, (k, v), rhs) -> aux lhs; f k v; aux rhs
      in
      aux t

    (* val binary_find : (key -> int) -> t -> (key * 'a) option *)
    let binary_find f t =
      let rec aux = function
	      | Node(lhs, (k, v), rhs) ->
           let direction = f k in (* TODO: check compare parameters *)
           if direction = 0
           then Some (k, v)
           else if direction < 0
           then aux lhs
           else aux rhs
	      | Empty ->
           None
      in
      aux t

    let find_opt k t =
      let rec aux = function
	      | Node(lhs, (k', v'), rhs) ->
           let direction = Ord.compare k k' in (* TODO: check compare parameters *)
           if direction = 0
           then Some v'
           else if direction < 0
           then aux lhs
           else aux rhs
	      | Empty ->
           None
      in
      aux t

    let find_exn k t =
      let rec aux = function
	      | Node(lhs, (k', v'), rhs) ->
           let direction = Ord.compare k k' in (* TODO: check compare parameters *)
           if direction = 0
           then v'
           else if direction < 0
           then aux lhs
           else aux rhs
	      | Empty ->
           raise Not_found
      in
      aux t


    (* O(n) *)
    let cardinal t =
      let rec aux = function
	      | Node(lhs, _, rhs) ->
           aux lhs + 1 + aux rhs
	      | Empty ->
           0
      in
      aux t

  end
