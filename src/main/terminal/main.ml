(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/10 11:51:10 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/19 15:14:15 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module rec K : Term_intf.Key_intf = Key
   and GK : Shared_intf.GameKey_intf = Gamekey
   and KP : (Shared_intf.KeyPair_intf
             with type key = K.t
             with type gamekey = GK.t) = Keypair.Make(K)(GK)
   and G : (Shared_intf.Graph_impl_intf
            with type kpset = KP.Set.t) = Graph_inst.Make(KP)
   and D : (Shared_intf.Display_intf) = Display.Make(K)(KP)(G)(A)
   and A : (Shared_intf.Algo_intf
            with type key = K.t
            with type keypair = KP.t
            with type kpset = KP.Set.t
            with type vertex = G.V.t
            with type edge = G.E.t) = Algo.Make(K)(GK)(KP)(G)


let () =
  match D.run_err () with
  | Error msg ->
     Ftlog.lvl 0;
     Ftlog.outnl "%s Error: \"%s\"" Sys.argv.(0) msg
  | _ -> ()
