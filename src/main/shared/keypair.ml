(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   keypair.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/15 10:58:13 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/15 14:00:06 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make (Key : Shared_intf.Key_intf)
            (GameKey : Shared_intf.GameKey_intf)
       : (Shared_intf.KeyPair_intf
          with type key = Key.t
          with type gamekey = GameKey.t) =
  struct

    module Impl =
      struct
        type key = Key.t
        type gamekey = GameKey.t
        type t = gamekey * key

        let default = GameKey.default, Key.default

        let of_strings_err gamekey key =
          match GameKey.of_string_err gamekey, Key.of_string_err key with
          | Ok gk, Ok k -> Ok (gk, k)
          | Error msg, _ | _, Error msg -> Error msg

        let of_key key =
          GameKey.default, key

        let to_string (gk, k) =
          Printf.sprintf "%s:%s" (GameKey.to_string gk) (Key.to_string k)

        let compare_gamekey (gk, _) (gk', _) =
          GameKey.compare gk gk'

        let compare_key (_, k) (_, k') =
          Key.compare k k'

        let compare = compare_gamekey
      end
    include Impl

    module Set =
      struct
        include Avl.Make(Impl)

        let to_string kpset =
          fold (fun kp acc ->
              (Impl.to_string kp)::acc
            ) kpset []
          |> String.concat "; "
          |> Printf.sprintf "\027[33m<%s>\027[0m"
      end

    module BidirDict =
      struct
        type elt = t
        module GameKeySet =
          Avl.Make(struct
                      type t = elt
                      let compare = compare_gamekey
                    end)
        module KeySet =
          Avl.Make(struct
                      type t = elt
                      let compare = compare_key
                    end)

        type t = {
            kp_of_k : KeySet.t
          ; kp_of_gk : GameKeySet.t
          }

        let empty =
          {kp_of_k = KeySet.empty; kp_of_gk = GameKeySet.empty}

        let add_err {kp_of_k; kp_of_gk} kp =
          match GameKeySet.mem kp kp_of_gk, KeySet.mem kp kp_of_k with
          | true, true ->
             to_string kp
             |> Printf.sprintf ("[GameKey_container.add_err] "
                                ^^ "%s both keys already bound")
             |> (fun v -> Error v)
          | true, false ->
             to_string kp
             |> Printf.sprintf ("[GameKey_container.add_err] "
                                ^^ "%s gamekey already bound")
             |> (fun v -> Error v)
          | false, true ->
             to_string kp
             |> Printf.sprintf ("[GameKey_container.add_err] "
                                ^^ "%s key already bound")
             |> (fun v -> Error v)
          | false, false ->
             let kp_of_k = KeySet.add kp kp_of_k in
             let kp_of_gk = GameKeySet.add kp kp_of_gk in
             Ok {kp_of_k; kp_of_gk}

        let keypair_of_gamekey {kp_of_gk} gamekey =
          GameKeySet.binary_find
            (fun (gamekey', _) -> GameKey.compare gamekey gamekey') kp_of_gk

        let keypair_of_key {kp_of_k} key =
          KeySet.binary_find
            (fun (_, key') -> Key.compare key key') kp_of_k
      end

  end
