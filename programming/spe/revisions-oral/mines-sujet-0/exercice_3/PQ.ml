module PQif = Set.Make (struct
                    type t = (float*int)
                    let compare = compare
                     end)
type t = PQif.t
       
let recupere_min p = let x,y = PQif.min_elt p in y,x
           
let retire_min p =
  let x = PQif.min_elt p in
  PQif.remove x p

let ajoute p i f = PQif.add (f,i) p

  
let file_vide = PQif.empty
