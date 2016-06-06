(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   avl.ml                                             :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/06 14:59:46 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/06 15:55:28 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(*
 * AVL implementation from `piscine_ocaml` `j03_Development_Environment` `ex04`
 * Was too lazy to improve implementation and store height in Nodes
 *)

module type OrderedType =
  sig
    type t
    val compare : t -> t -> int
  end

module type S =
  sig
    type elt
    type t
    val empty : t
    val is_empty : t -> bool
    val mem : elt -> t -> bool
    val add : elt -> t -> t
    (* val singleton : elt -> t *)
    val remove : elt -> t -> t
    (* merge (Map only) *)
    (* val union : t -> t -> t *)
    (* val inter : t -> t -> t (Set only) *)
    (* val diff : t -> t -> t (Set only) *)
    (* val compare : t -> t -> int *)
    (* val equal : t -> t -> bool *)
    (* val subset : t -> t -> bool (Set only) *)
    val iter : (elt -> unit) -> t -> unit
    val fold : (elt -> 'a -> 'a) -> t -> 'a -> 'a
    (* val for_all: (elt -> bool) -> t -> bool *)
    (* val exists: (elt -> bool) -> t -> bool *)
    (* val filter: (elt -> bool) -> t -> t *)
    (* val partition: (elt -> bool) -> t -> t * t *)
    (* val cardinal : t -> int *)
    (* bindings (Map only) *)
    (* max_binding (Map only) *)
    (* min_binding (Map only) *)
    (* val elements : t -> elt list (Set only) *)
    (* val min_elt : t -> elt (Set only) *)
    (* val max_elt : t -> elt (Set only) *)
    (* val choose : t -> elt *)
    (* val split : elt -> t -> t * bool * t *)
    (* find (Both) *)
    (* of_list (Set only) *)
    (* map, mapi (Map only) *)
    val check : t -> bool
  end

(*s Sets implemented as reb-black trees. *)

module type Make_intf =
  functor (Ord : OrderedType) ->
  (S with type elt = Ord.t)

module Make : Make_intf =
  functor(Ord : OrderedType) ->
  struct

    type elt = Ord.t
    type t = Empty | Node of t * elt * t

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
	      | Empty -> true
	      | Node(_, v, Node(_, v', _)) when v' < v -> false
	      | Node(Node(_, v', _), v, _) when v' > v -> false
	      | Node(a, _, b) -> (aux a) && (aux b)
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

    let mem v t =
      let rec aux = function
	      | Empty -> false
	      | Node(_, v', _) when v = v' -> true
	      | Node(a, v', _) when v < v' -> aux a
	      | Node(_, _, b) -> aux b
      in
      aux t

    let is_empty = function Empty -> true | _ -> false

    (* Indentation used to emphasize the ordering of variables in repacking *)
    let balance l v r =
      let diff = (height l) - (height r) in
      let h = height in
      if diff > 1 then
	      match l with
	      | Node(        l', v',             r') when h l' - h r' >= 0
	        -> Node(     l', v', Node(       r',             v, r))
	      | Node(        l', v', Node(l'',   v'',      r''))
	        -> Node(Node(l', v',      l''),  v'', Node(r'',  v, r))
	      | _
	        -> failwith "Balancing failed"
      else if diff < (-1) then
	      match r with
	      | Node(                    l',             v', r') when h l' - h r' <= 0
	        -> Node(Node(l, v,       l'),            v', r')
	      | Node(Node(         l'',  v'',      r''), v', r')
	        -> Node(Node(l, v, l''), v'', Node(r'',  v', r'))
	      | _
	        -> failwith "Balancing failed"
      else
	      Node(l, v, r)

    (* If already present, erase previous binding *)
    let add v t =
      let rec aux = function
	      | Node(a, v', b) when v = v' -> Node(a, v, b)
	      | Node(a, v', b) when v < v' -> balance (aux a) v' b
	      | Node(a, v', b) -> balance a v' (aux b)
	      | _ -> Node(Empty, v, Empty)
      in
      aux t

    (* TODO: test and fail silently if not present *)
    let remove v t =
      let rec min = function
	      | Node(Empty, v', _) -> v'
	      | Node(a, _, _) -> min a
	      | _ -> failwith "unreachable"
      and merge a b =
	      match a, b with
	      | Empty, x | x, Empty -> x
	      | _ -> let minb = min b in
							 balance a minb (aux b minb)
      and aux t v =
	      match t with
	      | Node(Empty, v', Empty) when v = v' -> Empty
	      | Node(a, v', b) when v = v' -> merge a b
	      | Node(a, v', b) when v < v' -> balance (aux a v) v' b
	      | Node(a, v', b) -> balance a v' (aux b v)
	      | _ -> failwith "doesn't exists"
      in
      aux t v

    let fold f t init =
      let rec aux acc = function
        | Empty -> acc
        | Node(lhs, v, rhs) -> aux (f v (aux acc lhs)) rhs
      in
      aux init t

    let iter f t =
      let rec aux = function
        | Empty -> ()
        | Node(lhs, v, rhs) -> aux lhs; f v; aux rhs
      in
      aux t



  end
