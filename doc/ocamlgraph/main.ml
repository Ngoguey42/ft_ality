

module V =
  struct
    type t = {
        name : string
      }
  end

module E =
  struct
    type t = {
        id : int
      }
    let compare {id} {id = id'} =
      id' - id

    let default = {id = 42}
  end

module G = Persistent.Digraph.AbstractLabeled(V)(E)

let () =
  Printf.eprintf "Salut\n%!"
