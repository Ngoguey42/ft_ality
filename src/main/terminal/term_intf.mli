(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   term_intf.mli                                      :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/10 08:39:51 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/14 16:07:31 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module type Key_intf =
  sig
    include Shared_intf.Key_intf

    val of_char : char -> t
    val of_sequence : char list -> t
  end
