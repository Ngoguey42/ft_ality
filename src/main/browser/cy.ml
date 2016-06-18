(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   cy.ml                                              :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/18 09:07:33 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/18 15:01:49 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

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

    let (~|) = Js.string

    (* module Kwarg = *)
    (*   struct *)

    (*     class type c = *)
    (*       object *)
    (*         method container : Dom_html.element Js.t Js.readonly_prop *)
    (*       end *)

    (*     let create : Dom_html.element Js.t -> c Js.t = fun elt -> *)
    (*       object%js (self) *)
    (*         val container = elt *)
    (*       end *)

    (*   end *)

    class type c =
      object
        method width : int Js.meth
        method add : Js.Unsafe.any Js.t -> unit Js.meth
      end

    type t = c Js.t
    type vertex = Graph.V.t
    type edge = Graph.E.t
    type algo = Algo.t

    (* module StrSet = Avl.Make(struct *)
    (*                           type t = string *)
    (*                           let compare = compare *)
    (*                         end) *)

    (* let req_fields = ["width"] *)

    (* let validate_fields_err elt = *)
    (*   Js.object_keys elt *)
    (*   |> Js.to_array *)
    (*   |> Array.fold_left (fun acc k -> *)
    (*          if StrSet.mem k acc *)
    (*          then StrSet.remove k acc *)
    (*          else acc *)
    (*        ) (StrSet.of_list req_fields) *)
    (*   |> (fun set -> *)
    (*     if StrSet.is_empty set *)
    (*     then Ok elt *)
    (*     else Error "missing fields in elt") *)
    let log msg =
      ignore (Js.Unsafe.fun_call (Js.Unsafe.js_expr "console.log")
                                 [| Js.Unsafe.inject msg |])

    module DomElement =
      struct
        (* let of_dom_element_err elt = *)

        let of_eltid_err eltid =
          match Dom_html.getElementById eltid with
          | exception _ ->
             Error (Printf.sprintf "Could not retreive `%s` in DOM" eltid)
          | elt -> Ok elt
      end
    (* cytoscape({ *)

    (* container: document.getElementById('cy'), *)

    (* elements: [ *)
    (*     {group: 'nodes', data: {id: 'n1'}}, *)
    (*     {group: 'nodes', data: {id: 'n2'}}, *)
    (*     {group: 'nodes', data: {id: 'n3'}}, *)
    (*   ], *)

    (*}); *)

    module Conf =
      struct
        let order orig =
          object%js (self)
            val name = ~|"breadthfirst"
            val fit = Js.bool true
            val padding = 30
            val avoidOverlap = Js.bool true
            val directed = Js.bool true
            (* val circle = Js.bool true *)
            val spacingFactor = 0.5
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
          end

        let nodes_css =
          let obj =
            object%js
              val shape = ~|"octagon"
              (* val width = ~|"mapData(65, 40, 80, 20, 60)" *)
              (* val width = ~|"250" *)
              (* val height = ~|"100" *)
              val content = ~|"data(id)"
              (* val text-valign = ~|"center", *)
              (* val text-outline-width = 2, *)
              (* val text-outline-color = ~|"data(faveColor)", *)
              (* val background-color = ~|"data(faveColor)", *)
              val color = ~|"#fff"
            end
          in
          Js.Unsafe.set obj ~|"text-valign" ~|"center";
          (* Js.Unsafe.set obj ~|"font-size" ~|"120px"; *)
          Js.Unsafe.set obj ~|"text-wrap" ~|"wrap";
          (* Js.Unsafe.set obj ~|"text-max-width" ~|"125"; *)
          Js.Unsafe.set obj ~|"text-outline-width" 2;
          Js.Unsafe.set obj ~|"text-outline-color" ~|"#000";
          Js.Unsafe.set obj ~|"background-color" ~|"#F5A45D";
          obj

        (* cytoscape.stylesheet().selector('node').css({}) *)
        let style cy =

          (* log "test"; *)
          (* Ftlog.outnl "TEST TA MERE LA PUTE"; *)
          (* log (cy##stylesheet); *)
          (* log nodes_css; *)
          let obj = ((cy##stylesheet)##selector (~|"node"))
                      ##css nodes_css
          in
          log obj;
          obj
          (* |> ignore; *)
          (* Ftlog.outnl "TEST TA MERE LA PUTE2" *)

      end

    let create_err algodat =
      let jarr = new%js Js.array_empty in
      let insert_vertex v () =
        let obj : Js.Unsafe.any Js.t =
          object%js (self)
            val group = Js.string "nodes"
            val data =
              object%js (self)
                val id = Graph.V.label v
                         |> Graph.Vlabel.to_string ~color:false
                         |> Js.string
              end
          end
          |> Js.Unsafe.coerce
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
        (* Ftlog.lvl 0; *)
        (* Ftlog.outnl "===>'%s' '%s' '%s'" *)
        (*             (jstr_of_e e |> Js.to_string) *)
        (*             (Graph.E.src e |> jstr_of_v |> Js.to_string) *)
        (*             (Graph.E.dst e |> jstr_of_v |> Js.to_string) *)
        (*             ; *)
        let obj : Js.Unsafe.any Js.t =
          let src = Graph.E.src e |> str_of_v in
          let dst = Graph.E.dst e |> str_of_v in
          let edge = src ^ dst in
          object%js (self)
            val group = Js.string "edges"
            val data =
              object%js (self)
                val id = ~|edge
                val source = ~|src
                val target = ~|dst
              end
          end
          |> Js.Unsafe.coerce
        in
        jarr##push obj
        |> ignore;
        ()
      in
      Algo.fold_vertex insert_vertex algodat ();
      Algo.fold_edge insert_edge algodat ();
      match DomElement.of_eltid_err "cy" with
      | Error msg -> Error msg
      | Ok elt ->
         let c = Js.Unsafe.global##.cytoscape in
         (* match new%js c (object%js end) with *)
         (* | exception _ -> *)
         (*    Error "Could not construct `cycape` instance" *)
         (* | dummy -> *)
            let kwarg =
              object%js (self)
                val container = elt
                val elements = jarr
                val layout = Conf.order (Algo.origin_vertex algodat)
                val style = Conf.style c
              end
            in
            match new%js c kwarg with
            | exception _ ->
               Error "Could not construct `cytoscape` instance"
            | inst ->
               Ok inst

    (* let new_vertex v cy = *)
    (*   let id = Graph.V.label v |> Graph.Vlabel.to_string ~color:false in *)
    (*   Ftlog.lvl 2; *)
    (*   Ftlog.outnl "Cy.new_vertex(%s)" id; *)
    (*   let kwarg : Js.Unsafe.any Js.t = *)
    (*     object%js (self) *)
    (*       val group = Js.string "nodes" *)
    (*       val data = object%js (self) *)
    (*                    val id = Js.string id *)
    (*                  end *)
    (*     end *)
    (*     |> Js.Unsafe.coerce *)
    (*   in *)
    (*   log kwarg; *)
    (*   (\* Printf.eprintf "%d\n%!" ; *\) *)
    (*   (\* let cy' : c Js.t = cy in *\) *)
    (*   cy##add kwarg; *)
    (*   cy *)

    let new_edge v cy =
      Ftlog.lvl 2;
      Ftlog.outnl "Cy.new_edge()";
      cy

  end
