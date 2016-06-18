(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   browser_intf.mli                                   :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/16 09:58:01 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/18 12:39:36 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module type Key_intf =
  sig
    include Shared_intf.Key_intf

    val of_char : char -> t
    val of_sequence : char list -> t
  end

module type Cy_intf =
  sig
    type t
    type vertex
    type edge
    type algo

    (* val of_eltid_err : string -> (t, string) result *)
    (* val new_vertex : vertex -> t -> t *)
           (* val new_edge : edge -> t -> t *)
    val create_err : algo -> (t, string) result
  end
