open Printf

type graphe =
  {nb_sommets : int;
   voisins : int -> int list}

exception Trouve of int array

let hamiltonien_depuis g x0 =
  let ordre = Array.make g.nb_sommets (-1) in

  let rec explore x i =
    if ordre.(x) = -1 then begin
      ordre.(x) <- i;
      if i = g.nb_sommets - 1 then raise (Trouve ordre);
      List.iter (fun y -> explore y (i + 1)) (g.voisins x);
      ordre.(x) <- -1 (* Si on arrive à cette ligne, c'est qu'on a pas eu d'exception, *)
                      (* donc aucun chemin n'a été trouvé -> on reset et on repart *)
    end
  in
    
  try
    explore x0 0;
    None
  with
  | Trouve o -> Some o


let adj_g0 =
  [|
    [1];
    [0; 2; 7];
    [1; 3; 5];
    [2; 4; 6];
    [3];
    [2; 8];
    [3; 7; 8];
    [1; 6];
    [5; 6]
  |]

let g0 = {
  nb_sommets = 9;
  voisins = fun i -> adj_g0.(i)
}

let verifie_case n m i j =
  i >= 0 && i < n && j >= 0 && j < m

let graphe_cavalier n m =
  let indice i j = m * i + j in
  let adj = Array.make (n * m) [] in
  for i = 0 to n - 1 do
    for j = 0 to n - 1 do
      let deltas = [(-1, -2); (-2, -1); (-2, 1); (-1, 2); (1, -2); (2, -1); (2, 1); (1, 2)] in
      let rec add indices deltas =
        match deltas with
        | [] -> adj.(indice i j) <- indices
        | (di, dj) :: xs ->
          let i', j' = i + di, j + dj in
          if verifie_case n m i' j' then add ((indice i' j') :: indices) xs
          else add indices xs
      in add [] deltas
    done;
  done;
  {
    nb_sommets = n * m;
    voisins = fun i -> adj.(i)
  }

let affiche_parcours_cavalier n m (x, y) =
  let graphe = graphe_cavalier n m in
  let res = hamiltonien_depuis graphe (x * n + y) in
  match res with
  | None -> printf "Aucun parcours pour cette configuration"
  | Some ordre ->
    for i = 0 to n * m - 1 do
      if i mod m = 0 then printf "\n";
      printf "%d " ordre.(i)
    done

let hamiltonien_opt_depuis g x0 =
  let ordre = Array.make g.nb_sommets (-1) in
  let tri_voisin x y =
    let nb i = List.fold_right
      (fun k acc -> if ordre.(k) = -1 then acc + 1 else acc)
      (g.voisins i) 0
    in
    nb x - nb y
  in
  let compteur = ref 0 in
  let rec explore x i =
    if ordre.(x) = -1 then begin
      incr compteur;
      ordre.(x) <- i;
      if i = g.nb_sommets - 1 then raise (Trouve ordre);
      let succ = List.sort tri_voisin (g.voisins x) in
      List.iter (fun y -> explore y (i + 1)) succ;
      ordre.(x) <- -1
    end
  in
  try
    explore x0 0
  with
  | Trouve _ -> printf "%d\n" !compteur

(* Pour un graphe 200x200, on parcourt 40000 noeuds soit la longueur exacte du chemin. *)
(* On ne fait jamais de backtracking, l'heuristique est parfaite *)


(*
  II – Tableaux auto-référents
*)

(* Code générique *)
type 'a reponse =
  | Refus
  | Accepte of 'a
  | Partiel of 'a

type 'a probleme = {
  accepte: 'a -> 'a reponse;
  enfants: 'a -> 'a list;
  initiale: 'a
}

let enumere pb =
  let rec backtrack candidat =
    match pb.accepte candidat with
    | Refus -> []
    | Accepte s -> [s]
    | Partiel s ->
      let rec enfants = function
      | [] -> []
      | x :: xs -> backtrack x @ enfants xs
      in enfants (pb.enfants s)
  in backtrack pb.initiale

(* Spécialisation au problème *)

let rec occurences n t =
  let occs = Array.make n 0 in
  Array.iter (fun x -> occs.(x) <- occs.(x) + 1) t;
  occs

let rec enfants_auto n t =
  let f i = Array.append t [| i |] in
  List.init n f

let accepte_auto n t =
  (* On ne peut décider si une solution est bonne ou non que lorsqu'on a toute la taille *)
  if Array.length t = n then
    let occs = occurences n t in
    if occs = t then Accepte t
    else Refus
  else Partiel t

(* Bien retenir tout le long qu'on *construit* occurences _à partir_ de t *)
exception Echec

let accepte_auto_bis n t =
  let k = Array.length t in
  if n = k then accepte_auto n t (* Vérif à la fin : si tout est auto-référent *)
  else 
    try
      let sum = Array.fold_left (+) 0 t in
      if sum > n then raise Echec;      (* Vérif 1. somme inférieure à taile *)
      let occs = occurences n t in
      if k > 0 && somme + (n - k)
      let dispo = ref (n - k) in
      for i = 0 to k - 1 do
        dispo := !dispo - t.(i) + occs.(i); (* Vérif 3. assez de cases dispo pour toutes les occurences *)
        if !dispo < 0 || occs.(i) > t.(i) then raise Echec (* Vérif 4. déjà trop d'occurences par rapport au tableau *)
      done;
      Partiel t
    with 
      Echec -> Refus



let auto_referents_brute n = {
  accepte = accepte_auto n;
  enfants = enfants_auto n;
  initiale = [| |]
}
