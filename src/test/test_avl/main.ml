(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/06 14:59:50 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/06 14:59:53 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module IntAvl = Avl.Make(struct
                          type t = int
                          let compare = compare
                        end)

let test_depth = 7

let rec incr_depth t prev_depth =
  if prev_depth + 1 < test_depth
  then run_test t (prev_depth + 1)

and run_test t depth =

  for i = 1 to test_depth do (
    if depth <= 0
    then Printf.eprintf "Test at depth=%d for i=%d\n%!" depth i;

    let t' = IntAvl.add i t in
    if not (IntAvl.check t') then (
      Printf.eprintf "Error bordel\n%!";
      exit(1)
    );

    incr_depth t' depth
  )
  done;
  ()


let () =
  let _ = IntAvl.add 13 IntAvl.empty in
  run_test IntAvl.empty 0;
  Printf.eprintf "salut\n%!";
  ()
