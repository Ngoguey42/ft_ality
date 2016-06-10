
module type Display_intf =
  sig
    type algo
    type vertex
    val run : unit -> unit
    val declare_vertex : vertex -> unit
  end

module type Algo_intf =
  sig
    type t
    type vertex
    module Display : Display_intf
    val create : unit -> t
  end

module type Make_algo_intf =
  functor (Display : Display_intf) ->
  Algo_intf

module type Make_display_intf =
  functor (Algo : Algo_intf) ->
  Display_intf
  with type algo = Algo.t
  with type vertex = Algo.vertex


module type GigaMake_algo_intf =
  functor (Make_display : Make_display_intf) ->
  Algo_intf

module GigaMake_algo : GigaMake_algo_intf =
  functor (Make_display : Make_display_intf) ->
  struct

    module rec Algo : Algo_intf =
      struct
        type t = {
            abstract_field : bool
          }

        type vertex = {
            name : string
          }

        module Display = Make_display(Algo)

        let create _ =
          Printf.eprintf "Algo create\n%!";
          let v = {name = "v1"} in
          Display.declare_vertex v;
          {abstract_field = true}

      end

    include Algo

  end

module Make_display : Make_display_intf =
  functor (Algo : Algo_intf) ->
  struct
    type algo = Algo.t
    type vertex = Algo.vertex

    let declare_vertex v =
      Printf.eprintf "Display declare vertex\n%!";
      ()

    let run () =
      Printf.eprintf "Display run\n%!";
      let dat = Algo.create () in
      ()


  end

module Algo = GigaMake_algo(Make_display)

let () =
  Algo.Display.run ()
  (* Algo.a () *)


(* module Make_algo = *)
(*   functor (Display : Display_intf) -> *)
(*   struct *)

(*     type t = { *)
(*         abstract_field : bool *)
(*       } *)

(*     module Impl = *)
(*       functor (Display : Display_intf with type algo = t) -> *)
(*       struct *)

(*       end *)

(*     include Impl(Display) *)

(*   end *)

(* module Make_algo : Make_algo_intf = *)
(* module rec Wrap *)
(*            : *)
(*              sig *)
(*                module rec Algo : (Algo_intf) *)
(*                   and Display : (Display_intf *)
(*                              with type algo = Algo.t) *)
(*              end *)
(*   = *)
(*   struct *)

(* module rec Algo : Algo_intf = *)
(*   (functor (Display : Display_intf) -> *)
(*    struct *)
(*      type t = { *)
(*          abstract_field : bool *)
(*        } *)
(*      let a () = *)
(*        Display.b {abstract_field = true}; *)
(*        () *)
(*    end)(Display) *)

(*    and Display : *)
(*          sig *)
(*            type algo = Algo.t *)
(*            val b : algo -> unit *)
(*          end with type algo = Algo.t *)
(*      = *)
(*      (functor (Algo : Algo_intf) -> *)
(*       struct *)
(*         type algo = Algo.t *)
(*         let b _ = *)
(*           Printf.eprintf "Super\n%!" *)
(*       end)(Algo) *)

  (* end *)

(* module type Make_display_intf = *)
(*   functor (Algo : Algo_intf) -> *)
(*   sig *)
(*     include Display_intf with type algo = Algo.t *)
(*   end *)



(* module Make_display : Make_display_intf = *)
(*   functor (Algo : Algo_intf) -> *)
(*   struct *)
(*     (\* module Algo_proxy = Algo *\) *)

(*     type algo = Algo.t *)
(*     let b _ = *)
(*       () *)
(*   end *)

(* module rec Algo : Algo_intf = Make_algo(Display) *)
(*    and Display : (Display_intf with type algo = Algo.t) = Make_display(Algo) *)

let () =
  Printf.eprintf "HW\n%!";
