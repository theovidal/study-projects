(*
    -------------------
    TP N°5 - 01/10/2021
    -------------------
*)

(* Exercice 2 *)

let fib_iter n =
  let f0 = ref 0 in
  let f1 = ref 1 in
  for i = 0 to n-1 do
    let f2 = !f0 + !f1 in
    f0 := !f1;
    f1 := f2
  done;
  !f0;;


let fib_rec n =
  let rec aux i f1 f2 =
      if i <= 1 then i
      else f1 + aux (i - 1) f2 (f1 + f2) in
  aux n 0 1

let () =
  assert (fib_rec 2 = 1);
  assert (fib_rec 3 = 2);
  assert (fib_rec 4 = 3);
  assert (fib_rec 5 = 5);
  assert (fib_rec 6 = 8);
  assert (fib_rec 7 = 13);
  assert (fib_rec 8 = 21);
  assert (fib_rec 9 = 34);
  assert (fib_rec 10 = 55)
  

(* Exercice 3 *)

let tri_decroissant u = List.sort (fun a b -> b - a) u

let tri_valeur_absolue u = List.sort (fun a b -> int_of_float (abs_float b -. abs_float a)) u

let tri_deuxieme_composante u =
  List.sort (fun a b -> snd a - snd b) u


(* Exercice 4 *)

let rec records cmp u = match u with
  | [] -> []
  | x :: xs -> 


let () =
  assert (records compare [] = []);
  assert (records compare [4] = [4]);
  assert (records compare [4; 1; 3; 7; 5; 7; 6; 7; 10] = [4; 7; 10]);
  assert (records compare [4; 1; 3; 7; 5] = [4; 7]);
  let u = [1; 8; 2; 4; 5; 10; 4; 10; 11; 8] in
  assert (records (fun x y -> x - y) u = [1; 8; 10; 11]);
  let v = [(1, 3); (2, 2); (0, 5); (3, 1); (4, 3)] in
  let cmp (a, b) (c, d) = (a + b) - (c + d) in
  assert (records cmp v = [(1, 3); (0, 5); (4, 3)])


(* Exercice 5 *)

let rec pgcd a b =
  if b = 0 then a else pgcd b (a mod b)


let rec etapes a b =
  failwith "à faire"


let () =
  assert (etapes 0 0 = 0);
  assert (etapes 12 0 = 0);
  assert (etapes 17 1 = 1);
  assert (etapes 15 6 = 2);
  assert (etapes 728 427 = 7);
  assert (etapes 34 21 = 7);
  assert (etapes 112233445566 223344556677 = 6)


let phi n =
  failwith "à faire"

let () =
  assert (
    List.init 15 (fun i -> phi (i + 1))
    = [0; 1; 2; 2; 3; 2; 3; 4; 3; 3; 4; 4; 5; 4; 4]);
  assert (phi 12345 = 15)


let records_euclide borne =
  failwith "à faire"
