(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/10 11:51:10 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/11 18:07:50 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module rec D : (Shared_intf.Display_intf
                with type key = Key.t
                with type vertex = G.V.t
                with type edge = G.E.t) = Display.Make(Key)(G)(A)
   and A : (Shared_intf.Algo_intf
            with type key = Key.t) = Algo.Make(Key)(G)(D)
   and G : (Shared_intf.Graph_intf
            with type key = Key.t) = Graph_impl.Make(Key)

let () =
  D.run ()
