(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   display.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Ngo <ngoguey@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/03 17:26:03 by Ngo               #+#    #+#             *)
(*   Updated: 2016/06/14 16:07:26 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make (Key : Term_intf.Key_intf)
            (KeyCont : Shared_intf.Key_container_intf
             with type key = Key.t)
            (Graph : Shared_intf.Graph_intf
             with type key = Key.t
             with type keyset = KeyCont.Set.t)
            (Algo : Shared_intf.Algo_intf
             with type key = Key.t
             with type keyset = KeyCont.Set.t)
       : (Shared_intf.Display_intf
          with type key = Key.t
          with type vertex = Graph.V.t
          with type edge = Graph.E.t) =
  struct

    type key = Key.t
    type vertex = Graph.V.t
    type edge = Graph.E.t


    (* Internal *)

    (* TODO: remove wait() function  *)
    let wait milli =
      let sec = milli /. 1000. in
      let tm1 = Unix.gettimeofday () in
      while Unix.gettimeofday () -. tm1 < sec do () done

    module Input =
      struct

        (* Key presses detection with `ncurses` using non-blocking `getch()`:
         * When next() detects an input it creates a `key set` with this key,
         *   and opens a `range_millisecf` millisec time frame in which the user
         *   may press new keys that will be added to the set. Each new key
         *   added to the set extend the time frame by `incrrange_millisecf`
         *   milliseconds.
         *)

        (* Key presses detection with `termcap` using non-blocking `input_char`:
         * When next() detects an input it opens a `range_millisecf` millisec
         *   time frame in which the user may press new keys.
         *)

        module KS = KeyCont.Set

        type press = Exit | Empty | Set of KS.t

        let range_msf = 150. /. 1000.
        let incrrange_msf = 75. /. 1000.

        let read_escape_seq () =
          let rec aux l =
            match input_char stdin with
            | exception End_of_file -> l
            | c -> aux (c::l)
          in
          aux []
          |> List.rev

        let return_keyset kset =
          if KS.is_empty kset
          then Empty
          else Set kset

        let rec build_keyset kset timeout c =
          match c with
          | '\004' ->
             Exit
          | '\027' ->
             begin match read_escape_seq () with
             | [] -> Exit
             | l -> recurse_with_key kset timeout (Key.of_sequence l)
             end
          | c ->
             recurse_with_key kset timeout (Key.of_char c)

        and recurse_with_key kset timeout k =
          let now = Unix.gettimeofday () in
          wait_next_char (KS.add k kset) (now +. incrrange_msf)

        and wait_next_char kset timeout =
          let rec aux () =
            let now = Unix.gettimeofday () in
            if now > timeout then
              None
            else match input_char stdin with
                 | exception End_of_file -> aux ()
                 | c -> Some c
          in
          match aux () with
          | None -> return_keyset kset
          | Some c -> build_keyset kset timeout c

        let next () =
          match input_char stdin with
          | exception End_of_file -> Empty
          | c -> build_keyset KS.empty (Unix.gettimeofday () +. range_msf) c

        let loop_err (algodat_init, keys) =
          let rec aux dat =
            match next () with
            | Empty -> aux dat
            | Exit -> Ok ()
            | Set kset -> match Algo.on_key_press_err kset dat with
                          | Ok dat' -> aux dat'
                          | Error msg -> Error msg
          in
          aux algodat_init
      end

    let init_termcap () =
      (* TODO: check for error exceptions *)
      let terminfo = Unix.tcgetattr Unix.stdin in
      let newterminfo = {terminfo with
                          Unix.c_icanon = false
                        ; Unix.c_vmin = 0
                        ; Unix.c_echo = false
                        ; Unix.c_vtime = 0}
      in
      at_exit (fun _ -> Unix.tcsetattr Unix.stdin Unix.TCSAFLUSH terminfo);
      Printf.eprintf "  Init ncurses\n%!";
      Unix.tcsetattr Unix.stdin Unix.TCSAFLUSH newterminfo;
      Ok ()


    (* Exposed *)

    let declare_vertex v =
      Printf.eprintf "\t\tDisplay.declare_vertex(%s)\n%!"
                     (Graph.V.label v |> Graph.Vlabel.to_string);
      ()

    let declare_edge e =
      Printf.eprintf "\t\tDisplay.declare_edge(src:%s label:%s dst:%s)\n%!"
                     (Graph.E.src e |> Graph.V.label |> Graph.Vlabel.to_string)
                     (Graph.E.label e |> Graph.Elabel.to_string)
                     (Graph.E.dst e |> Graph.V.label |> Graph.Vlabel.to_string);
      ()

    let focus_vertex_err v =
      Graph.V.label v
      |> Graph.Vlabel.to_string
      |> Printf.eprintf "\t\tDisplay.focus_vertex_err(%s)\n%!";
      Ok ()

    let run_err () =
      Printf.eprintf "Display.run_err()\n%!";
      Printf.eprintf "  if stdin open, pass stdin\n%!";
      Printf.eprintf "  elseif argv[1] can be open, pass file\n%!";
      Printf.eprintf "  else, error print usage\n%!";

      Printf.eprintf "  if error in Algo.create_err, exit with message\n%!";
      Printf.eprintf "  else continue\n%!";
      match Algo.create_err stdin with
      | Error msg ->
         Error msg
      | Ok dat ->
         match init_termcap () with
         | Error msg -> Error msg
         | Ok _ ->  let res = Input.loop_err dat in
                    (* Curses.endwin (); *)
                    res
  end
