(*
   _________  ________        ___    ___ ___       ___  ___  ___     
  |\___   ___\\   __  \      |\  \  /  /|\  \     |\  \|\  \|\  \    
  \|___ \  \_\ \  \|\  \     \ \  \/  / | \  \    \ \  \ \  \ \  \   
       \ \  \ \ \   ____\     \ \    / / \ \  \    \ \  \ \  \ \  \  
        \ \  \ \ \  \___|      /     \/   \ \  \____\ \  \ \  \ \  \ 
         \ \__\ \ \__\        /  /\   \    \ \_______\ \__\ \__\ \__\
          \|__|  \|__|       /__/ /\ __\    \|_______|\|__|\|__|\|__|
                             |__|/ \|__|                             
                                                                     
                              10/05/2022                                        
*)

type formule =
  | C of bool
  | V of int
  | Et of formule * formule
  | Ou of formule * formule
  | Imp of formule * formule
  | Non of formule

type valuation = bool array

(*
  I – Algorithme en force brute
*)

let rec taille f =
  match f with
  | C _ | V _ -> 1
  | Et (f1, g1) | Ou (f1, g1) | Imp (f1, g1) -> 1 + taille f1 + taille g1
  | Non f' -> 1 + taille f'

let rec var_max = function
  | C _ -> -1
  | V i -> i
  | Et (f1, g1) | Ou (f1, g1) | Imp (f1, g1) ->
    let var_f = var_max f1 in
    let var_g = var_max g1 in
    max var_f var_g
  | Non f' -> var_max f'

let rec evalue f v =
  match f with
  | C b -> b
  | V i -> v.(i)
  | Et (f1, g1) -> evalue f1 v && evalue g1 v
  | Ou (f1, g1) -> evalue f1 v || evalue g1 v
  | Imp (f1, g1) -> evalue (Ou (Non f1, g1)) v
  | Non f' -> not (evalue f' v)

exception Derniere
let incremente_valuation v =
  let rec aux v i =
    if v.(i) then begin
      if Array.length v - 1 = i then raise Derniere;
      v.(i) <- false;
      aux v (i + 1)
    end
    else v.(i) <- true
  in aux v 0

let satisfiable_brute f =
  let vmax = var_max f in
  let v = Array.make (vmax + 1) false in
  try
    let rec loop _ =
      if evalue f v then true
      else begin
        incremente_valuation v;
        loop ()
      end
    in loop ()
  with
  | Derniere -> false

(*
  II – Algorithme de Quine
*)

let rec elimine_constantes = function
  | V i -> V i
  | C v -> C v
  | Et (f, g) ->
    begin
      match elimine_constantes f, elimine_constantes g with
      | C a, C b -> C (a && b)
      | C v, exp | exp, C v when v -> exp (* Si vrai, attendre de voir l'autre *)
      | C v, _ | _, C v when not v -> C v (* si faux, le ET ne marchera pas *)
      | f', g' -> Et (f', g')
    end
                                              (* Voir ces histoires comme une logique tri-valuée *)
  | Ou (f, g) ->
    begin
      match elimine_constantes f, elimine_constantes g with
      | C a, C b -> C (a || b)
      | C v, exp | exp, C v when v = false -> exp (* Si faux, attendre l'autre *)
      | C v, _ | _, C v when v = true -> C true (* Si vrai, comme OU, alors c'est bon *)
      | f', g' -> Ou (f', g')
    end

  | Imp (f, g) ->
    begin
      match elimine_constantes f, elimine_constantes g with
      | C false, _ | _, C true -> C true           (* non a ou b *)
      | C true, h -> h
      | f', C false -> Non f'
      | f', g'-> Imp (f', g')
    end

  | Non f -> 
    match elimine_constantes f with
    | C v -> C (not v)
    | exp -> Non exp

let rec substitue f i g =
  match f with
  | V j when i = j -> g
  | Et (f1, f2) -> Et (substitue f1 i g, substitue f2 i g)
  | Ou (f1, f2) -> Ou (substitue f1 i g, substitue f2 i g)
  | Non f' -> Non (substitue f' i g)
  | _ -> f

type decision =
  | Feuille of bool
  | Noeud of int * decision * decision

let rec var_min = function
  | C _ -> max_int
  | V i -> i
  | Et (f1, g1) | Ou (f1, g1) ->
    let var_f = var_min f1 in
    let var_g = var_min g1 in
    min var_f var_g
  | Non f' -> var_min f'

let rec construire_arbre f =
  match elimine_constantes f with
  | C v -> Feuille v
  | g ->
    let i = var_min g in
    let g_bottom = substitue g i (C false) in
    let g_top = substitue g i (C true) in
    Noeud (i, construire_arbre g_bottom, construire_arbre g_top)

let satisfiable_via_arbre f =
  let rec aux = function
  | Feuille v -> v
  | Noeud (_, f, g) -> aux f || aux g
  in aux (construire_arbre f)

(*
  III – Un exemple d'application : le coloriage de graphes
*)

type graphe = int list array

(* Graphe de Petersen : nombre chromatique égal à 3. *)
let petersen =
  [|
    [4; 5; 6];
    [6; 7; 8];
    [5; 8; 9];
    [4; 7; 9];
    [0; 3; 8];
    [0; 2; 7];
    [0; 1; 9];
    [1; 3; 5];
    [1; 2; 4];
    [2; 3; 6]
  |]

(* Générateur de graphe aléatoire.
 * graphe_alea n p génère un graphe à n sommet
 * dans lequel chaque arête possible a une probabilité p
 * d'être choisie (indépendamment des autres). *)

let graphe_alea n proba_arete =
  let g = Array.make n [] in
  for i = 0 to n - 1 do
    for j = i + 1 to n - 1 do
      if Random.float 1. <= proba_arete then begin
        g.(i) <- j :: g.(i);
        g.(j) <- i :: g.(j)
      end
    done
  done;
  g

  
  let rec binarise_et l =
    match l with
    | [] -> C true
    | x :: xs -> Et (x, binarise_et xs)
    
    let rec binarise_ou l =
      match l with
      | [] -> C false
      | x :: xs -> Ou (x, binarise_ou xs)
      
(* Tentative un peu foireuse *)
let encode g k =
  let n = Array.length g in
  let x i c = V (i * k + c) in
  let rec aux et_l ou_l i c =
    if i = n then binarise_et et_l
    else if c = k then aux (binarise_ou ou_l :: et_l) [] (i + 1) 0
    else
      let conflit_avec_voisins = binarise_ou (List.map (fun j -> x j c) g.(i)) in
      aux et_l (Et (x i c, Non (conflit_avec_voisins)) :: ou_l) i (c + 1)
  in aux [] [] 0 0

(* Correction *)

let encode g k =
  let n = Array.length g in
  let var i c = V (n * i + c) in
  let est_colorie i = binarise_ou (List.init k (fun c -> var i c)) in

  let contraintes i =
    let contraintes_couleurs c =
      let autres_couleurs = List.filter (fun x -> x <> c) (range k) in
      let voisins = List.map (fun x -> var x c) g.(i) in
      let unique = List.map (fun c' -> var i c' ) autres_couleurs in
      Imp (var i c, Non (binarise_ou (voisins @ unique)))
    in Et (est_colorie i, binarise_et (List.init k contraintes_couleurs))
  in
  binarise_et (List.init n (fun i -> contraites i))

let est_k_coloriable g k =
  let col = encode g k in
  satisfiable_via_arbre col
