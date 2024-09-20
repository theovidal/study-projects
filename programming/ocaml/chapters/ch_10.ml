type 'a trie = Node of 'a * bool * 'a trie list

let example =
  Node("d", false, [
    Node("i", false, [
      Node("t", true, [])
    ]);
    Node("o", true, [
    Node("d", false, [
        Node("o", true, []);
        Node("u", true, [])
      ]);
      Node("n", false, [
        Node("c", true, []);
        Node("t", true, [])
      ]);
    ])
  ])

let rec search_set letter = function
  | [] -> None
  | Node (s, _, subset) :: xs when s = letter -> Some subset
  | _ :: xs -> search_set letter xs 

(*let rec autocomplete letters set =
  match letters with
  | [] -> set
  | x :: xs -> 
    match search_letter x with
    | None ->
    | Some subset ->*)

(* Exercice 1 *)
type 'a strict = F of 'a | N of 'a * 'a strict * 'a strict

let rec profondeur_min = function
  | F _ -> 1
  | N (_, g, d) -> 1 + min (profondeur_min g) (profondeur_min d)

let rec profondeur = function
  | F _ -> 0
  | N (_, g, d) -> 1 + max (profondeur g) (profondeur d)

let rec diff_max arbre = profondeur arbre - profondeur_min arbre

let rec feuille_basse_naif arbre =
  match arbre with
  | F a -> a
  | N (_, g, d) ->
    if profondeur g >= profondeur d then feuille_basse_naif g
    else feuille_basse_naif d

let feuille_basse arbre =
  (* renvoyer (feuille_basse a, hauteur a) *)
  let rec aux arbre = 
    match arbre with
    | F a -> (a, 0)
    | N (a, g, d) ->
      let (fg, hg) = aux g in
      let (fd, hd) = aux d in
      if hg >= hd then (fg, hg + 1)
      else (fd, hd + 1) in
  let (a, _) = aux arbre in
  a


let etiquette = function
  | F a -> a
  | N (a, _, _) -> a

let rec arbre_hauteurs = function
  | F _ -> F 0
  | N (_, g, d) ->
    let hg = arbre_hauteurs g in
    let hd = arbre_hauteurs d in
    N (1 + max (etiquette hg) (etiquette hd), hg, hd)

let exemple = N(
  1,
  N ( 2, 
    F(3),
    N( 4, F(5), F(6))),
  N ( 7, F(8), F(9))
)

(* Exercice 11 *)
type 'a arbre = N of 'a * 'a arbre list

let rec est_binaire_strict (N (_, arbre)) =
  let rec aux list nb_child =
    match list with
    | [] -> nb_child = 0 || nb_child = 2
    | x :: xs ->
      est_binaire_strict x && aux xs (nb_child + 1)
  in aux arbre 0

let exemple =
  N (9, [
    N (0, []);
    N (2, [N(1, [])]);
    N (5, [])
  ])

let rec somme (N (a, arbre)) =
  let rec aux = function
  | [] -> 0
  | N (x, rest) :: xs -> x + aux rest + aux xs
  in a + aux arbre


(* Exercice 12 *)
type 'a binaire =
  | V
  | N of 'a * 'a binaire * 'a binaire

let rec taille = function
  | V -> 0
  | N (_, g, d) -> 1 + taille g + taille d

let rec poids = function
  | V -> 0
  | N (_, g, d) -> poids g + poids d + (if taille d > taille g then 1 else 0)

let exemple =
  N(1, 
  N(3, N(5, V, V), N(6, V, V)),
  N(2,
    N(7, V, V),
    N(1, N(0, V, V), N(9, V, V))
  )
)

let rec poids arbre =
  (* renvoie (poids arbre, taille arbre) *)
  let rec aux arbre =
    match arbre with
    | V -> (0, 0)
    | N (_, g, d) ->
      let (pg, hg) = aux g in
      let (pd, hd) = aux d in
      let new_height = 1 + max hd hg in
      pg + pd + (if hd > hg then 1 else 0), new_height
  in let (w, _) = aux arbre in
  w


(* Exercice 13 *)

let rec peigne_gauche n =
  if n = 0 then V
  else N (n, peigne_gauche (n - 1), V)

let rec peigne_droit n =
  if n = 0 then V
  else N (n, V, peigne_droit (n - 1))

let rec parfait n =
  if n = 0 then V
  else N (n, parfait (n - 1), parfait (n - 1))

(* Exercice 14 *)
let liste_largeur arbre =
  let rec aux tokens foret =
    if Queue.is_empty foret then tokens
    else match Queue.pop foret with
    | V -> aux tokens foret
    | N (a, g, d) ->
      Queue.push g foret; Queue.push d foret;
      aux (a :: tokens) foret
  in
  let queue = Queue.create () in
  Queue.push arbre queue;
  List.rev (aux [] queue)
