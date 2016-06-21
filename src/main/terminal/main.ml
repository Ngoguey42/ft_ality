(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/10 11:51:10 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/21 15:44:55 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module KP : (Shared_intf.KeyPair_intf
             with module GK = Gamekey
             with type key = Key.t) = Keypair.Make(Key)(Gamekey)
module G : (Shared_intf.Graph_inst_intf
            with module KP = KP) = Graph_inst.Make(KP)
module A : (Shared_intf.Algo_intf
            with type key = Key.t
            with module KP = KP
            with module G = G) = Algo.Make(Key)(Gamekey)(KP)(G)
module D : Shared_intf.Display_intf = Display.Make(Key)(KP)(G)(A)

let () =
  match D.run_err () with
  | Error msg ->
     Ftlog.lvl 0;
     Ftlog.outnl "%s Error: \"%s\"" Sys.argv.(0) msg
  | _ -> ()
