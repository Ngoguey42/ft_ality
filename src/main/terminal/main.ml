(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/10 11:51:10 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/14 14:57:00 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module rec D : (Shared_intf.Display_intf
                with type key = K.t
                with type vertex = G.V.t
                with type edge = G.E.t) = Display.Make(K)(KC)(G)(A)
   and A : (Shared_intf.Algo_intf
            with type key = K.t
            with type keyset = KC.Set.t) = Algo.Make(K)(KC)(G)(D)
   and G : (Shared_intf.Graph_intf
            with type key = K.t
            with type keyset = KC.Set.t) = Graph_inst.Make(K)(KC)
   and K : Term_intf.Key_intf = Key
   and KC : (Shared_intf.Key_container_intf
             with type key = K.t) = Key_container.Make(K)

let () =
  match D.run_err () with
  | Error msg ->
     Printf.eprintf "%s Error: \"%s\"\n%!" Sys.argv.(0) msg
  | _ -> ()
