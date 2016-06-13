(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   display.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Ngo <ngoguey@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/03 17:26:03 by Ngo               #+#    #+#             *)
(*   Updated: 2016/06/13 13:25:16 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make : Term_intf.Make_display_intf =
  functor (Key : Term_intf.Key_intf) ->
  functor (Graph : Shared_intf.Graph_intf
           with type key = Key.t) ->
  functor (Algo : Shared_intf.Algo_intf
           with type key = Key.t
           with type keyset = Graph.KeySet.t) ->
  struct

    type key = Key.t
    type vertex = Graph.V.t
    type edge = Graph.E.t


    (* Internal *)

    let wait milli =
      let sec = milli /. 1000. in
      let tm1 = Unix.gettimeofday () in
      while Unix.gettimeofday () -. tm1 < sec do () done

    type press = Exit | Empty | Set of Graph.KeySet.t

    let keyset_range_millisecf = 150. /. 1000.
    let keyset_incrange_millisecf = 50. /. 1000.

    let rec build_keypress_set kset timeout kcode =
      if Unix.gettimeofday () > timeout then
        if Graph.KeySet.is_empty kset
        then Empty
        else Set kset
      else if kcode = Curses.Key.backspace then
        Exit
      else if kcode = -1 then
        Curses.getch ()
        |> build_keypress_set kset timeout
      else
        let k = Key.of_curses_code kcode in
        if Graph.KeySet.mem k kset then
          Curses.getch ()
          |> build_keypress_set kset timeout
        else
          Curses.getch ()
          |> build_keypress_set (Graph.KeySet.add k kset)
                                (timeout +. keyset_incrange_millisecf)

    let next_keypress_set () =
      match Curses.getch () with
      | -1 ->
         Empty
      | kcode ->
         build_keypress_set Graph.KeySet.empty
                            (Unix.gettimeofday () +. keyset_range_millisecf)
                            kcode

    let init_curses () =
      Printf.eprintf "  Init ncurses\n%!";
      let w = Curses.initscr () in
      let seq = [ lazy (Curses.keypad w true)
                ; lazy (Curses.nodelay w true)
                ; lazy (Curses.noecho ())]
      in
      match ListLabels.for_all ~f:(fun l -> Lazy.force l) seq with
      | false -> Shared_intf.Error "Ncurses init failed"
      | true -> Shared_intf.Ok w

    let input_loop_err (algodat_init, keys) =
      match init_curses () with
      | Shared_intf.Error msg -> Shared_intf.Error msg
      | Shared_intf.Ok _ ->
         let rec aux dat =
           match next_keypress_set () with
           | Empty ->
              aux dat
           | Exit ->
              Shared_intf.Ok ()
           | Set kset ->
              match Algo.on_key_press_err kset dat with
              | Shared_intf.Ok dat' -> aux dat'
              | Shared_intf.Error msg -> Shared_intf.Error msg
         in
         let res = aux algodat_init in
         Curses.endwin ();
         res


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
      Printf.eprintf "\t\t  Print current state info to terminal\n%!";
      Shared_intf.Ok ()

    let run_err () =
      Printf.eprintf "Display.run_err()\n%!";
      Printf.eprintf "  if stdin open, pass stdin\n%!";
      Printf.eprintf "  elseif argv[1] can be open, pass file\n%!";
      Printf.eprintf "  else, error print usage\n%!";

      Printf.eprintf "  if error in Algo.create_err, exit with message\n%!";
      Printf.eprintf "  else continue\n%!";
      match Algo.create_err stdin with
      | Shared_intf.Error msg -> Shared_intf.Error msg
      | Shared_intf.Ok dat -> input_loop_err dat

  end
