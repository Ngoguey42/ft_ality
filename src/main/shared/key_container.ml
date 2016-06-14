(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   key_container.ml                                   :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/14 14:30:12 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/14 14:33:36 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make (Key : Shared_intf.Key_intf)
       : (Shared_intf.Key_container_intf
          with type key = Key.t) =
  struct
    type key = Key.t

    module Set =
      struct
        include Avl.Make(Key)

        let to_string kset =
          fold (fun e acc ->
              (Key.to_string e)::acc
            ) kset []
          |> String.concat "; "
          |> Printf.sprintf "\027[33m<%s>\027[0m"
      end

    module BidirDict =
      struct
        module StrMap =
          Ftmap.Make(struct
                      type t = string
                      let compare = compare
                    end)
        module KeyMap = Ftmap.Make(Key)

        type t = {
            k_to_a : string KeyMap.t
          ; a_to_k : Key.t StrMap.t
          }

        let empty =
          {k_to_a = KeyMap.empty; a_to_k = StrMap.empty}

        let add {k_to_a; a_to_k} action k =
          let k_to_a = KeyMap.add k action k_to_a in
          let a_to_k = StrMap.add action k a_to_k in
          {k_to_a; a_to_k}

        let key_of_action {a_to_k} action =
          StrMap.find_opt action a_to_k

        let action_of_key {k_to_a} key =
          KeyMap.find_opt key k_to_a
      end

  end
