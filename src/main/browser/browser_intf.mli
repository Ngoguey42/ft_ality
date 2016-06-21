(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   browser_intf.mli                                   :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/16 09:58:01 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/21 14:50:09 by ngoguey          ###   ########.fr       *)
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
    module G : Shared_intf.Graph_inst_intf
    module A : Shared_intf.Algo_intf

    val create_err : A.t -> (t, string) result
    val destroy : t -> unit
    val update_focus_err : A.t -> t -> (t, string) result
    val animate_node_err : t -> G.V.t -> (unit, string) result
  end
