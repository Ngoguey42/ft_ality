
let truc = 42
let log s =
  Js.Unsafe.fun_call (Js.Unsafe.js_expr "console.log") [| Js.Unsafe.inject s |]

let () =
  log "salut le world";
  Printf.eprintf "Hello World browser\n%!";
  Bar.foo "test browser"
