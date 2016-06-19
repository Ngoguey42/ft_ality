(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   display.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Ngo <ngoguey@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/03 17:26:03 by Ngo               #+#    #+#             *)
(*   Updated: 2016/06/19 12:04:53 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make (Key : Browser_intf.Key_intf)
            (KeyPair : Shared_intf.KeyPair_intf
             with type key = Key.t)
            (Graph : Shared_intf.Graph_impl_intf
             with type kpset = KeyPair.Set.t)
            (Algo : Shared_intf.Algo_intf
             with type key = Key.t
             with type keypair = KeyPair.t
             with type kpset = KeyPair.Set.t
             with type vertex = Graph.V.t
             with type edge = Graph.E.t)
            (Cy : Browser_intf.Cy_intf
             with type vertex = Graph.V.t
             with type edge = Graph.E.t
             with type algo = Algo.t)
       : Shared_intf.Display_intf =
  struct
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
      end

    module OpenButton =
      struct

        let create_err () =
          match Dom_html.getElementById "open_button" with
          | exception _ ->
             Error "Could not retreive `open_button` in DOM"
          | v ->
             match Dom_html.CoerceTo.input v
                   |> Js.Opt.to_option with
             | None -> Error "Could not coerce `OpenButton` to input"
             | Some v -> Ok v

        let add_changes_listener open_button f =
          Lwt_js_events.changes open_button f

        let query_file_content_err open_button =
          Ftlog.lvl 4;
          Ftlog.outnl "OpenButton.query_file_content_err()";
          Ftlog.lvl 6;
          match open_button##.files |> Js.Optdef.to_option with
          | None -> Error "Undefined files";
          | Some files ->
             match files##item 0 |> Js.Opt.to_option with
             | None -> Error "Undefined file";
             | Some file -> Ok (File.readAsText file)
      end

    type t = {
        (* Doesn't vary over time *)
        ob : Dom_html.inputElement Js.t
      ; changes_listener : unit Lwt.t

      (* Need to be ##destroy() between two phases *)
      ; cy : Cy.t option

      (* Need to be Lwt.cancel() *)
      ; keys_listener : unit Lwt.t option
      ; file_listener : unit Lwt.t option

      (* Fully functionnal *)
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
        val on_dom_loaded_err : unit -> (t, string) result
        val on_change_err : t -> (t, string) result
        val on_file_loaded_err : Js.js_string Js.t -> t -> (t, string) result
        val on_key_press_err : Dom_html.keyboardEvent Js.t -> t
                               -> (t, string) result
      end

    module type Closure_intf =
      sig
        val on_dom_loaded_err : unit -> (unit, string) result
        val on_change : Dom_html.event Js.t -> unit Lwt.t -> unit Lwt.t
        val on_file_loaded : Js.js_string Js.t -> unit Lwt.t
        val on_key_press : Dom_html.keyboardEvent Js.t -> unit Lwt.t
                           -> unit Lwt.t
      end


    module Run (Cl : Closure_intf) : Run_intf =
      struct

        let cleanup actions dat_start =
          let aux dat action =
            match action, dat with
            | `Cy_destroy, {cy = Some cy} ->
               Ftlog.outnl "Destroying cy";
               Cy.destroy cy;
               {dat with cy = None}
            | `Keys_listener_cancel, {keys_listener = Some kl} ->
               Ftlog.outnl "Canceling keys_listener";
               Lwt.cancel kl;
               {dat with keys_listener = None}
            | `File_listener_cancel, {file_listener = Some fl} ->
               Ftlog.outnl "Canceling file_listener";
               Lwt.cancel fl;
               {dat with file_listener = None}
            | `File_listener_cleanup, {file_listener = Some fl} ->
               {dat with file_listener = None}
            | _, _ ->
               dat
          in
          ListLabels.fold_left ~f:aux ~init:dat_start actions

        let on_dom_loaded_err () =
          Ftlog.outnllvl 6 "Run.init_err()";
          match OpenButton.create_err () with
          | Error msg -> Error msg
          | Ok ob ->
             Ftlog.outnllvl 7 "Adding listener to open_button change";
             Ok { ob
                ; changes_listener =
                    OpenButton.add_changes_listener ob Cl.on_change
                ; cy = None
                ; keys_listener = None
                ; file_listener = None
                ; algodat = None}

        let on_change_err dat_dirty =
          Ftlog.outnllvl 2 "Run.on_change_err()";
          Ftlog.lvl 3;
          let ({ob} as dat) = cleanup [`File_listener_cancel] dat_dirty in
          match OpenButton.query_file_content_err ob with
          | Error err -> Error err
          | Ok t -> Ftlog.outnllvl 3 "Adding listener to on_file_loaded";
                    let fl = Lwt.bind t Cl.on_file_loaded in
                    Ok {dat with file_listener = Some fl}

        let on_file_loaded_err jstr dat_dirty =
          Ftlog.lvl 2;
          Ftlog.outnl "Run.on_file_loaded_err()";
          Ftlog.lvl 3;
          let ({keys_listener; cy} as dat) =
            cleanup [`Keys_listener_cancel; `Cy_destroy; `File_listener_cleanup]
                    dat_dirty
          in
          let stdinfiller = Sys_js.set_channel_filler stdin in
          stdinfiller (fun () ->
              stdinfiller (fun () -> "");
              Js.to_string jstr
            );
          match Algo.create_err stdin with
          | Error msg -> Error msg
          | Ok algodat ->
             match Cy.create_err algodat with
             | Error msg -> Error msg
             | Ok cy ->
                Ftlog.outnllvl 3 "Adding listener to keypresses";
                let kl = Lwt_js_events.keydowns
                           Dom_html.document
                           Cl.on_key_press
                in
                Ok {dat with algodat = Some algodat
                           ; cy = Some cy
                           ; keys_listener = Some kl}

        let on_key_press_err ke dat_dirty =
          Ftlog.outnllvl 2 "Run.on_key_press_err()";
          Ftlog.lvl 3;
          let ({cy} as dat) = cleanup [] dat_dirty in
          Ok dat

      end

    module Closure (R : Run_intf) : Closure_intf =
      struct
        (* Only bit of imperative style contained in this closure *)
        let data_ref = ref None

        let on_dom_loaded_err () =
          Ftlog.lvl 4;
          Ftlog.outnl "Closure.init_err()";
          match R.on_dom_loaded_err () with
          | Ok dat -> data_ref := Some dat;
                      Ok ()
          | Error msg-> Error msg

        let dispatch_event_lwt f =
          match !data_ref with
          | None ->
             Error.Lwt.missing_data ()
          | Some dat ->
             match f dat with
             | Error msg ->
                Error.Lwt.msg msg
             | Ok dat -> (* Shadowing dat *)
                data_ref := Some dat;
                Lwt.return_unit

        let on_change _ _ =
          Ftlog.lvl 0;
          Ftlog.outnl "Closure.on_change()";
          dispatch_event_lwt R.on_change_err

        let on_file_loaded jstr =
          Ftlog.lvl 0;
          Ftlog.outnl "Closure.on_file_loaded()";
          dispatch_event_lwt (R.on_file_loaded_err jstr)

        let on_key_press ke _ =
          Ftlog.lvl 0;
          Ftlog.outnl "Closure.on_key_press()";
          dispatch_event_lwt (R.on_key_press_err ke)

      end

    module rec Cl : Closure_intf = Closure(R)
       and R : Run_intf = Run(Cl)


    (* Exposed *)

    let run_err () =
      Ftlog.lvl 2;
      Ftlog.outnl "Display.run_err()";
      Cl.on_dom_loaded_err ()

  end
