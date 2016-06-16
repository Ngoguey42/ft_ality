(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   display.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Ngo <ngoguey@student.42.fr>                +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/03 17:26:03 by Ngo               #+#    #+#             *)
(*   Updated: 2016/06/16 09:26:49 by ngoguey          ###   ########.fr       *)
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

    (* TODO: remove wait() function  *)
    (* let wait milli = *)
    (*   let sec = milli /. 1000. in *)
    (*   let tm1 = Unix.gettimeofday () in *)
    (*   while Unix.gettimeofday () -. tm1 < sec do () done *)

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
      Ftlog.lvl 0;
      Ftlog.outnl "Display.run_err()";
      Ftlog.lvl 2;
      Ftlog.outnl "if stdin open, pass stdin";
      Ftlog.outnl "elseif argv[1] can be open, pass file";
      Ftlog.outnl "else, error print usage";

      Ftlog.outnl "if error in Algo.create_err, exit with message";
      Ftlog.outnl "else continue";
      match Algo.create_err stdin with
      | Error msg -> Error msg
      | Ok dat -> Ok ()
  end
