(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   keypair.ml                                         :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: ngoguey <ngoguey@student.42.fr>            +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2016/06/15 10:58:13 by ngoguey           #+#    #+#             *)
(*   Updated: 2016/06/15 10:59:09 by ngoguey          ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Make (Key : Shared_intf.Key_intf)
            (GameKey : Shared_intf.GameKey_intf
             with type key = Key.t)
       : (Shared_intf.GameKey_container_intf
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

        let to_string (gk, k) =
          Printf.sprintf "%s:%s" (GameKey.to_string gk) (Key.to_string k)

        let compare_gamekey (gk, _) (gk', _) =
          Key.compare gk gk'

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
        module NameSet =
          Ftmap.Make(struct
                      type t = gamekey
                      let compare = Gamekey.compare_name
                    end)
        module KeySet =
          Ftmap.Make(struct
                      type t = gamekey
                      let compare = Gamekey.compare_key
                    end)

        type t = {
            k_to_a : KeySet.t
          ; a_to_k : NameSet.t
          }

        let empty =
          {k_to_a = KeySet.empty; a_to_k = NameSet.empty}

        let add_err {k_to_a; a_to_k} gk =
          match NameSet.mem gk, KeySet.mem gk with
          | true, true ->
             GameKey.to_string gk
             |> Printf.sprintf ("[GameKey_container.add_err] "
                                ^^ "%d both keys already bound")
             |> (fun v -> Error v)
          | true, false ->
             GameKey.to_string gk
             |> Printf.sprintf ("[GameKey_container.add_err] "
                                ^^ "%d game name already bound")
             |> (fun v -> Error v)
          | false, true ->
             GameKey.to_string gk
             |> Printf.sprintf ("[GameKey_container.add_err] "
                                ^^ "%d key already bound")
             |> (fun v -> Error v)
          | false, false ->
             let k_to_a = KeySet.add gk k_to_a in
             let a_to_k = NameSet.add gk a_to_k in
             Ok {k_to_a; a_to_k}

        let key_of_action {a_to_k} action =
          NameSet.find_opt action a_to_k

        let action_of_key {k_to_a} key =
          KeySet.find_opt key k_to_a
      end

  end
