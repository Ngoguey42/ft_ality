(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   browser_intf.mli                                   :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/16 09:58:01 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/20 08:11:00 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module type Key_intf =
  sig
    include Shared_intf.Key_intf

    val of_dom_event : Dom_html.keyboardEvent Js.t -> t
  end

module type Cy_intf =
  sig
    type t
    type vertex
    type edge
    type algo

    val create_err : algo -> (t, string) result
    val destroy : t -> unit
    val update_focus_err : t -> algo -> (t, string) result
  end
