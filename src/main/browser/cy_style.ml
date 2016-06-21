(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   cy_style.ml                                        :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/21 12:05:24 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/21 12:28:41 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let (~|) = Js.string
let (~&) = Js.bool
let entry k v obj =
  Js.Unsafe.set obj k v;
  obj

let spell_anim_durf = 0.9
let spell_anim_durstr = Printf.sprintf "%fs" spell_anim_durf

let nodes_css =
  object%js
    (* val width = ~|"mapData(150, 140, 80, 20, 60)" *)
    (* val text-valign = ~|"center", *)
    (* val text-outline-width = 2, *)
    (* val text-outline-color = ~|"data(faveColor)", *)
    (* val background-color = ~|"data(faveColor)", *)
    val width = ~|"110"
    val height = ~|"60"
    val shape = ~|"ellipse"
    val label = ~|"data(name)"
    val color = ~|"#fff"
  end
  (* |> entry ~|"text-max-width" ~|"125"; *)
  (* |> entry ~|"background-fit" ~|"cover" *)
	|> entry ~|"text-valign" ~|"center"
  |> entry ~|"text-halign" ~|"top"
  |> entry ~|"text-wrap" ~|"wrap"
  |> entry ~|"text-outline-width" 2
  |> entry ~|"text-outline-color" ~|"#000"
  |> entry ~|"background-color" ~|"#F5A45D"
  |> entry ~|"font-size" ~|"12px"


let focus_css =
  object%js
  end
  |> entry ~|"background-color" ~|"#FF1122"

let spellcast_css =
  object%js
  end
  |> entry ~|"background-color" ~|"#61bffc"
  |> entry ~|"transition-property" ~|"background-color, target-arrow-color"
  |> entry ~|"transition-duration" ~|spell_anim_durstr

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
  (* |> entry ~|"text-max-width" ~|"125"; *)
	(* |> entry ~|"text-valign" ~|"center" *)
  (* |> entry ~|"text-halign" ~|"top" *)
  (* |> entry ~|"text-wrap" ~|"wrap" *)
  (* |> entry ~|"background-color" ~|"#F5A45D" *)
  |> entry ~|"text-outline-width" 2
  |> entry ~|"text-outline-color" ~|"#888"
  |> entry ~|"font-size" ~|"11px"
  |> entry ~|"edge-text-rotation" ~|"autorotate"
  |> entry ~|"curve-style" ~|"unbundled-bezier"

let of_stylesheet stylesheet =
  stylesheet
  |> (fun i -> i##selector ~|"node")
  |> (fun i -> i##css nodes_css)
  |> (fun i -> i##selector ~|"edge")
  |> (fun i -> i##css edges_css)
  |> (fun i -> i##selector ~|".focus")
  |> (fun i -> i##css focus_css)
  |> (fun i -> i##selector ~|".spellcast")
  |> (fun i -> i##css spellcast_css)
