(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/16 07:03:16 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/16 12:10:49 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module rec K : Term_intf.Key_intf = Key
   and GK : Shared_intf.GameKey_intf = Gamekey
   and KP : (Shared_intf.KeyPair_intf
             with type key = K.t
             with type gamekey = GK.t) = Keypair.Make(K)(GK)
   and G : (Shared_intf.Graph_impl_intf
            with type kpset = KP.Set.t) = Graph_inst.Make(KP)
   and D : (Shared_intf.Display_intf
            with type keypair = KP.t
            with type vertex = G.V.t
            with type edge = G.E.t) = Display.Make(K)(KP)(G)(A)
   and A : (Shared_intf.Algo_intf
            with type key = K.t
            with type keypair = KP.t
            with type kpset = KP.Set.t) = Algo.Make(K)(GK)(KP)(G)(D)


(* let log s = *)
(*   ignore( *)
(*       Js.Unsafe.fun_call (Js.Unsafe.js_expr "console.log") [| Js.Unsafe.inject s |] *)
(*     ) *)



(* let work () = *)
(*   let (~|) = Js.Unsafe.obj in *)
(*   let (@) k v = (k, Js.Unsafe.inject v) in *)

(*   let node i n w fc fs = *)
(*     ~| [| "data" @ ~| [| "id" @ i *)
(*                        ; "name" @ n *)
(*                        ; "weight" @ w *)
(*                        ; "faveColor" @ fc *)
(*                        ; "faveShape" @ fs *)
(*                       |] |] *)
(*   in *)
(*   let edge s t fc s = *)
(*     ~| [| "data" @ ~| [| "source" @ s *)
(*                        ; "target" @ t *)
(*                        ; "faveColor" @ fc *)
(*                        ; "strength" @ s *)
(*                       |] |] *)
(*   in *)
(*   let _ = *)
(*     ~| [| "test" @ "salut" *)
(*         ; "layout" @ *)
(*             ~| [| *)
(*                 "name" @ "cose" *)
(*               ; "padding" @ 10 *)
(*               |] *)
(*         ; "elements" @ *)
(*             ~| [| *)
(*                 "nodes" @ ~| [| node "j" "Jerry" 65 "#6FB1FC" "triangle" *)
(*                               ; node "e" "Elaine" 45 "#EDA1ED" "ellipse" *)
(*                               ; node "k" "Kramer" 75 "#86B342" "octagon" *)
(*                               ; node "g" "George" 70 "#F5A45D" "rectangle" *)
(*                              |] *)
(*               ; "edges" @ ~| [| edge "j" "e" "#6FB1FC" 90 *)
(*                               ; edge "j" "k" "#6FB1FC" 70 *)
(*                               ; edge "j" "g" "#6FB1FC" 80 *)
(*                               ; edge "e" "j" "#EDA1ED" 95 *)
(*                               ; edge "e" "k" "#EDA1ED" 60 *)
(*                               ; edge "k" "j" "#86B342" 100 *)
(*                               ; edge "k" "e" "#86B342" 100 *)
(*                               ; edge "k" "g" "#86B342" 100 *)
(*                               ; edge "g" "j" "#F5A45D" 90 *)
(*                              |] *)
(*               |] *)
(*        |] *)
(*   in *)
(*   () *)
(* let elt = *)

  (* let cy = ref None in *)

      (* cy := Some v; *)
       (* Ftlog.outnl "ok" *)
    (* end; *)

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
