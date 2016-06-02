

module rec Display : (Shared_intf.Display_intf
                      with type key = Algo.Key.t) = Make_display.Make_display(Algo)
   and Algo : Shared_intf.Algo_intf = Make_algo.Make_algo(Display)







module type Foo_intf =
  sig
    type t
    val a : unit -> unit
  end

module type Bar_intf =
  sig
    type t_proxy
    val b : t_proxy -> unit
  end

module type Make_foo_intf =
  functor (Bar : Bar_intf) ->
  Foo_intf

module type Make_bar_intf =
  functor (Foo : Foo_intf) ->
  Bar_intf

module Make_foo =
  functor (Bar : Bar_intf) ->
  struct
    type t = {
        abstract_field : bool
      }
    let a () =
      Bar.b {abstract_field = true};
      ()
  end

module Make_bar =
  functor (Foo : Foo_intf) ->
  struct
  end

module rec Foo : Foo_intf = Make_foo(Bar)
   and Bar : Bar_intf = Make_bar(Foo)




let truc = 42

let () =
  Printf.eprintf "Hello World\n%!";

  Printf.eprintf "\027[33m%s\027[0m\n%!" __LOC__;
  let dat = Algo.create stdin in
  Printf.eprintf "\027[33m%s\027[0m\n%!" __LOC__;

  Foo.a ();
  (* Bar.foo "test" *)
