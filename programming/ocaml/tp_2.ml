(*
    -------------------
    TP N°2 - 13/09/2021
    -------------------
*)

(* 1.1 *)

let rec mem x u = match u with
  | [] -> false
  | y :: ys -> y = x || mem x ys


(* 1.2 *)

let rec nth u n = match u with
  | [] -> failwith "pas assez d'éléments"
  | x :: _ when n = 0 -> x
  | _ :: xs -> nth xs (n - 1)
    

(* version avec match sur les deux paramètres *)

let rec nth u n = match u, n with
  | [], _ -> failwith "pas assez d'éléments"
  | x :: _, 0 -> x
  | x :: xs, n -> nth xs (n - 1)


(* 1.3 -> bien penser au match sur les deux paramètres *)

let rec take n u = match u, n with
  | [], _ | _, 0 -> []
  | x :: xs, _ -> x :: take (n - 1) xs


(* 1.4 -> de a inclus à b exclus *)

let rec range a b =
  if a >= b then []
  else a :: range (a + 1) b


(* 2.1 -> identique au 9 du TD 1 
   cf. corrigé pour les formules mathématiques *)
(* 2.3 -> identique au 10 du TD 1 *)


(* 2.5 *)

(* on touche pas à la liste de droite, on inverse juste la liste de gauche *)
let rec rev_append a b = match a with
  | [] -> b
  | x :: xs -> rev_append xs (x :: b)


(* 2.6 *)

let rec miroir l = rev_append l []


(* 3.1 *)

let rec applique f u = match u with
  | [] -> []
  | x :: xs -> f x :: applique f xs


(* 3.2 *)

let liste_carres u = applique (fun x -> x * x) u


(* 4.1 *)

let rec sans_doublons_triee u = match u with
  | [] | _ :: [] -> true
  | x :: y :: tail -> x <> y && sans_doublons_triee (y :: tail)


(* 4.2 *)

let rec elimine_doublons_triee u = match u with
  | [] | _ :: [] -> u
  | x :: y :: tail -> let triee = elimine_doublons_triee (y :: tail) in
    if x = y then triee
    else x :: triee


(* 4.3 *)

let rec sans_doublons u = match u with
  | [] | _ :: [] -> true
  | x :: xs -> not (mem x xs) && sans_doublons xs


(* 4.4 *)

let rec elimine_doublons u = match u with
  | [] | _ :: [] -> u
  | x :: tail -> let triee = elimine_doublons tail in
    if mem x triee then triee
    else x :: triee


(* 5.1 *)

let compresse u = match u with
  | [] -> u
  | x :: xs -> 
    let rec compresse_aux u v c = match u with
      | [] -> v @ [c]
      | y :: ys when y = fst c -> compresse_aux ys v (y, snd c + 1)
      | y :: ys -> compresse_aux ys (v @ [c]) (y, 1) in
    compresse_aux xs [] (x, 1)

(* 5.2 *)

let rec decompresse u =
  let rec deroule c v =
    let a, n = c in
      if n = 0 then v
      else deroule (a, n-1) (a :: v) in

  match u with
  | [] -> []
  | y :: ys -> deroule y [] @ decompresse ys;;

decompresse [("a", 3); ("c", 1); ("b", 2)]
