(*
    --------------------
    TP N°19 - 14/12/2021
    --------------------
*)

(* Exercice 1 *)

let compare_couple (x, x') (y, y') =
  let res = abs x - abs y in
  if res = 0 then abs y' - abs x'
  else res

in assert (
  List.sort compare_couple [(2, 3); (4, 2); (4, 3); (3, 45)]
    = [(2, 3); (3, 45); (4, 3); (4, 2)]
)

(* Exercice 2 *)

let cmp_somme (x, y) (x', y') = x + y - (x' + y')
let cmp_premiere (x, _) (x', _) = x - x'

let sort t = 
  Array.sort cmp_somme t;
  Array.sort cmp_premiere t;


