type cographe =
  | Seul
  | Union of cographe * cographe
  | Somme of cographe * cographe

let rec nb_sommets = function
  | Seul -> 1
  | Union (g1, g2) | Somme (g1, g2) -> nb_sommets g1 + nb_sommets g2

let rec nb_aretes = function
  | Seul -> 0
  | Union (g1, g2) -> nb_aretes g1 + nb_aretes g2
  | Somme (g1, g2) -> nb_aretes g1 + nb_aretes g2 + (nb_sommets g1 * nb_sommets g2)

let alpha g =
  match g with
  | Seul -> 1
  | Union (g1, g2) -> alpha g1 + alpha g2 (* Sommets de g1 et g2 indépendants *)
  | Somme (g1, g2) -> max (alpha g1) (alpha g2) (* Tous les sommets de g1 sont reliés à tous les sommets de g2 *)

let coloriage g k =
  match g with
  | Seul -> true
  | Union (g1, g2) -> coloriage g1 && coloriage g2

  (* Tous les sommets de g1 et g2 sont reliés deux à deux : *)
  (* Sommets de g1 de degré au moins nb_sommets g2 et inversement *)
  | Somme (g1, g2) ->
       nb_sommet g1 <= k @@ nb_sommets g2 <= k
    && coloriage g1 k && coloriage g2 kj
