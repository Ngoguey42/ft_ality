(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   cy.ml                                              :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/18 09:07:33 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/21 15:11:51 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let (~|) = Js.string
let (~&) = Js.bool
let log msg =
  Js.Unsafe.fun_call (Js.Unsafe.js_expr "console.log")
                     [|Js.Unsafe.inject msg|]
  |> ignore

module Make (Graph : Shared_intf.Graph_inst_intf)
            (Algo : Shared_intf.Algo_intf
             with module G = Graph)
       : (Browser_intf.Cy_intf
          with module G = Graph
          with module A = Algo) =
  struct
    type t = {
        cy : Jsobj.cy Js.t
      ; focus : Jsobj.cynode Js.t
      }
    module G = Graph
    module A = Algo


    (* Internal *)

    module Error =
      struct
        let to_string msg e =
          e##toString
          |> Js.to_string
          |> Printf.sprintf "%s: (%s)" msg
          |> (fun s -> Error s)
      end

    module Global =
      struct
        (* `js_of_ocaml`'s `.js` script file must be included
         *   AFTER `cytoscape`'s `.js` file *)
        let v : 'a = Js.Unsafe.global##.cytoscape
        let global : Jsobj.cyglobal Js.t = v
        let ctor : ((< .. > Js.t as 'a) -> Jsobj.cy Js.t) Js.constr = v

        let construct_err kwarg =
          match new%js ctor kwarg with
          | exception Js.Error e ->
             Error.to_string "Could not instanciate `cytoscape`" e
          | inst ->
             Ok inst

        let new_stylesheet () =
          global##stylesheet
      end

    module Dom =
      struct
        let get_cy () =
          match Dom_html.getElementById "cy" with
          | exception Js.Error e ->
             Error.to_string "Could not retreive `cy` in DOM" e
          | elt -> Ok elt
      end

    module JsInstance =
      struct
        module Node =
          struct
            let create_unsafe_of_vertex v : Js.Unsafe.any Js.t =
              object%js (self)
                (* val selected = ~&false *)
                (* Do not lock, makes auto placement fail *)
                (* val locked = ~&true  *)
                val group = ~|"nodes"
                val selectable = ~&true
                val grabbable = ~&false
                val data =
                  object%js (self)
                    val id = Graph.V.uid v
                    val name = Graph.V.label v
                               |> Graph.Vlabel.to_string ~color:false
                               |> Js.string
                  end
              end
              |> Js.Unsafe.coerce
          end

        module Edge =
          struct
            let create_unsafe_of_edge e : Js.Unsafe.any Js.t =
              let src = Graph.E.src e |> Graph.V.uid in
              let dst = Graph.E.dst e |> Graph.V.uid in
              object%js (self)
                val group = ~| "edges"
                val data =
                  object%js (self)
                    val id = (src lsl 16) + dst
                    val name = ~|(Graph.E.label e
                                  |> Graph.Elabel.to_string ~color:false)
                    val source = src
                    val target = dst
                  end
              end
              |> Js.Unsafe.coerce
          end

        module Construction =
          struct
            let order =
              object%js (self)
                val name = ~|"breadthfirst"
                val fit = ~&true
                val padding = 30
                val avoidOverlap = ~&true
                val directed = ~&true
                val spacingFactor = 0.0
              end

            let elements algodat =
              let jarr = new%js Js.array_empty in
              Algo.fold_vertex (fun v () ->
                  jarr##push (Node.create_unsafe_of_vertex v)
                  |> ignore
                ) algodat ();
              Algo.fold_edge (fun e () ->
                  jarr##push (Edge.create_unsafe_of_edge e)
                  |> ignore
                ) algodat ();
              jarr

            let kwarg domelt algodat =
              object%js (self)
                val container = domelt
                val elements = elements algodat
                val layout = order
                val style = Cy_style.of_stylesheet (Global.new_stylesheet ())
                val userZoomingEnabled = ~& false
                val userPanningEnabled = ~& false
                val boxSelectionEnabled = ~& false
              end
          end

        let find_node cy vert =
          let focusid = Graph.V.uid vert in
          let node = cy##getElementById focusid in
          match node##id |> Js.Optdef.to_option with
          | None -> None
          | Some _ -> Some node

        let create_err algodat =
          Fterr.try_2expr
            (Dom.get_cy ())
            (fun domelt ->
              Construction.kwarg domelt algodat
              |> Global.construct_err)
      end


    (* Exposed  *)

    let create_err algodat =
      Fterr.try_3expr
        (JsInstance.create_err algodat)
        (fun cy ->
          match JsInstance.find_node cy (Algo.focus algodat) with
          | None -> Error "[Cy.create_err] unknown vertex id"
          | Some n -> Ok n)
        (fun cy focus ->
          focus##addClass ~|"focus" |> ignore;
          Ok {cy; focus}
        )

    let destroy {cy} =
      cy##destroy

    let update_focus_err algodat {cy; focus} =
      focus##removeClass ~|"focus" |> ignore;
      Fterr.try_2expr
        (match JsInstance.find_node cy (Algo.focus algodat) with
         | None -> Error "[Cy.update_focus_err] unknown vertex id"
         | Some n -> Ok n)
        (fun focus -> (* shadowing focus *)
          focus##addClass ~|"focus" |> ignore;
          Ok {cy; focus})

    let animate_node_err {cy} vert =
      Ftlog.outnllvl 4 "Cy.animate_node_err()";
      match JsInstance.find_node cy vert with
      | None -> Error "[Cy.animate_node_err] unknown vertex id"
      | Some n ->
         n##addClass ~|"spellcast" |> ignore;
         Lwt.bind
           (Lwt_js.sleep (Cy_style.spell_anim_durf +. 0.1))
           (fun _ ->
             n##removeClass ~|"spellcast" |> ignore;
             Lwt.return_unit)
         |> ignore;
         Ok ()
  end
