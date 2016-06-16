(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   display.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Ngo <ngoguey@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/03 17:26:03 by Ngo               #+#    #+#             *)
(*   Updated: 2016/06/16 12:04:15 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make (Key : Term_intf.Key_intf)
            (KeyPair : Shared_intf.KeyPair_intf
             with type key = Key.t)
            (Graph : Shared_intf.Graph_impl_intf
             with type kpset = KeyPair.Set.t)
            (Algo : Shared_intf.Algo_intf
             with type key = Key.t
             with type keypair = KeyPair.t
             with type kpset = KeyPair.Set.t)
       : (Shared_intf.Display_intf
          with type keypair = KeyPair.t
          with type vertex = Graph.V.t
          with type edge = Graph.E.t) =
  struct

    type keypair = KeyPair.t
    type vertex = Graph.V.t
    type edge = Graph.E.t

    (* Internal *)

    module Error =
      struct
        let missing_data () =
          Dom_html.window##alert (Js.string "Error: Display not initialized");
          Js._false

        let msg msg =
          Dom_html.window##alert (
              Printf.sprintf "Error: \"%s\"" msg
              |> Js.string);
          Js._false

      end

    module DOMElements =
      struct
        type t = {
            cy : Dom_html.element Js.t
          ; open_button : Dom_html.inputElement Js.t
          }

        (* Internal *)

        let element_of_name_err name =
          Ftlog.outnl "Retreiving `%s` element in page" name;
          match Dom_html.getElementById name with
          | exception _ ->
             Error (Printf.sprintf "Could not retreive `%s` in DOM" name)
          | v ->
             Ok v


        (* Exposed *)

        let create_err () =
          match element_of_name_err "cy"
              , element_of_name_err "open_button" with
          | Ok cy, Ok open_button_raw ->
             begin match Dom_html.CoerceTo.input open_button_raw
                   |> Js.Opt.to_option with
             | None -> Error "Could not coerce `OpenButton` to input"
             | Some open_button -> Ok {cy; open_button}
             end
          | Error msg, _ | _, Error msg -> Error msg


        module OpenButton =
          struct
            let add_click_listener ({open_button} as de) f =
              Dom_html.addEventListener
                open_button
                Dom_html.Event.change
                (Dom_html.handler f)
                Js._false
              |> ignore;
              de

            let ask_filepath_err ({open_button} as de) =
              Ftlog.lvl 4;
              Ftlog.outnl "OpenButton.ask_filepath_err()";
              Ftlog.lvl 6;
              match open_button##files |> Js.Optdef.to_option with
              | None -> Error "Undefined files";
              | Some files ->
                 (* let _ = files##item  in *)
                 (* match (files##item 0) |> Js.Opt.to_option with *)
                 (*              | None -> Error "Undefined files"; *)
                 (*              | Some file -> *)
                                  Ok "lol"

          end
      end

    type t = {
        de : DOMElements.t
      ; test : int
      }

    module Input =
      struct

        module KS = KeyPair.Set
        (* TODO: implement clear screan with \012 *)
        type press = Exit | Empty | Set of KS.t

        let range_msf = 150. /. 1000.
        let incrrange_msf = 125. /. 1000.

        let next dat =
          Empty

        (* Program main loop *)
        let loop_err algodat_init =
          let rec aux dat =
            match next dat with
            | Empty -> aux dat
            | Exit -> Ok ()
            | Set kset -> match Algo.on_key_press_err dat kset with
                          | Ok dat' -> aux dat'
                          | Error msg -> Error msg
          in
          aux algodat_init
      end

    let run_on_click_err ({de; test} as data) =
      Ftlog.lvl 2;
      Ftlog.outnl "run_on_click_err()";
      Ftlog.outnl "%d" test;
      match DOMElements.OpenButton.ask_filepath_err de with
      | Error err -> Error err
      | Ok filename -> Ok {data with test = test + 1}

    (* Only bit of imperative style contained in this closure *)
    module Closure =
      struct
        let data_ref = ref None

        let init data =
          data_ref := Some data

        let dispatch_event f =
          match !data_ref with
          | None -> Error.missing_data ()
          | Some data ->
             match f data with
             | Error msg -> Error.msg msg
             | Ok data ->
                data_ref := Some data;
                Js._true

        let on_click _ =
          Ftlog.lvl 0;
          Ftlog.outnl "Closure.on_click() callback";
          dispatch_event run_on_click_err

      end


    (* Exposed *)

    let declare_keypair kp =
      Ftlog.lvl 8;
      Ftlog.outnl "Display.declare_keypair(%s)"
                  (KeyPair.to_string kp);
      ()

    let declare_vertex v =
      Ftlog.lvl 8;
      Ftlog.outnl "Display.declare_vertex(%s)"
                  (Graph.V.label v |> Graph.Vlabel.to_string);
      ()

    let declare_edge e =
      Ftlog.lvl 8;
      Ftlog.outnl "Display.declare_edge(src:%s label:%s dst:%s)"
                  (Graph.E.src e |> Graph.V.label |> Graph.Vlabel.to_string)
                  (Graph.E.label e |> Graph.Elabel.to_string)
                  (Graph.E.dst e |> Graph.V.label |> Graph.Vlabel.to_string);
      ()

    let focus_vertex_err v =
      Ftlog.lvl 8;
      Graph.V.label v
      |> Graph.Vlabel.to_string
      |> Ftlog.outnl "Display.focus_vertex_err(%s)";
      Ok ()

    let run_err () =
      Ftlog.lvl 2;
      Ftlog.outnl "Display.run_err()";
      Ftlog.lvl 4;
      match DOMElements.create_err () with
      | Error msg ->
         Error msg
      | Ok de ->
         Ftlog.outnl "Adding listener to open_button clicks";
         let de = DOMElements.OpenButton.add_click_listener de Closure.on_click in
         Closure.init {de; test = 0};
         Ok ()
                      (* Error "test err" *)
                      (* Ftlog.outnl "if error in Algo.create_err, exit with message"; *)
                      (* Ftlog.outnl "else continue"; *)
                      (* match Algo.create_err stdin with *)
                      (* | Error msg -> Error msg *)
                      (* | Ok dat -> Ok () *)
  end
