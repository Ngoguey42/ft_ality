(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   cy.ml                                              :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/18 09:07:33 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/20 09:21:42 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let (~|) = Js.string
let (~&) = Js.bool
let log msg =
  Js.Unsafe.fun_call (Js.Unsafe.js_expr "console.log")
                     [|Js.Unsafe.inject msg|]
  |> ignore


module Make (Graph : Shared_intf.Graph_impl_intf)
            (Algo : Shared_intf.Algo_intf
             (* with type key = Key.t *)
             (* with type keypair = KeyPair.t *)
             (* with type kpset = KeyPair.Set.t *)
             with type vertex = Graph.V.t
             with type edge = Graph.E.t)

       : (Browser_intf.Cy_intf
          with type vertex = Graph.V.t
          with type edge = Graph.E.t
          with type algo = Algo.t) =
  struct

    type vertex = Graph.V.t
    type edge = Graph.E.t
    type algo = Algo.t

    module Error =
      struct
        let to_string msg e =
          e##toString
          |> Js.to_string
          |> Printf.sprintf "%s: (%s)" msg
          |> (fun s -> Error s)

      end

    module JsInstance =
      struct
        module Node =
          struct
            class type c =
              object

                (* Declared as `Js.Optdef.t` to detect `cy##getElementById()`
                 * return value correctness *)
                method id : int Js.Optdef.t Js.meth
                method addClass : Js.js_string Js.t -> unit Js.t Js.meth
                method removeClass : Js.js_string Js.t -> unit Js.t Js.meth

              end
          end

        class type c =
          object
            method width : int Js.meth
            method destroy : unit Js.meth
            method container : Dom_html.element Js.t Js.meth

            (* Always return an object, use `Node##id` to check correctness *)
            method getElementById : int -> Node.c Js.t Js.meth
          end

        let node_of_vertex_err cy vert =
          let focusid = Graph.V.uid vert in
          let node = cy##getElementById focusid in
          match node##id |> Js.Optdef.to_option with
          | None ->
             Error (Graph.V.label vert
                    |> Graph.Vlabel.to_string
                    |> Printf.sprintf "Could not retrieve node `%s` in dom")
          | Some _ -> Ok node

        let focus_node_of_algodat_err cy algodat =
          node_of_vertex_err cy (Algo.focus algodat)

      end

    module Global =
      struct
        class type c =
          object
            method stylesheet : < .. > Js.t Js.meth
          end

        let new_instance_err kwarg =
          let c : (< .. > Js.t -> JsInstance.c Js.t) Js.constr =
            Js.Unsafe.global##.cytoscape
          in
          match new%js c kwarg with
          | exception Js.Error e ->
             Error.to_string "Could not instanciate `cytoscape`" e
          | inst ->
             Ok inst

        let stylesheet () =
          let c : c Js.t = Js.Unsafe.global##.cytoscape in
          c##stylesheet

      end

    type t = {
        cy : JsInstance.c Js.t
      ; focus : JsInstance.Node.c Js.t
      }


    module DomElement =
      struct
        let of_eltid_err eltid =
          match Dom_html.getElementById eltid with
          | exception Js.Error e ->
             Error.to_string "Could not retreive `cy` in DOM" e
          | elt -> Ok elt
      end

    module Field =
      struct
        let entry k v obj =
          Js.Unsafe.set obj k v;
          obj

        let order orig =
          object%js (self)
            (* val circle = ~&true *)
            (* val roots = *)
            (*   object%js (self) *)
            (*     val data = *)
            (*       object%js (self) *)
            (*         val id  = Graph.V.label orig *)
            (*                   |> Graph.Vlabel.to_string ~color:false *)
            (*                   |> Js.string *)
            (*       end *)
            (*   end *)
            (* val maximalAdjustments = 50 *)
            val name = ~|"breadthfirst"
            val fit = ~&true
            val padding = 30
            val avoidOverlap = ~&true
            val directed = ~&true
            val spacingFactor = 0.0
          end

        let nodes_css =
          object%js
            (* val width = ~|"mapData(150, 140, 80, 20, 60)" *)
            val width = ~|"110"
            val height = ~|"60"
            (* val text-valign = ~|"center", *)
            (* val text-outline-width = 2, *)
            (* val text-outline-color = ~|"data(faveColor)", *)
            (* val background-color = ~|"data(faveColor)", *)
            val shape = ~|"ellipse"
            val label = ~|"data(name)"
            val color = ~|"#fff"
          end
          (* (\* |> entry ~|"text-max-width" ~|"125"; *\) *)
	        |> entry ~|"text-valign" ~|"center"
          |> entry ~|"text-halign" ~|"top"
          |> entry ~|"text-wrap" ~|"wrap"
          |> entry ~|"text-outline-width" 2
          |> entry ~|"text-outline-color" ~|"#000"
          |> entry ~|"background-color" ~|"#F5A45D"
          |> entry ~|"font-size" ~|"12px"
          (* |> entry ~|"background-fit" ~|"cover" *)

        let focus_css =
          object%js
          end
          |> entry ~|"background-color" ~|"#FF1122"

        let spellcast_css =
          object%js
          end
          |> entry ~|"background-color" ~|"#61bffc"
          (* |> entry ~|"line-color" ~|"#61bffc" *)
          (* |> entry ~|"target-arrow-color" ~|"#61bffc" *)
          |> entry ~|"transition-property"
                   (* ~|"background-color, line-color, target-arrow-color" *)
                   ~|"background-color, target-arrow-color"
          |> entry ~|"transition-duration" ~|"0.5s"

        let edges_css =
          object%js
            (* val width = ~|"mapData(65, 40, 80, 20, 60)" *)
            (* val width = ~|"250" *)
            (* val height = ~|"100" *)
            (* val text-valign = ~|"center", *)
            (* val text-outline-width = 2, *)
            (* val text-outline-color = ~|"data(faveColor)", *)
            (* val background-color = ~|"data(faveColor)", *)
            (* val shape = ~|"octagon" *)
            val label = ~|"data(name)"
            val color = ~|"#fff"
          end
          (* (\* |> entry ~|"text-max-width" ~|"125"; *\) *)
	        (* |> entry ~|"text-valign" ~|"center" *)
          (* |> entry ~|"text-halign" ~|"top" *)
          (* |> entry ~|"text-wrap" ~|"wrap" *)
          |> entry ~|"text-outline-width" 2
          |> entry ~|"text-outline-color" ~|"#888"
          (* |> entry ~|"background-color" ~|"#F5A45D" *)
          |> entry ~|"font-size" ~|"11px"
          |> entry ~|"edge-text-rotation" ~|"autorotate"
          (* |> entry ~|"curve-style" ~|"bezier" *)

        let style () =
          Global.stylesheet ()
          |> (fun i -> i##selector ~|"node")
          |> (fun i -> i##css nodes_css)
          |> (fun i -> i##selector ~|"edge")
          |> (fun i -> i##css edges_css)
          |> (fun i -> i##selector ~|".focus")
          |> (fun i -> i##css focus_css)
          |> (fun i -> i##selector ~|".spellcast")
          |> (fun i -> i##css spellcast_css)

        let node id name =
          object%js (self)
            (* val selected = ~&false *)
            (* val locked = ~&true (\* Do not lock, auto placement fails *\) *)
            val group = ~|"nodes"
            val selectable = ~&true
            val grabbable = ~&false
            val data =
              object%js (self)
                val id = id
                val name = name
              end
          end

        let edge id name srcid dstid =
          object%js (self)
            val group = ~| "edges"
            val data =
              object%js (self)
                val id = id
                val name = name
                val source = srcid
                val target = dstid
              end
          end

        let constructor_kwarg domelt algodat elements =
          object%js (self)
             val container = domelt
             val elements = elements
             val layout = order (Algo.origin_vertex algodat)
             val style = style ()
             val userZoomingEnabled = ~& false
             val userPanningEnabled = ~& false
             val boxSelectionEnabled = ~& false
           end
      end

    module Elements =
      struct
        let of_algo algodat =
          let jarr = new%js Js.array_empty in

          let insert_vertex v () =
            let obj : Js.Unsafe.any Js.t =
              let name =
                Graph.V.label v
                |> Graph.Vlabel.to_string ~color:false
                |> Js.string
              in
              let id = Graph.V.uid v in
              Field.node id name |> Js.Unsafe.coerce
            in
            jarr##push obj
            |> ignore
          in

          let str_of_e e =
            Graph.E.label e
            |> Graph.Elabel.to_string ~color:false
          in
          let insert_edge e () =
            let obj : Js.Unsafe.any Js.t =
              let src = Graph.E.src e |> Graph.V.uid in
              let dst = Graph.E.dst e |> Graph.V.uid in
              let id = (src lsl 16) + dst in
              let name = str_of_e e in
              Field.edge id ~|name src dst |> Js.Unsafe.coerce
            in
            jarr##push obj
            |> ignore
          in
          Algo.fold_vertex insert_vertex algodat ();
          Algo.fold_edge insert_edge algodat ();
          jarr

      end

    let instance_of_algodat_err algodat =
      Fterr.try_2expr
        (DomElement.of_eltid_err "cy")
        (fun domelt ->
          let kwarg =
            Field.constructor_kwarg domelt algodat (Elements.of_algo algodat)
          in
          Global.new_instance_err kwarg)

    let create_err algodat =
      Fterr.try_3expr
        (instance_of_algodat_err algodat)
        (fun cy ->
          JsInstance.focus_node_of_algodat_err cy algodat)
        (fun cy focus ->
          focus##addClass ~|"focus" |> ignore;
          Ok {cy; focus}
        )

    let destroy {cy} =
      cy##destroy

    let update_focus_err algodat {cy; focus} =
      focus##removeClass ~|"focus" |> ignore;
      Fterr.try_2expr
        (JsInstance.focus_node_of_algodat_err cy algodat)
        (fun focus -> (* shadowing focus *)
          focus##addClass ~|"focus" |> ignore;
          Ok {cy; focus})

    let animate_node_err {cy} vert =
      Ftlog.outnllvl 4 "Cy.animate_node_err()";
      match JsInstance.node_of_vertex_err cy vert with
      | Error msg -> Error msg
      | Ok node -> node##addClass ~|"spellcast" |> ignore;
                   Lwt.bind
                     (Lwt_js.sleep 0.6)
                     (fun _ ->
                       node##removeClass ~|"spellcast" |> ignore;
                       Lwt.return_unit)
                   |> ignore;
                   Ok ()
  end
