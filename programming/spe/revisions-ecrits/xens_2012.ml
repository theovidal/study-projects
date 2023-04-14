type ac =
  | Z
  | U
  | C of int * ac * ac

let cons i a1 a2 = C (i, a1, a2)

type ensemble = int list

(* descente le long de la branche droite *)
let rec un_elt = function
  | Z -> failwith "arbre invalide"
  | U -> []
  | C (i, _, t2) -> i :: un_elt t2

let rec singleton = function
  | [] -> U
  | x :: xs -> cons x Z (singleton xs)

let appartient u t = 
  match u, t with
  | [], U -> true
  | _, Z -> false
  | _, U -> false
  | [], C (_, sans, _) -> appartient [] sans (* Il faut descendre tout à gauche pour savoir si l'ensemble vide appartient ou non! *)
  | x :: xs, C (i, sans, avec) ->
    if x = i then appartient xs avec
    else if x < i then false (* La liste n'est pas triée par ordre croissant *)
    else appartient u sans

let rec cardinal = function
  | Z -> 0
  | U -> 1
  | C (_, t1, t2) -> cardinal t1 + cardinal t2
