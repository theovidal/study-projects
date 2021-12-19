(*
    -------------------
    TP N°6 - 08/10/2021
    -------------------
*)

(* Exercice 1 *)

let rec binom k n =
  if k < 0 || k > n then 0
  else if k = n || k = 0 then 1
  else binom k (n - 1) + binom (k - 1) (n - 1);;

(* Exercice 2 *)

let triangle n =
  let t = Array.make (n + 1) [| |] in (* O(n) *)
  for i = 0 to n do
    t.(i) <- Array.make (i + 1) 1; (* O(i) *)
    for j = 1 to i - 1 do (* Attention aux bornes : on ne va pas sur les bords du triangle *)
      t.(i).(j) <- t.(i-1).(j) + t.(i-1).(j-1)
    done; (* toute la boucle = O(i) *)
  done;
  t;;

let binom_it k n = (triangle n).(n).(k)

(* version tentative de smart avec des flottants *)
let binom_bof k n =
  let res = ref 1. in
  let p = ref k in
  for i = int_of_float n downto int_of_float (n -. k +. 1.) do
    res := !res *. (float_of_int i) /. !p;
    p := !p -. 1.
  done;
  !res;;

let rec binom_smart k n = 
  if k < 0 || k > n then 0
  else if k = n || k = 0 then 1
  else n * binom_smart (k - 1) (n - 1) / k (* attention à l'ordre des opérations *)

(* Exercice 3 *)


