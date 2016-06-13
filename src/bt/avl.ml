(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   avl.ml                                             :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/06 14:59:46 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/13 13:32:34 by ngoguey          ###   ########.fr       *)
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
    (* Interface from std and Set, same ordering, same prototypes *)

    type elt
    type t
    val empty : t
    val is_empty : t -> bool
    val mem : elt -> t -> bool
    val add : elt -> t -> t
    (* val singleton : elt -> t *)
    val remove : elt -> t -> t
    (* val union : t -> t -> t *)
    (* val inter : t -> t -> t *)
    (* val diff : t -> t -> t *)
    val compare : t -> t -> int
    (* val equal : t -> t -> bool *)
    (* val subset : t -> t -> bool *)
    val iter : (elt -> unit) -> t -> unit
    val fold : (elt -> 'a -> 'a) -> t -> 'a -> 'a
    val for_all: (elt -> bool) -> t -> bool
    (* val exists: (elt -> bool) -> t -> bool *)
    val filter: (elt -> bool) -> t -> t
    (* val partition: (elt -> bool) -> t -> t * t *)
    val cardinal : t -> int
    val elements : t -> elt list
    (* val min_elt : t -> elt *)
    (* val max_elt : t -> elt *)
    (* val choose : t -> elt *)
    (* val split : elt -> t -> t * bool * t *)
    (* val find : elt -> t -> elt *)
    val of_list : elt list -> t


    (* Not present in std *)
    val find : (elt -> bool) -> t -> elt option
    val binary_find : (elt -> int) -> t -> elt option
    val check : t -> bool (* not present in std *)
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
	      | Node(_, v, Node(_, v', _)) when Ord.compare v v' > 0 -> false
	      | Node(Node(_, v', _), v, _) when Ord.compare v v' < 0 -> false
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
	      | Node(_, v', _) when Ord.compare v v' = 0 -> true
	      | Node(a, v', _) when Ord.compare v v' < 0  -> aux a
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
	      | Node(a, v', b) when Ord.compare v v' = 0 -> Node(a, v, b)
	      | Node(a, v', b) when Ord.compare v v' < 0 -> balance (aux a) v' b
	      | Node(a, v', b) -> balance a v' (aux b)
	      | _ -> Node(Empty, v, Empty)
      in
      aux t

    (* TODO: test and fail silently if v missing in t *)
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
	      | Node(Empty, v', Empty) when Ord.compare v v' = 0 -> Empty
	      | Node(a, v', b) when Ord.compare v v' = 0 -> merge a b
	      | Node(a, v', b) when Ord.compare v v' < 0 -> balance (aux a v) v' b
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

    let for_all f t =
      let rec aux = function
        | Empty -> true
        | Node(lhs, v, rhs) ->
           if not (aux lhs)
           then false
           else if not (f v)
           then false
           else aux rhs
      in
      aux t

    let binary_find f t =
      let rec aux = function
	      | Node (lhs, v, rhs) ->
           let direction = f v in
           if direction = 0
           then Some v
           else if direction < 0
           then aux lhs
           else aux rhs
	      | Empty ->
           None
      in
      aux t

    let find f t =
      let rec aux = function
        | Empty -> None
        | Node(lhs, v, rhs) when f v -> Some v
        | Node(lhs, v, rhs) -> match aux lhs with
                               | None -> aux rhs
                               | ret -> ret
      in
      aux t

    let filter f t =
      fold (fun v acc -> if f v then add v acc else acc) t empty

    (* O(n) *)
    let cardinal t =
      let rec aux = function
	      | Node(lhs, _, rhs) ->
           aux lhs + 1 + aux rhs
	      | Empty ->
           0
      in
      aux t

    let of_list l =
      List.fold_left (fun acc e ->
          add e acc) empty l

    (* Quick and DIRTY implementation *)
    let elements t =
      fold (fun v acc -> v::acc) t []
      |> List.rev

    (* Quick and DIRTY implementation *)
    let compare a b =
      match cardinal a - cardinal b with
      | 0 ->
         let rec diff2 la lb =
           match la, lb with
           | hda::tla, hdb::tlb ->
              begin match Ord.compare hda hdb with
              | 0 -> diff2 tla tlb
              | diff -> diff
              end
           | _, _ ->
              0
         in
         diff2 (elements a) (elements b)
      | diff ->
         diff

  end
