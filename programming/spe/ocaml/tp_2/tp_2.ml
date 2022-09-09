type regex =
  | Vide
  | Epsilon
  | Lettre of char
  | Somme of regex * regex
  | Produit of regex * regex
  | Etoile of regex

(* La fonction parse prend en entrée une string et renvoie la regex
 * correspondante.
 * Epsilon est représenté par le caractère & et Vide par le caractère #.
 * On a les règles de priorité usuelles, et les espaces sont ignorés.
 *)

let parse string =
  let open Printf in
  let s = Stream.of_string string in
  let rec peek () =
    match Stream.peek s with
    | Some ' ' -> Stream.junk s; peek ()
    | Some c -> Some c
    | None -> None in
  let eat x =
    match peek () with
    | Some y when y = x -> Stream.junk s; ()
    | Some y -> failwith (sprintf "expected %c, got %c" x y)
    | None -> failwith "incomplete" in
  let rec regex () =
    let t = term () in
    match peek () with
    | Some '|' -> eat '|'; Somme (t, regex ())
    | _ -> t
  and term () =
    let f = factor () in
    match peek () with
    | None | Some ')' | Some '|' -> f
    | _ -> Produit (f, term ())
 and factor () =
    let rec aux acc =
      match peek () with
      | Some '*' -> eat '*'; aux (Etoile acc)
      | _ -> acc in
    aux (base ())
  and base () =
    match peek () with
    | Some '(' -> eat '('; let r = regex () in eat ')'; r
    | Some '&' -> eat '&'; Epsilon
    | Some '#' -> eat '#'; Vide
    | Some (')' | '|' | '*' as c) -> failwith (sprintf "unexpected '%c'" c)
    | Some c -> eat c; Lettre c
    | None -> failwith "unexpected end of string" in
  let r = regex () in
  try Stream.empty s; r
  with _ -> failwith "trailing ')' ?"

let rec string_of_regex = function
  | Vide -> "#"
  | Epsilon -> "&"
  | Lettre c -> String.make 1 c
  | Somme (r1, r2) -> string_of_regex r1 ^ "|" ^ (string_of_regex r2)
  | Produit (r1, r2) -> string_of_regex r1 ^ (string_of_regex r2)
  | Etoile r -> string_of_regex r ^ "*"

let rec est_vide = function
  | Vide -> true
  | Epsilon | Lettre _ -> false
  | Somme (r1, r2) -> est_vide r1 && est_vide r2
  | Produit (r1, r2) -> est_vide r1 || est_vide r2
  | Etoile r -> false

let rec un_mot = function
  | Vide -> None
  | Epsilon -> Some ""
  | Lettre c -> Some (String.make 1 c)
  | Somme (r1, r2) -> begin
    match un_mot r1 with
    | None -> un_mot r2
    | r -> r
  end
  | Produit (r1, r2) -> begin
    (* Ne pas faire 2 matchs : simplement un cas "Si les deux sont bons, ok, sinon ça ne peut pas être correct" *)
    match un_mot r1, un_mot r2 with
    | Some m1, Some m2 -> Some (m1 ^ m2)
    | _ -> None
  end
  | Etoile r -> Some ""

exception EstVide
let rec un_mot_exc = function
  | Vide -> "#"
  | Epsilon -> ""
  | Lettre c -> String.make 1 c
  | Somme (r1, r2) ->
    let e1 = est_vide r1 in
    if est_vide r1 && est_vide r2 then raise EstVide
    else if e1 then un_mot_exc r2
    else un_mot_exc r1
  | Produit (r1, r2) ->
    let m1 = un_mot_exc r1 in
    let m2 = un_mot_exc r2 in
    if m1 = "#" || m2 = "#" then raise EstVide
    else m1 ^ m2
  | Etoile r -> ""

let rec extrait_vide = function
  | Vide -> Vide
  | Epsilon -> Epsilon
  | Lettre c -> Lettre c
  | Somme (r1, r2) -> begin
    match extrait_vide r1, extrait_vide r2 with
    | Vide, Vide -> Vide
    | Vide, e | e, Vide -> e
    | e1, e2 -> Somme (e1, e2)
  end
  | Produit (r1, r2) -> begin
    match extrait_vide r1, extrait_vide r2 with
    | Vide, _ | _, Vide -> Vide
    | e1, e2 -> Produit (e1, e2)
  end
  | Etoile r -> begin
    match extrait_vide r with
    | Vide -> Epsilon
    | e -> e
  end

type t =
  | NonBorne
  | AucunMot
  | Entier of int

let rec longueur = function
  | Vide -> AucunMot
  | Epsilon -> Entier 0
  | Lettre _ -> Entier 1
  | Somme (r1, r2) -> begin
    match longueur r1, longueur r2 with
    | Entier n1, Entier n2 -> Entier (max n1 n2)
    | Entier n, AucunMot | AucunMot, Entier n -> Entier n
    | NonBorne, _ | _, NonBorne -> NonBorne
    | _ -> AucunMot
  end
  | Produit (r1, r2) -> begin
    match longueur r1, longueur r2 with
    | Entier n1, Entier n2 -> Entier (n1 + n2)
    | Entier n, AucunMot | AucunMot, Entier n -> AucunMot
    | NonBorne, _ | _, NonBorne -> NonBorne
    | _ -> AucunMot
  end
  | Etoile r -> begin
    match longueur r with
    | AucunMot -> Entier 1
    | _ -> NonBorne
  end

type partie_principale =
  | L of char
  | E of partie_principale
  | S of partie_principale * partie_principale
  | P of partie_principale * partie_principale

type forme_normale =
  | V
  | Eps
  | R of partie_principale
  | PlusEps of partie_principale

let rec reduire = function
  | Vide -> V
  | Epsilon -> Eps
  | Lettre c -> L c
  | Somme (r, Epsilon) | Somme (Epsilon, r) -> PlusEps (reduire r)
  | Somme (r1, r2) -> begin
    match reduire r1, reduire r2 with
    | Vide, Vide -> Vide
    | Vide, e | e, Vide -> e
    | e1, e2 -> 
  end
  | Produit (r1, r2) -> begin
    match extrait_vide r1, extrait_vide r2 with
    | Vide, _ | _, Vide -> Vide
    | e1, e2 ->
  end
  | Etoile r -> begin
    match reduire r with
    | Vide -> Eps
    | e -> E e
  end
