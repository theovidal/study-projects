type point = {x : float; y : float}

(* Exercice 1 *)

let distance p1 p2 = sqrt ((p2.x -. p1.x) ** 2. +. (p2.y -. p1.y) ** 2.)

let dmin_naif pts = 
  let min_d = ref infinity in
  let n = Array.length pts in
  for i = 0 to n - 1 do
    for j = 0 to n - 1 do
      if i <> j then
        let d = distance pts.(i) pts.(j) in
        min_d := min !min_d d
    done;
  done;
  !min_d

let teste_dmin_naif () =
  let points = Array.init 100 (fun _ -> { x = Random.float 100.; y = Random.float 100.}) in
  print_float (dmin_naif points)


(* Exercice 2 *)

let separe_moitie l =
  let n = List.length l in
  let rec aux u v i =
    match u with
    | [] -> [], []
    | _ when i > n / 2 - 1 -> List.rev v, u (* taille : partie entière de n / 2 -> mettre -1 pour correspondre à l'indice de l'élément *)
    | x :: xs -> aux xs (x :: v) (i + 1)
  in aux l [] 0

(* On peut aussi utiliser directement n-2 comme indice qu'on décrémente à chaque fois *)

let compare_x a b =
  if a.x < b.x then -1
  else if a.x = b.x then 0
  else 1

let tri_par_x = List.sort compare_x

let rec dmin_gauche_droite g d =
  match g with
  | [] -> infinity
  | a :: ta ->
    let rec aux d =
      match d with
      | [] -> infinity
      | b :: tb ->
        min (distance a b) (aux tb)
  in min (dmin_gauche_droite ta d) (aux d) 

let teste_dmin_gauche_droite () =
  let points = Array.init 100 (fun _ -> { x = Random.float 100.; y = Random.float 100.}) in
  let g, d = separe_moitie (Array.to_list points) in
  dmin_gauche_droite g d;;

let rec dmin_dc_naif points =
  let rec aux = function
  | [] | [_] -> infinity
  | [a; b] -> distance a b
  | pts ->
    let g, d = separe_moitie pts in
    let mg = dmin_dc_naif g in
    let md = dmin_dc_naif d in
    let mgd = dmin_gauche_droite g d in
    min (min mg md) mgd
  in aux (tri_par_x points)


(* Exercice 4 *)

let compare_y a b =
  if a.y < b.y then -1
  else if a.y = b.y then 0
  else 1

let tri_par_y = List.sort compare_y

(*
  Calcule la distance minimale au sein d'une bande de largeur 2d
  en prenant comme milieu l'abcisse xmed
*)
let dmin_med points xmed d =
  let band_list = List.filter (fun p -> p.x <= xmed +. d && p.x >= xmed -. d) points in
  let band = Array.of_list (tri_par_y band_list) in
  let dmin = ref infinity in
  let n = Array.length band in
  for i = 0 to n - 1 do
    for k = i + 1 to min (n - 1) (i + 7) do
      dmin := min !dmin (distance band.(i) band.(k))
    done;
  done;
  !dmin
(* on pourrait combiner avec la fonction principale pour éviter
d'avoir encore une boucle de calcul du minimum *)

(* Fonction principale *)
let rec dmin_dc points =
  let rec aux = function
  | [] | [_] -> infinity
  | [a; b] -> distance a b
  | pts ->
    let left_pts, right_pts = separe_moitie pts in
    let d = min (dmin_dc_naif left_pts) (dmin_dc_naif right_pts) in
    let d_med = dmin_med pts (List.hd right_pts).x d in (* La médiane correspond au point le plus à gauche de la partie droite, mais attention ! on prend les 2 parties en compte *)
    min d d_med
  in aux (tri_par_x points)

let teste_dmin_dc () =
  for i = 0 to 1000 do
    let points = Array.init 100 (fun _ -> { x = Random.float 100.; y = Random.float 100.}) in
    assert (dmin_naif points = dmin_dc (Array.to_list points))
  done;;

(* Attention aux points de rigueur :
  - Opérandes sur flottants ≠ opérandes sur entiers
  - Indices à partir desquels on prend les éléments, parties à traiter bref logique de l'algo
  - Bien retenir "dmin_droite_gauche", qui présente le parcours quadratique d'une liste (exemple ci-dessous)
*)
let rec apply_two f t =
  match t with
  | [] -> ()
  | x :: xs ->
    let rec aux t' =
      match t' with
      | [] -> ()
      | y :: ys -> f x y ; aux ys
  in aux xs ; apply_two f xs (* On utilise aux xs pour ne pas appliquer f sur les mêmes couples *)
