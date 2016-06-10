
module type Foo_intf =
  sig
    type t
    val a : unit -> unit
  end

module type Bar_intf =
  sig
    type foo
    val b : foo -> unit
  end

module type Make_foo_intf =
  functor (Bar : Bar_intf) ->
  Foo_intf

module type Make_bar_intf =
  functor (Foo : Foo_intf) ->
  Bar_intf
  with type foo = Foo.t


(* module Make_foo : Make_foo_intf = *)
(*   functor (Bar : Bar_intf) -> *)
(*   struct *)

(*     type t = { *)
(*         abstract_field : bool *)
(*       } *)

(*     let a () = *)
(*       Bar.b {abstract_field = true} *)

(*   end *)

module GigaMake_foo =
  functor (Make_bar : Make_bar_intf) ->
  struct

    module rec Foo : Foo_intf =
      struct
        type t = {
            abstract_field : bool
          }

        module Bar = Make_bar(Foo)

        let a _ =
          Bar.b {abstract_field = true}

      end

    include Foo

  end

module Make_bar : Make_bar_intf =
  functor (Foo : Foo_intf) ->
  struct
    type foo = Foo.t

    let b _ =
      Printf.eprintf "worked\n%!";
      Foo.a ()

  end

module Foo = GigaMake_foo(Make_bar)

let () =
  Foo.a ()


(* module Make_foo = *)
(*   functor (Bar : Bar_intf) -> *)
(*   struct *)

(*     type t = { *)
(*         abstract_field : bool *)
(*       } *)

(*     module Impl = *)
(*       functor (Bar : Bar_intf with type foo = t) -> *)
(*       struct *)

(*       end *)

(*     include Impl(Bar) *)

(*   end *)

(* module Make_foo : Make_foo_intf = *)
(* module rec Wrap *)
(*            : *)
(*              sig *)
(*                module rec Foo : (Foo_intf) *)
(*                   and Bar : (Bar_intf *)
(*                              with type foo = Foo.t) *)
(*              end *)
(*   = *)
(*   struct *)

(* module rec Foo : Foo_intf = *)
(*   (functor (Bar : Bar_intf) -> *)
(*    struct *)
(*      type t = { *)
(*          abstract_field : bool *)
(*        } *)
(*      let a () = *)
(*        Bar.b {abstract_field = true}; *)
(*        () *)
(*    end)(Bar) *)

(*    and Bar : *)
(*          sig *)
(*            type foo = Foo.t *)
(*            val b : foo -> unit *)
(*          end with type foo = Foo.t *)
(*      = *)
(*      (functor (Foo : Foo_intf) -> *)
(*       struct *)
(*         type foo = Foo.t *)
(*         let b _ = *)
(*           Printf.eprintf "Super\n%!" *)
(*       end)(Foo) *)

  (* end *)

(* module type Make_bar_intf = *)
(*   functor (Foo : Foo_intf) -> *)
(*   sig *)
(*     include Bar_intf with type foo = Foo.t *)
(*   end *)



(* module Make_bar : Make_bar_intf = *)
(*   functor (Foo : Foo_intf) -> *)
(*   struct *)
(*     (\* module Foo_proxy = Foo *\) *)

(*     type foo = Foo.t *)
(*     let b _ = *)
(*       () *)
(*   end *)

(* module rec Foo : Foo_intf = Make_foo(Bar) *)
(*    and Bar : (Bar_intf with type foo = Foo.t) = Make_bar(Foo) *)

let () =
  Printf.eprintf "HW\n%!";
