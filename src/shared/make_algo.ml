(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   make_algo.ml                                       :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/02 11:50:40 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/02 12:31:34 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make_algo : Shared_intf.Make_algo_intf =
  functor (Display : Shared_intf.Display_intf) ->
  struct
    type t = {
        tamere : int
      }

    module Key : Shared_intf.Key_intf =
      struct
        (* type t = Display.key *)
        type t = {
            name : string
          }
      end

    module Vertex =
      struct
        type t = {
            id : int
          }
      end

    (* module Disp : (Shared_intf.Display_intf *)
    (*                with type key = Key.t) = Display *)

    let create chan =
      Printf.eprintf "\027[33m%s\027[0m\n%!" __LOC__;

      (* let k = {name = "space"} in *)
      (* Display.declare_key {Key.name = "space"}; *)
      {tamere = 42}

    let on_key_pressed k env =
      Printf.eprintf "\027[33m%s\027[0m\n%!" __LOC__;
      env

  end
