(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/16 07:03:16 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/21 15:36:51 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(* module GK : Shared_intf.Gamekey_intf = Gamekey *)

module KP : (Shared_intf.KeyPair_intf
             with module GK = Gamekey
             with type key = Key.t) = Keypair.Make(Key)(Gamekey)
module G : (Shared_intf.Graph_inst_intf
            with module KP = KP) = Graph_inst.Make(KP)
module A : (Shared_intf.Algo_intf
            with type key = Key.t
            with module KP = KP
            with module G = G) = Algo.Make(Key)(Gamekey)(KP)(G)
module C : (Browser_intf.Cy_intf
            with module G = G
            with module A = A) = Cy.Make(G)(A)
module D : Shared_intf.Display_intf = Display.Make(Key)(KP)(G)(A)(C)


let () =
  (* Ftlog.disable (); *)
  Ftlog.lvl 0;
  Ftlog.outnl "Listen domContentLoaded before Display.run_err() phase";
  Lwt.bind
    (Lwt_js_events.domContentLoaded ())
    (fun () ->
      Ftlog.outnl "on_domContentLoaded()";
      match D.run_err () with
      | Error msg ->
         Dom_html.window##alert (
             Printf.sprintf "Error: \"%s\"" msg
             |> Js.string);
         Lwt.fail_with msg
      | _ ->
         Lwt.return_unit
    )
  |> ignore
