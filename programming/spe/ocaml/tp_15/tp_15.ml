open Printf

let nb_lignes = 6
let nb_colonnes = 7
let neginfinity = (-1.) *. infinity

type position = {
  grille : float array array;
  hauteurs : int array;
  mutable dernier : int;
  mutable nb_joues : int;
  mutable code : int;
}

let creer_initiale () = {
  grille = Array.make_matrix nb_lignes nb_colonnes 0.;
  hauteurs = Array.make nb_colonnes 0;
  nb_joues = 0;
  dernier = -1;
  code = 0;
}

let affiche position =
  let open Printf in
  let bordure = String.make (nb_colonnes + 2) '_' in
  printf " ";
  print_endline bordure;
  for ligne = nb_lignes - 1 downto 0 do
    printf "%d|" ligne;
    for col = 0 to nb_colonnes - 1 do
      let x = position.grille.(ligne).(col) in
      if x = 1. then printf "X"
      else if x = -1. then printf "O"
      else printf " "
    done;
    printf "|\n"
  done;
  printf " ";
  print_endline (String.make (nb_colonnes + 2) '-');
  printf "  ";
  for col = 0 to nb_colonnes - 1 do printf "%d" col done;
  print_newline ()

let joueur_courant position =
  if position.nb_joues mod 2 = 0 then 1.
  else -1.

let en_jeu i j =
  0 <= i && i < nb_lignes && 0 <= j && j < nb_colonnes

let compte_consecutifs position ligne col (di, dj) =
  let nb = ref 0 in
  let g = position.grille in
  let joueur = g.(ligne).(col) in
  let i = ref ligne in
  let j = ref col in
  while en_jeu !i !j && g.(!i).(!j) = joueur do
    incr nb;
    i := !i + di;
    j := !j + dj
  done;
  i := ligne - di;
  j := col - dj;
  while en_jeu !i !j && g.(!i).(!j) = joueur do
    incr nb;
    i := !i - di;
    j := !j - dj
  done;
  !nb

let tab_valeurs =
  [|
    [| 3.; 4.; 5.; 7.; 5.; 4.; 3.|];
    [| 4.; 6.; 7.; 10.; 7.; 6.; 4.|];
    [| 5.; 8.; 11.; 13.; 11.; 8.; 5.|];
    [| 5.; 8.; 11.; 13.; 11.; 8.; 5.|];
    [| 4.; 6.; 7.; 10.; 7.; 6.; 4.|];
    [| 3.; 4.; 5.; 7.; 5.; 4.; 3.|];
  |]

let coups_possibles pos =
  let rec aux i = function
    | t when i = nb_colonnes -> t
    | u -> aux (i + 1) (if pos.hauteurs.(i) < nb_lignes then i :: u else u)
  in aux 0 []

let joue pos coup =
  let h = pos.hauteurs.(coup) in
  pos.grille.(h).(coup) <- joueur_courant pos;
  pos.hauteurs.(coup) <- h + 1;
  pos.nb_joues <- pos.nb_joues + 1;
  pos.dernier <- coup

let restore pos coup =
  let h = pos.hauteurs.(pos.dernier) in
  pos.grille.(h - 1).(pos.dernier) <- 0.;
  pos.hauteurs.(pos.dernier) <- h - 1;
  pos.nb_joues <- pos.nb_joues - 1;
  pos.dernier <- coup

(* Version bourrin mais putain c'est affreux
let perdant pos =
  let perdant = ref false in
  let joueur = joueur_courant pos *. (-1.) in
  let dis = [|(0, 1); (1, 0); (1, 1); (-1, -1)|] in
  for i = 0 to nb_lignes - 1 do
    for j = 0 to nb_colonnes - 1 do
      if pos.grille.(i).(j) = joueur then
        for k = 0 to 3 do
          if compte_consecutifs pos i j dis.(k) >= 4 then perdant := true
        done;
    done;
  done;
  !perdant
*)

let perdant pos =
  let col = pos.dernier in
  if col = -1 then false
  else
    let lig = pos.hauteurs.(col) - 1 in
    let f (di, dj) = compte_consecutifs pos lig col (di, dj) in
    f (1, 1) >= 4 || f (1, -1) >= 4 || f (0, 1) >= 4 || f (1, 0) >= 4

