
module rec D : (Shared_intf.Display_intf
               with type key = Key.t) = Display.Make(A)
   and A : (Shared_intf.Algo_intf
           with type key = Key.t) = Algo.Make(Key)(D)


(* module type Foo_intf = *)
(*   sig *)
(*     type t *)
(*     val a : unit -> unit *)
(*   end *)

(* module type Bar_intf = *)
(*   sig *)
(*     type foo *)
(*     val b : foo -> unit *)
(*   end *)

(* module type Make_foo_intf = *)
(*   functor (Bar : Bar_intf) -> *)
(*   sig *)
(*     (\* include Foo_intf *\) *)
(*   end *)

(* module Make_foo : Make_foo_intf = *)
(*   functor (Bar : Bar_intf) -> *)
(*   struct *)
(*     type t = { *)
(*         abstract_field : bool *)
(*       } *)
(*     let a () = *)
(*       let v : Bar.foo in *)
(*       Bar.b v; *)
(*       () *)
(*   end *)

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
  D.run ();
  ()
