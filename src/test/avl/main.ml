(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/06 14:59:50 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/06 16:19:10 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Int = struct
  type t = int
  let compare = compare
end

module IntAvl = Avl.Make(Int)
module IntSet = Set.Make(Int)

let check_order silent v (prev_int, num_elt) =
  if not silent
  then Printf.eprintf "Avl: v=%d\n%!" v;
  if v <= prev_int then (
    Printf.eprintf "Error fold\n%!";
    exit(1)
  ) else (
    (v, num_elt + 1)
  )

let check_order_ref v =
  Printf.eprintf "Set: v=%d\n%!" v


let test_depth = 7

let rec incr_depth t prev_depth =
  if prev_depth + 1 < test_depth
  then run_test t (prev_depth + 1)

and run_test (t, refe) depth =

  for i = 1 to test_depth do (
    if depth <= 0
    then Printf.eprintf "Test at depth=%d for i=%d\n%!" depth i;

    let t' = IntAvl.add i t in
    let refe' = IntSet.add i refe in
    if not (IntAvl.check t') then (
      Printf.eprintf "Error invariants\n%!";
      exit(1)
    );
    let _, num_elt = IntAvl.fold (check_order true) t' (min_int, 0) in
    if num_elt <> IntSet.cardinal refe'
       || num_elt <> IntAvl.cardinal t' then (
      Printf.eprintf "Error num_elt got %d, wanted %d\n%!"
                     num_elt (IntSet.cardinal refe');
      let _, _ = IntAvl.fold (check_order false) t' (min_int, 0) in
      IntSet.iter check_order_ref refe';
      exit(1)
    );

    incr_depth (t', refe') depth
  )
  done;
  ()

let () =
  run_test (IntAvl.empty, IntSet.empty) 0;
  let n = float test_depth in
  Printf.eprintf "PASSED all %.0f combinations!!!\n%!" (n ** n);
  ()