let strat_alea pos =
  Sys.time ()
  |> int_of_float
  |> Random.init;
  let rec aux = function
    | [x] -> x
    | x :: _ when Random.int 2 = 1 -> x
    | _ :: xs -> aux xs
    | _ -> failwith "plus aucun coup possible"
  in aux (coups_possibles pos)

let joue_partie s1 s2 =
  let pos = creer_initiale () in
  let rec loop joueur =
    if joueur = 0 then joue pos (s1 pos)
    else joue pos (s2 pos);
    affiche pos;
    if perdant pos then printf "Le joueur %d remporte la partie!" (joueur + 1)
    else if pos.nb_joues < nb_lignes * nb_colonnes then loop (1 - joueur)
    else printf "La partie est nulle!"
  in loop 0


let strat_humain pos =
  let rec aux () =
    printf "Dans quelle colonne voulez-vous jouer ? ";
    match read_int_opt () with
    | Some coup ->
      if coup < 0 || coup > nb_lignes || pos.hauteurs.(coup) = nb_lignes then (
        printf "Coup invalide!\n";
        aux ()
      ) else coup
    | None -> printf "erreur de lecture"; aux () 
  in aux ()

let heuristique_basique pos =
  let h = ref 0. in
  for i = 0 to nb_lignes - 1 do
    for j = 0 to nb_colonnes - 1 do
      h := !h +. pos.grille.(i).(j) *. tab_valeurs.(i).(j)
    done;
  done;
  !h

let rec negamax h pmax pos =
  let joueur = joueur_courant pos in
  if perdant pos then (neginfinity, -1)
  else if pos.nb_joues = nb_lignes * nb_colonnes then (0., -1)
  else if pmax = 0 then (h pos *. joueur, -1)
  else
  let rec aux eval_max coup_max = function
  | [] -> eval_max, coup_max
  | coup :: xs ->
    let dernier = pos.dernier in
    joue pos coup;
    let (x, _) = negamax h (pmax - 1) pos in
    restore pos dernier;
    let eval = (-1.)*.x in
    if eval = infinity then eval, coup
    else if eval >= eval_max then aux eval coup xs
    else aux eval_max coup_max xs
  in aux 0. (-1) (coups_possibles pos)

let strat_negamax pos =
  let (_, coup) = negamax heuristique_basique 5 pos in
  coup

let rec alphabeta h pmax pos alpha beta =
  let joueur = joueur_courant pos in
  if perdant pos then (neginfinity, -1)
  else if pos.nb_joues = nb_lignes * nb_colonnes then (0., -1)
  else if pmax = 0 then (h pos *. joueur, -1)
  else
  let rec aux valeur_max coup_max = function
  | [] -> valeur_max, coup_max
  | coup :: xs ->
    let dernier = pos.dernier in
    joue pos coup;
    let (x, _) = alphabeta h (pmax - 1) pos (-. beta) (-. valeur_max) in
    restore pos dernier;
    let valeur = (-1.)*.x in
    if valeur >= beta then beta, coup
    else if valeur > valeur_max then aux valeur coup xs
    else aux valeur_max coup_max xs
  in let possibles = coups_possibles pos in
  aux a (List.hd possibles) possibles

let strat_alphabeta pos =
  let (_, coup) = alphabeta heuristique_basique 7 pos neginfinity infinity in
  coup

let extrait_colonne x j =
  let col = x lsr (9 * j) in (* Se mettre en position pour récupérer la colonne, codée sur les 9 prochains buts *)
  col land 511

let 2pk k = (1 lsl k) - 1

let remplace_colonne x j v =
  ((2pk (9*j)) land x) + (v lsl (9*j)) + 

let ajoute_colonne v p =
  if p <> 1. then v else
  let col = v lsr 3 in
  let rec aux i = function
  | 0 -> 1 lsl i
  | x -> ((x land 1) lsl i) + aux (i + 1) (x lsr 1)
  in 
  ((aux 0 col) lsl 3) + (v land 0b111)
  
let enleve_colonne v =

let main () =
  Printexc.record_backtrace true;
  joue_partie strat_humain strat_alphabeta

let () = main ()

