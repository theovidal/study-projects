(*
    ---------------------------------------------------------
    TRAVAUX SUR LE CHAPITRE 2 - ASPECTS FONCTIONNELS DE OCAML
    ---------------------------------------------------------
*)

(* Définition de types *)

type p3d = float * float * float
type v3d = float * float * float

(* Fonction annotée pour prendre nos types *)

let vect3d (a : p3d) (b : p3d) : v3d =
    let x1, y1, z1 = a in
    let x2, y2, z2 = b in
    (x2 -. x1), (y2 -. y1), (z2 -. z1)

(* Application de notre fonction *)

let a : v3d = (4., 5., 6.)
let u = vect3d (4., 5., 6.) (2., 3., -1.)

(* Création d'un opérateur infixe d'addition de vecteurs puis utilisation *)

let (+^) ((x1, y1, z1) : v3d) ((x2, y2, z2) : v3d) : v3d = (x1 +. x2, y1 +. y2, z1 +. z2);;
(4., 5., 6.) +^ (7., -2., -5.)

(* Utilisation du option pour une fonction qui peut ne rien renvoyer *)

let req =
    let n = Random.int 6 + 1 in
        if n > 3 then None
        else Some n in
(* Déballage de l'option avec un match *)
match req with
    | Some n -> n * 2
    | None -> 0

(* Utilisation d'un record pour représenter une droite *)
(* TODO pour s'amuser : fonction qui renvoie un option contenant le point d'intersection *)

type droite = {origine : p3d ; directeur : v3d};;

let paralleles d1 d2 =
    let x1, y1, z1 = d1.directeur in
    let x2, y2, z2 = d2.directeur in
    x1 *. y2 = x2 *. y1 && y1 *. z2 = y2 *. z1 && z1 *. x2 = z2 *. x1;;
    
let d = {origine = (0., 0., 0.); directeur = (4., 3., 5.)};;
let delta = {origine = (3., 2., 5.); directeur = (8., 6., 9.)};;
paralleles d delta


(* Exercice 5.5 *)
let rec harmonique n =
    if n < 1 then 0.
    else h (n - 1) +. 1. /. float n

let premier_n x =
    let rec aux k s =
        if s >= x then k
        else aux (k + 1) (s +. 1. /. float (k + 1)) in
    aux 1 1.
