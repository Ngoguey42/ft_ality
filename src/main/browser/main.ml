
let truc = 42



let log s =
  ignore(
      Js.Unsafe.fun_call (Js.Unsafe.js_expr "console.log") [| Js.Unsafe.inject s |]
    )



let work () =
  let (~|) = Js.Unsafe.obj in
  let (@) k v = (k, Js.Unsafe.inject v) in

  let node i n w fc fs =
    ~| [| "data" @ ~| [| "id" @ i
                       ; "name" @ n
                       ; "weight" @ w
                       ; "faveColor" @ fc
                       ; "faveShape" @ fs
                      |] |]
  in
  let edge s t fc s =
    ~| [| "data" @ ~| [| "source" @ s
                       ; "target" @ t
                       ; "faveColor" @ fc
                       ; "strength" @ s
                      |] |]
  in
  let _ =
    ~| [| "test" @ "salut"
        ; "layout" @
            ~| [|
                "name" @ "cose"
              ; "padding" @ 10
              |]
        ; "elements" @
            ~| [|
                "nodes" @ ~| [| node "j" "Jerry" 65 "#6FB1FC" "triangle"
                              ; node "e" "Elaine" 45 "#EDA1ED" "ellipse"
                              ; node "k" "Kramer" 75 "#86B342" "octagon"
                              ; node "g" "George" 70 "#F5A45D" "rectangle"
                             |]
              ; "edges" @ ~| [| edge "j" "e" "#6FB1FC" 90
                              ; edge "j" "k" "#6FB1FC" 70
                              ; edge "j" "g" "#6FB1FC" 80
                              ; edge "e" "j" "#EDA1ED" 95
                              ; edge "e" "k" "#EDA1ED" 60
                              ; edge "k" "j" "#86B342" 100
                              ; edge "k" "e" "#86B342" 100
                              ; edge "k" "g" "#86B342" 100
                              ; edge "g" "j" "#F5A45D" 90
                             |]
              |]
       |]
  in
  ()
(* let elt = *)


let () =
  log "salut le world";
  Printf.printf "Test hello LOOL\n%!";
  ()
  (* Printf.eprintf "Hello World browser\n%!"; *)
