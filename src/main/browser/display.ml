(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   display.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Ngo <ngoguey@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/03 17:26:03 by Ngo               #+#    #+#             *)
(*   Updated: 2016/06/18 09:59:01 by ngoguey          ###   ########.fr       *)
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
        module Lwt =
          struct
            let missing_data () =
              Dom_html.window##alert (Js.string "Error: Display not initialized");
              Lwt.fail_with "Error: Display not initialized"

            let msg msg =
              Dom_html.window##alert (
                  Printf.sprintf "Error: \"%s\"" msg
                  |> Js.string);
              Lwt.fail_with msg
          end

        module Js =
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
          Ftlog.lvl 8;
          begin match Cy.of_eltid_err "cy" with
          | Error msg ->
             Printf.eprintf "%s\n%!" msg;
          | Ok cy ->
             Printf.eprintf "Ok (%d)\n%!"
                            (cy##width)
          end;
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

            let ask_file_err ({open_button} as de) =
              Ftlog.lvl 4;
              Ftlog.outnl "OpenButton.ask_file_err()";
              Ftlog.lvl 6;
              match open_button##.files |> Js.Optdef.to_option with
              | None -> Error "Undefined files";
              | Some files ->
                 match (files##item 0) |> Js.Opt.to_option with
                 | None -> Error "Undefined file";
                 | Some file ->
                    (* val readAsText : #blob Js.t -> Js.js_string Js.t Lwt.t *)
                    Ok (File.readAsText file)
                    (* file##.name |> Js.to_string *)
                    (* |> Ftlog.outnl "Found file \"%s\""; *)
                    (* let fr = new%js File.fileReader in *)
                    (* fr##.onloadend := yes *)


                    (* fr##readAsText file *)
                    (* |> ignore; *)

                    (* let file_any = fr##.result in *)
                    (* match File.CoerceTo.string file_any |> Js.Opt.to_option with *)
                    (* | None -> Error "Could not read file" *)
                    (* | Some str -> *)
                    (*    let str = Js.to_string str in *)
                    (*    Printf.eprintf "Some '%s'\n%!" str; *)
                       (* Sys_js.set_channel_filler stdin (fun () -> *)
                       (*                             Printf.eprintf "callbacklol\n%!"; *)
                       (*                             str *)
                       (*                           ); *)
                    (*    let rec aux () = *)
                    (*      match input_line stdin with *)
                    (*      | exception _ -> *)
                    (*         Printf.eprintf "End\n%!" *)
                    (*      | str -> *)
                    (*         Printf.eprintf "en cours'%s'\n%!" str; *)
                    (*         aux () *)
                    (*    in *)
                    (*    Printf.eprintf "try read\n%!"; *)
                    (*    aux (); *)
                    (*    Printf.eprintf "\n%!"; *)
                       (* Ok () *)

          end
      end

    type t = {
        de : DOMElements.t
      ; algodat : Algo.t option
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

    module type Run_intf =
      sig
        val init_err : unit -> (t, string) result
        val on_click_err : t -> (t, string) result
        val on_file_loaded_err : Js.js_string Js.t -> t -> (t, string) result
      end

    module type Closure_intf =
      sig
        val init_err : unit -> (unit, string) result
        val on_click : 'a -> bool Js.t
        val on_file_loaded : Js.js_string Js.t -> unit Lwt.t
      end

    module Run (Cl : Closure_intf) : Run_intf =
      struct

        let init_err () =
          Ftlog.lvl 6;
          Ftlog.outnl "Run.init_err()";
          match DOMElements.create_err () with
          | Error msg ->
             Error msg
          | Ok de ->
             Ftlog.lvl 6;
             Ftlog.outnl "Adding listener to open_button clicks";
             let de = DOMElements.OpenButton.add_click_listener
                        de Cl.on_click in
             Ok {de; algodat = None}

        let on_click_err ({de} as data) =
          Ftlog.lvl 2;
          Ftlog.outnl "Run.on_click_err()";
          (* val readAsText : #blob Js.t -> Js.js_string Js.t Lwt.t *)
          match DOMElements.OpenButton.ask_file_err de with
          | Error err -> Error err
          | Ok t -> let _ = Lwt.bind t Cl.on_file_loaded in
                    Ftlog.outnl "Adding listener to on_file_loaded";
                    Ok data

        let on_file_loaded_err jstr dat =
          Ftlog.lvl 2;
          Ftlog.outnl "Run.on_file_loaded_err()";
          let str = Js.to_string jstr in
          let stdinfiller = Sys_js.set_channel_filler stdin in
          stdinfiller (fun () ->
              stdinfiller (fun () -> "");
              Js.to_string jstr
            );
          match Algo.create_err stdin with
          | Error msg -> Error msg
          | Ok algodat -> Ok {dat with algodat = Some algodat}

      end

    module Closure (R : Run_intf) : Closure_intf =
      struct
        (* Only bit of imperative style contained in this closure *)
        let data_ref = ref None

        let init_err () =
          Ftlog.lvl 4;
          Ftlog.outnl "Closure.init_err()";
          match R.init_err () with
          | Ok dat -> data_ref := Some dat;
                      Ok ()
          | Error msg -> Error msg

        let dispatch_event_js f =
          match !data_ref with
          | None ->
             Error.Js.missing_data ()
          | Some data ->
             match f data with
             | Error msg -> Error.Js.msg msg
             | Ok data ->
                data_ref := Some data;
                Js._true

        let dispatch_event_lwt f =
          match !data_ref with
          | None ->
             Error.Lwt.missing_data ()
          | Some data ->
             match f data with
             | Error msg ->
                Error.Lwt.msg msg
             | Ok data ->
                data_ref := Some data;
                Lwt.return_unit
                (* Js._true *)

        let on_click _ =
          Ftlog.lvl 0;
          Ftlog.outnl "Closure.on_click()";
          dispatch_event_js R.on_click_err

        let on_file_loaded jstr =
          Ftlog.lvl 0;
          Ftlog.outnl "Closure.on_file_loaded()";
          dispatch_event_lwt (R.on_file_loaded_err jstr)

      end

    module rec Cl : Closure_intf = Closure(R)
       and R : Run_intf = Run(Cl)

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
      Cl.init_err ()

  end
