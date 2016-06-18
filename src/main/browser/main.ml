(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/16 07:03:16 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/18 11:29:35 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module rec K : Browser_intf.Key_intf = Key
   and GK : Shared_intf.GameKey_intf = Gamekey
   and KP : (Shared_intf.KeyPair_intf
             with type key = K.t
             with type gamekey = GK.t) = Keypair.Make(K)(GK)
   and G : (Shared_intf.Graph_impl_intf
            with type kpset = KP.Set.t) = Graph_inst.Make(KP)
   and A : (Shared_intf.Algo_intf
            with type key = K.t
            with type keypair = KP.t
            with type kpset = KP.Set.t
            with type vertex = G.V.t
            with type edge = G.E.t) = Algo.Make(K)(GK)(KP)(G)
   and C : (Browser_intf.Cy_intf
            with type vertex = G.V.t
            with type edge = G.E.t) = Cy.Make(G)
   and D : (Shared_intf.Display_intf) = Display.Make(K)(KP)(G)(A)(C)


let () =
  (* Ftlog.disable (); *)
  Ftlog.lvl 0;
  let on_domContentLoaded _ =
    Ftlog.outnl "on_domContentLoaded()";
    match D.run_err () with
    | Error msg ->
       Dom_html.window##alert (
           Printf.sprintf "Error: \"%s\"" msg
           |> Js.string);
       Js._false
    | _ ->
       Js._true
  in
  Ftlog.outnl "Listen domContentLoaded for Display.run_err() phase";
  Dom_html.addEventListener
    Dom_html.document
    Dom_html.Event.domContentLoaded
    (Dom_html.handler on_domContentLoaded)
    Js._false
  |> ignore;
  ()
