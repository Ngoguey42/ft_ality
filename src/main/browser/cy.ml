(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   cy.ml                                              :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/18 09:07:33 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/19 08:38:31 by ngoguey          ###   ########.fr       *)
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
        class type c =
          object
            (* method width : int Js.meth *)
            (* method add : Js.Unsafe.t Js.t -> unit Js.meth *)
          end
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

    type t = JsInstance.c Js.t


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
          let entry k v obj =
            Js.Unsafe.set obj k v;
            obj
          in
          object%js
            (* val width = ~|"mapData(65, 40, 80, 20, 60)" *)
            (* val width = ~|"250" *)
            (* val height = ~|"100" *)
            (* val text-valign = ~|"center", *)
            (* val text-outline-width = 2, *)
            (* val text-outline-color = ~|"data(faveColor)", *)
            (* val background-color = ~|"data(faveColor)", *)
            val shape = ~|"octagon"
            val content = ~|"data(id)"
            val color = ~|"#fff"
          end
          (* (\* |> entry ~|"text-max-width" ~|"125"; *\) *)
	        |> entry ~|"text-valign" ~|"center"
          |> entry ~|"text-wrap" ~|"wrap"
          |> entry ~|"text-outline-width" 2
          |> entry ~|"text-outline-color" ~|"#000"
          |> entry ~|"background-color" ~|"#F5A45D"
          |> entry ~|"font-size" ~|"12px"

        let style () =
          Global.stylesheet ()
          |> (fun i -> i##selector ~|"node")
          |> (fun i -> i##css nodes_css)

        let node id =
          object%js (self)
            (* val selected = ~&false *)
            (* val locked = ~&true (\* Do not lock, auto placement fails *\) *)
            val group = ~|"nodes"
            val selectable = ~&true
            val grabbable = ~&false
            val data =
              object%js (self)
                val id = id
              end
          end

        let edge id srcid dstid =
          object%js (self)
            val group = ~| "edges"
            val data =
              object%js (self)
                val id = id
                val source = srcid
                val target = dstid
              end
          end

      end

    module Elements =
      struct
        let of_algo algodat =
          let jarr = new%js Js.array_empty in

          let insert_vertex v () =
            let obj : Js.Unsafe.any Js.t =
              let id =
                Graph.V.label v
                |> Graph.Vlabel.to_string ~color:false
                |> Js.string
              in
              Field.node id |> Js.Unsafe.coerce
            in
            jarr##push obj
            |> ignore
          in

          let str_of_v v =
            Graph.V.label v
            |> Graph.Vlabel.to_string ~color:false
          in
          let str_of_e e =
            Graph.E.label e
            |> Graph.Elabel.to_string
          in
          let insert_edge e () =
            let obj : Js.Unsafe.any Js.t =
              let src = Graph.E.src e |> str_of_v in
              let dst = Graph.E.dst e |> str_of_v in
              let edge = src ^ dst in
              Field.edge ~|edge ~|src ~|dst |> Js.Unsafe.coerce
            in
            jarr##push obj
            |> ignore
          in
          Algo.fold_vertex insert_vertex algodat ();
          Algo.fold_edge insert_edge algodat ();
          jarr

      end

    let create_err algodat =
      match DomElement.of_eltid_err "cy" with
      | Error msg ->
         Error msg
      | Ok elt ->
         object%js (self)
           val container = elt
           val elements = Elements.of_algo algodat
           val layout = Field.order (Algo.origin_vertex algodat)
           val style = Field.style ()
         end
         |> Global.new_instance_err
  end
