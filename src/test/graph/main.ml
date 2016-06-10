(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/06 16:51:20 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/10 08:24:18 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Vlb =
  struct
    type t = {
        name : string
      }
    let to_string {name} =
      Printf.sprintf "`%s`" name

  end

module Elb =
  struct
    type t = {
        name : string
      }
    let compare a b =
      0
    let default =
      { name = "dflt" }
    let to_string {name} =
      Printf.sprintf "`%s`" name
  end

module type Sig = Ftgraph_intf.PersistentDigraphAbstractLabeled_intf
module FTG : (Sig
              with type V.label = Vlb.t
               and type E.label = Elb.t) =
  Ftgraph.Make_PersistentDigraphAbstractLabeled(Vlb)(Elb)
module G : (Sig with type V.label = Vlb.t
                 and type E.label = Elb.t) =
  struct
    include Graph.Persistent.Digraph.AbstractLabeled(Vlb)(Elb)

    let invariants _ = true
    let binary_find_succ_e _ _ _ = None
  end


module Both =
  struct
    module V =
      struct
        let create lb =
          G.V.create lb, FTG.V.create lb

      end

    module E =
      struct
        let create (v1a, v1b) lb (v2a, v2b) =
          Printf.eprintf "%s\n%!" __LOC__;
          let ea = G.E.create v1a lb v2a in
          Printf.eprintf "%s\n%!" __LOC__;
          let eb = FTG.E.create v1b lb v2b in
          Printf.eprintf "%s\n%!" __LOC__;
          ea, eb

      end

    let add_vertex (ga, gb) (va, vb) =
      Printf.eprintf "%s\n%!" __LOC__;
      let ga = G.add_vertex ga va in
      let gb = FTG.add_vertex gb vb in
      ga, gb

    let add_edge_e (ga, gb) (ea, eb) =
      Printf.eprintf "%s\n%!" __LOC__;
      let ga = G.add_edge_e ga ea in
      Printf.eprintf "%s\n%!" __LOC__;
      let gb = FTG.add_edge_e gb eb in
      Printf.eprintf "%s\n%!" __LOC__;
      ga, gb

    let create_and_add_vertex (ga, gb) lb =
      let va, vb = G.V.create lb, FTG.V.create lb in
      G.add_vertex ga va, FTG.add_vertex gb vb

    let iter_and_print_vertex (ga, gb) =
      G.iter_vertex (fun v ->
          Printf.eprintf "  V: %10s succ[" (Vlb.to_string (G.V.label v));
          G.iter_succ_e (fun e ->
              let src, dst = G.E.src e, G.E.dst e in
              if G.V.compare v src <> 0 then (
                Printf.eprintf "Corrupted edge src %s\n%!" __LOC__;
                exit(1)
              );
              Printf.eprintf "%s->%s;%!"
                             (Elb.to_string (G.E.label e))
                             (Vlb.to_string (G.V.label dst));
              ()
            ) ga v;
          Printf.eprintf "]\n%!";
        ) ga;
      FTG.iter_vertex (fun v ->
          Printf.eprintf "FTV: %10s succ[" (Vlb.to_string (FTG.V.label v));
          FTG.iter_succ_e (fun e ->
              let src, dst = FTG.E.src e, FTG.E.dst e in
              if FTG.V.compare v src <> 0 then (
                Printf.eprintf "Corrupted edge src %s\n%!" __LOC__;
                exit(1)
              );
              Printf.eprintf "%s->%s;%!"
                             (Elb.to_string (FTG.E.label e))
                             (Vlb.to_string (FTG.V.label dst));
              ()
            ) gb v;
          Printf.eprintf "]\n%!";
        ) gb;
      ()

  end



let run g =
  let g = Both.create_and_add_vertex g {Vlb.name = "loul"} in
  let g = Both.create_and_add_vertex g {Vlb.name = "hello"} in
  let g = Both.create_and_add_vertex g {Vlb.name = "truc"} in
  let v1 = Both.V.create {Vlb.name = "src"} in
  let v2 = Both.V.create {Vlb.name = "dst"} in
  let e = Both.E.create v1 {Elb.name = "e1"} v2 in
  let g = Both.add_edge_e g e in
  Both.iter_and_print_vertex g;

  ()

let () =
  run (G.empty, FTG.empty);
  Printf.eprintf "PASSING!!!\n%!";
  ()
