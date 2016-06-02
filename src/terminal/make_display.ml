(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   make_display.ml                                    :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/02 12:01:27 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/02 12:13:32 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make_display : Shared_intf.Make_display_intf =
  functor (Algo : Shared_intf.Algo_intf) ->
  struct

    type key = Algo.Key.t
    type vertex = Algo.Vertex.t

    let declare_key _ =
      Printf.eprintf "\027[33m%s\027[0m\n%!" __LOC__;
      ()
    let declare_vertex _ =
      Printf.eprintf "\027[33m%s\027[0m\n%!" __LOC__;
      ()
    let focus_vertex _ =
      Printf.eprintf "\027[33m%s\027[0m\n%!" __LOC__;
      ()

  end
