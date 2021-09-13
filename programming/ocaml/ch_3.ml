(*
    -------------------------------------------------------
    TRAVAUX SUR LE CHAPITRE 3 - ASPECTS IMPÉRATIFS DE OCAML
    -------------------------------------------------------
*)

(* Exercice 3.1 *)

let somme1 n =
  let s = ref 0. in
  for i = 1 to n do
    s := !s +. 1. /. float (i + n)
  done;
  !s

let somme2 n =
  let s = ref 0. in
  for i = 1 to n do
    for j = 1 to n do
      s := !s +. float (i * j)
    done;
  done;
  !s

let somme3 n =
  let s = ref 0. in
  for j = 2 to n do
    for i = 1 to j - 1 do
      s := !s +. float (i * j)
    done;
  done;
  !s

(* Exercice 3.2 -> renvoyer le résultat de la puissance *)

let puissance_inf n =
  let i = ref 1 in
  while !i * 2 <= n do
    i := !i * 2
  done;
  !i

(* Exercice 3.3 *)
let double a = Array.map (fun x -> 2 * x) a;;
let mul a u = Array.map (fun x -> a * x) u;;
let affiche u = Array.iter (fun x -> Printf.printf "%d " x) u;;

affiche (mul 3 [| 2; 4; 5 |])
