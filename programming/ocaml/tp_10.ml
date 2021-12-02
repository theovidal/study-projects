(*
   _________  ________        ___    ___     
  |\___   ___\\   __  \      |\  \  /  /|    
  \|___ \  \_\ \  \|\  \     \ \  \/  / /    
       \ \  \ \ \   ____\     \ \    / /     
        \ \  \ \ \  \___|      /     \/      
         \ \__\ \ \__\        /  /\   \      
          \|__|  \|__|       /__/ /\ __\     
                             |__|/ \|__|     
                                           
        VIDAL Théo 861 — 8/11/2021
*)

      (* —————————————— *)
      (*   Exercice 1   *)
      (* —————————————— *)

let rec rev_append u v =
  match u with
  | [] -> v
  | x :: xs -> rev_append xs (x :: v)

let miroir u = rev_append u []

type 'a file_fonct = 'a list * 'a list

let file_vide = ([], [])

let ajoute x (fst, snd) = x :: fst, snd

let enleve f =
  match f with
  | [], [] -> None
  | fst, snd ->
    match snd with
    | [] -> 
      let rev = miroir fst in
      Some (List.hd rev, ([], List.tl rev))
    | x :: xs -> Some (x, (fst, xs))

(* 
  version plus optimisée avec un seul match
  dans le dernier car on fait un appel récursif pour bien récupérer l'élément
*)

let rec enleve (fst, snd) =
  match fst, snd with
  | [], [] -> None
  | _, x :: xs -> Some (x, (fst, xs)) 
  | _, [] -> enleve ([], miroir fst)


      (* —————————————— *)
      (*   Exercice 2   *)
      (* —————————————— *)

let rec somme f =
  match enleve f with
  | None -> 0
  | Some (x, tail) -> x + somme tail

let file_fonct_of_list u =
  let rec aux u =
    match u with
    | [] -> file_vide
    | x :: xs -> ajoute x (aux xs) in
  aux (miroir u)

let rec ffol_eff u =
  match u with
  | [] -> [], []
  | x :: xs -> [], x :: (snd (ffol_eff xs))

let rec iter_file f file =
  match enleve file with
  | None -> ()
  | Some (x, xs) -> f x; iter_file f xs

let afficher f = iter_file (fun x -> print_int x; print_newline ()) f


      (* —————————————— *)
      (*   Exercice 4   *)
      (* —————————————— *)

type 'a pile = {donnees : 'a option array; mutable courant : int}

let capacite p = Array.length p.donnees

let nouvelle_pile c = { donnees = Array.make c None; courant = -1}

let pop pile =
  if pile.courant < 0 then None
  else
    let res = pile.donnees.(pile.courant) in
    pile.courant <- pile.courant - 1;
    res

let push x pile =
  if pile.courant + 1 >= capacite pile then failwith "Pile pleine"
  else 
    pile.courant <- pile.courant + 1;
    pile.donnees.(pile.courant) <- Some x


      (* —————————————— *)
      (*   Exercice 5   *)
      (* —————————————— *)

type 'a file_i = {
  donnees : 'a option array;
  mutable entree : int;
  mutable sortie : int;
  mutable cardinal : int
}

(*
  • Si l'on dispose uniquement de f.entree et f.cardinal, il est possible de retrouver
    f.sortie comme étant égal à f.entree + cardinal (si f.entree < f.sortie) ou f.entree - cardinal
    (si f.entree > f.sortie), le tout modulo la taille de la liste.
  
  • Si l'on dispose de f.entree et f.sortie, si les deux entiers sont identiques, nous ne pouvons pas savoir
    s'il s'agit d'une file vide ou pleine sans son cardinal. 
    Astuce : toujours laisser une case vide pour que le cas où sortie = entree soit la file vide.
*)


      (* —————————————— *)
      (*   Exercice 6   *)
      (* —————————————— *)

let file_vide_i n = {
  donnees = Array.make n None;
  entree = 0;
  sortie = 0;
  cardinal = 0
}

let capacite_i f = Array.length f.donnees

let ajoute_i a f =
  if f.entree = f.sortie && f.cardinal <> 0 then failwith "Insertion dans file pleine"
  else
    f.donnees.(f.entree) <- Some a;
    f.entree <- (f.entree + 1) mod (capacite_i f);
    f.cardinal <- f.cardinal + 1

let enleve_i f =
  if f.cardinal = 0 then None
  else
    let res = f.donnees.(f.sortie) in
    f.sortie <- (f.sortie + 1) mod (capacite_i f);
    f.cardinal <- f.cardinal - 1;
    res

let de_liste_i u n =
  let f = file_vide_i n in
  let rec aux u =
    match u with
    | [] -> f
    | x :: xs -> ajoute_i x f; aux xs in
  aux u


      (* —————————————— *)
      (*   Exercice 7   *)
      (* —————————————— *)

let peek_1 p =
  match pop p with
  | None -> None
  | Some x -> push x p; Some x

let est_vide_1 p = peek_1 p = None

let rec iter_destructif f s =
  match pop s with
  | None -> ()
  | Some x -> f x; iter_destructif f s

let copie s =
  let s_copie = nouvelle_pile (capacite s) in
  let miroir = nouvelle_pile (capacite s) in
  iter_destructif (fun x -> push x miroir) s;
  iter_destructif (fun x -> push x s; push x s_copie) miroir;
  s_copie


let egal_faux s t =
  while not (est_vide_1 s) && not (est_vide_1 t) && pop s = pop t do
    ()
  done;
  est_vide_1 s && est_vide_1 t

let egal_1 s t =
  let sc = copie s in
  let st = copie t in
  egal_faux sc st


      (* —————————————— *)
      (*   Exercice 8   *)
      (* —————————————— *)

let est_vide p = p.courant = -1

let flush p = p.courant <- -1

let egal p q =
  if p.courant <> q.courant then false else

  (* Version avec boucle *)
  let i = ref 0 in
  while !i <= p.courant && p.donnees.(!i) = q.donnees.(!i) do
    incr i
  done;
  !i > p.courant

  (* Version récursive *)
  let rec aux i =
    if i > p.courant then true
    else p.donnees.(i) = q.donnees.(i) && aux (i + 1) p q in
  aux 0


let itere f p = 
  for i = p.courant downto 0 do
    let el = p.donnees.(i) in
    match el with
    | None -> ()
    | Some x -> f x
  done;
