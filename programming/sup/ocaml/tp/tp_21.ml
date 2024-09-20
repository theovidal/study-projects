(*
   _________  ________        ___    ___ ___    ___ ___     
  |\___   ___\\   __  \      |\  \  /  /|\  \  /  /|\  \    
  \|___ \  \_\ \  \|\  \     \ \  \/  / | \  \/  / | \  \   
       \ \  \ \ \   ____\     \ \    / / \ \    / / \ \  \  
        \ \  \ \ \  \___|      /     \/   /     \/   \ \  \ 
         \ \__\ \ \__\        /  /\   \  /  /\   \    \ \__\
          \|__|  \|__|       /__/ /\ __\/__/ /\ __\    \|__|
                             |__|/ \|__||__|/ \|__|                                                        
*)

open Printf

type ('a, 'b) arbre =
  | Interne of 'a * ('a, 'b) arbre * ('a, 'b) arbre
  | Feuille of 'b

let exemple =
  Interne ( 12, 
             Interne ( 4, 
                       Interne (7, Feuille 20, Feuille 30),
                       Interne (14, Feuille 1, Feuille 2)),
             Feuille 20)

(* Exercice 2 *)
let rec hauteur = function
  | Feuille _ -> 0
  | Interne (_, gauche, droite) -> 1 + max (hauteur gauche) (hauteur droite)

let rec taille = function
  | Feuille _ -> 1
  | Interne (_, gauche, droite) -> 1 + (taille gauche) + (taille droite)

let rec dernier = function
  | Feuille b -> b
  | Interne (_, _, droite) -> dernier droite


(* Exercice 3 *)
let rec affiche_prefixe = function
  | Feuille b -> print_int b; print_newline ()
  | Interne (a, gauche, droite) ->
    print_int a; print_newline ();
    affiche_prefixe gauche; affiche_prefixe droite

let rec affiche_infixe = function
  | Feuille b -> print_int b; print_newline ()
  | Interne (a, gauche, droite) ->
    affiche_infixe gauche;
    print_int a; print_newline ();
    affiche_infixe droite

let rec affiche_postfixe = function
  | Feuille b -> print_int b; print_newline ()
  | Interne (a, gauche, droite) ->
    affiche_postfixe gauche; affiche_postfixe droite;
    print_int a; print_newline ()

(* Exercice 5 *)
type ('a, 'b) token = N of 'a | F of 'b

let rec postfixe_naif = function
  | Feuille b -> [F b]
  | Interne (a, gauche, droite) -> postfixe_naif gauche @ postfixe_naif droite @ [N a]
(* Inefficace car concaténations à mort *)

let postfixe arbre =
  let rec aux arbre tokens =
    match arbre with
    | Feuille b -> F b :: tokens
    | Interne (a, gauche, droite) ->
      aux droite (N a :: tokens) |> aux gauche
  in aux arbre []

let prefixe arbre =
  let rec aux arbre tokens =
    match arbre with
    | Feuille b -> F b :: tokens
    | Interne (a, gauche, droite) -> N a ::
    (aux droite tokens |> aux gauche)
  in aux arbre []
  

let infixe arbre =
  let rec aux arbre tokens =
    match arbre with
    | Feuille b -> F b :: tokens
    | Interne (a, gauche, droite) -> N a ::
      aux droite tokens |> aux gauche
  in aux arbre []


(* Exercice 6 *)
let postfixe_term arbre =
  let rec aux foret tokens =
    match foret with
    | [] -> tokens
    | Feuille b :: reste -> aux reste (F b :: tokens) 
    | Interne (a, gauche, droite) :: reste -> aux (droite :: gauche :: reste) (N a :: tokens)
  in aux [arbre] []

(* Exercice 7 *)
let largeur arbre =
  let rec aux tokens foret =
    if Queue.is_empty foret then tokens
    else match Queue.pop foret with
      | Feuille b -> aux (F b :: tokens) foret
      | Interne (a, gauche, droite) ->
        Queue.push gauche foret; Queue.push droite foret;
        aux (N a :: tokens) foret in
  let foret = Queue.create () in
  Queue.push arbre foret;
  List.rev (aux [] foret)


(* Exercice 8 *)
let rec lire_etiquette addr arbre =
  match addr, arbre with
  | [], Feuille b -> F b
  | [], Interne (a, _, _) -> N a
  | x :: xs, Interne (a, gauche, droite) ->
    lire_etiquette xs (if x then droite else gauche)
  | _ -> failwith "Lol, c'est faux"

let rec incremente addr arbre =
  match addr, arbre with
  | [], Feuille b -> Feuille (b + 1)
  | [], Interne (a, g, d) -> Interne (a + 1, g, d)
  | x :: xs, Interne (a, gauche, droite) ->
    Interne ( a, 
              (if x then gauche else incremente xs gauche),
              if x then incremente xs droite else droite
    )
  | _ -> failwith "Lol, c'est faux"


let affiche_avec_adresse (x, adresse) =
  List.iter (fun b -> print_int (if b then 1 else 0)) adresse;
  printf " : %i\n" x
  
let tableau_adresses arbre =
  let rec aux arbre adresse =
  match arbre with
    | Feuille b -> affiche_avec_adresse (b, List.rev adresse)
    | Interne (a, g, d) ->
      affiche_avec_adresse (a, List.rev adresse);
      aux g (false :: adresse);
      aux d (true :: adresse)
  in aux arbre []


(* Exercice 9 *)
let lire_postfixe tokens =
  let rec aux tokens foret =
    match tokens, foret with
    | [], [arbre] -> arbre
    | F b :: ts, _ -> aux ts (Feuille b :: foret)
    | N a :: ts, droite :: gauche :: rem ->
      aux ts (Interne (a, gauche, droite) :: rem)
    | _ -> failwith "Lol, c'est faux"
  in
  aux tokens []

let lire_prefixe tokens =
  let rec aux tokens foret =
    match tokens, foret with
    | [], [arbre] -> arbre
    | F b :: ts, _ -> aux ts (Feuille b :: foret)
    | N a :: ts, gauche :: droite :: rem ->
      aux ts (Interne (a, gauche, droite) :: rem)
    | _ -> failwith "Lol, c'est faux"
  in
  aux (List.rev tokens) []

let lire_largeur tokens =
  let rec aux tokens foret =
    match tokens with
    | [] -> Queue.pop foret
    | F b :: ts -> Queue.push (Feuille b) foret; aux ts foret
    | N a :: ts ->
      let droite = Queue.pop foret in
      let gauche = Queue.pop foret in
      Queue.push (Interne (a, gauche, droite)) foret;
      aux ts foret
  in aux (List.rev tokens) (Queue.create ())


(* Exercice 10 *)
type cote = G | D

type arbre = Feuille | Noeud of arbre * arbre

type arbre_annote =
  | N of int * arbre_annote * arbre_annote
  | F

let exemple2 = Noeud (
  Noeud (
    Feuille,
    Noeud (Feuille, Feuille)
  ),
  Feuille
)

let card = function
  | F -> 1
  | N (taille, _, _) -> taille

let rec annote arbre =
  match arbre with
  | Feuille -> F
  | Noeud (a, b) ->
    let a' = annote a in
    let b' = annote b in
    N (1 + card a' + card b', a', b')

let insere (arbre, num, cote) =
