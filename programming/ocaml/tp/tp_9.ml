(*
    ------------------------
    TP N°9 NOTÉ - 19/10/2021
    ------------------------
*)

open Printf

let u0_exemple = 31122010

(* Remplacez le 42 par votre date de naissance
 * au format JJMMAAAA. *)
let u0 = 21032003

(* NE TOUCHEZ PAS À CETTE PARTIE DU CODE !!! *)
let m = 1 lsl 31 - 1

let f initial =
  let n = 2_000_000 in
  let t = Array.make n initial in
  for i = 1 to n - 1 do
    t.(i) <- (16807 * t.(i - 1)) mod m
  done;
  t

let u_ex = f u0_exemple

let u = f u0

let v_ex = Array.map ((land) 1) u_ex

let v = Array.map ((land) 1) u
(* FIN DE LA PARTIE À LAISSER EN ÉTAT *)

(************)
(* Partie I *)
(************)



(* Question 1 :
 * u_1 : 5849
 * u_10 : 2003
 * u_1000000 : 9951 *)

(* Question 2
 * 6532
 * 5735
 * 1041  *)

let slice u a b =
  let sum = ref 0 in
  for i = 0 to Array.length u - 1 do
    if i >= a && i < b then sum := !sum + u.(i)
  done;
  !sum

(* Question 3
 * 657
 * 15130
 * 1040052 *)

let find_min u a b =
  let min_val = ref u.(0) in
  let min_i = ref 0 in
  for i = a to b - 1 do
    if u.(i) < !min_val then begin
      min_val := u.(i);
      min_i := i
    end
  done;
  !min_i

(************)
(* Partie 2 *)
(************)

let rec min_liste_a u = match u with
    | [] -> max_int
    | x :: xs -> min x (min_liste_a xs)

let min_liste u =
  let rec aux u min = match u with
    | [] -> min
    | x :: xs when x < min -> aux xs x
    | _ :: xs -> aux xs min in
  aux (List.tl u) (List.hd u)
  
let rec enleve x u =
  match u with
  | [] -> u
  | y :: ys when x = y -> ys
  | y :: ys -> y :: (enleve x ys)

let rec enleve_distincts x u =
  match u with
  | [] -> u
  | y :: ys when x = y -> enleve_distincts x ys
  | y :: ys -> y :: (enleve_distincts x ys)

let extrait_min u = 
  let m = min_liste u in
  let up = enleve_distincts m u in
  m, up


let rec tri_selection u = 
  match u with
  | [] -> u
  | _ ->
    let m, up = extrait_min u in
    m :: (tri_selection up)

(************)
(* Partie 3 *)
(************)


(* Question 9 :
 * 136
 * 133
 * 998 *)

let palindromes v l max =
  let count = ref 0 in
  for b = l to max do
    let rec aux i =
      if i > (2 * b - l - 1)/2 then 1
      else if v.(i) = v.(2 * b - 1 - i - l) then aux (i + 1)
      else 0 in

    count := !count + aux (b - l)
  done;
  !count

(* Question 10
 * 304
 * 358
 * 7344 *)

let nb_pal v n =
  let count = ref 0 in
  for b = 1 to n do
    for a = 0 to b - 1 do
      let rec aux i =
        if i > (b - 1 + a)/2 then 1
        else if v.(i) = v.(b - 1 - i + a) then aux (i + 1)
        else 0 in
      count := !count + aux a
    done;
  done;
  !count

(************)
(* Partie 4 *)
(************)

let delta v a b =
  let count_zero = ref 0 in
  let count_un = ref 0 in
  for i = a to b - 1 do
    if v.(i) = 0 then incr count_zero
    else if v.(i) = 1 then incr count_un
  done;
  !count_un - !count_zero

(* Question 11
 * 218
 * 79587
 * 1821 *)

let count_eqs v l max =
  let a = ref 1 in
  let b = ref (l + 1) in
  let d = ref (delta v 0 l) in
  let count = ref (if !d = 0 then 1 else 0) in
  while !b < max + 1 do
    d := !d + if v.(!a - 1) = 1 then -1 else 1;
    d := !d + if v.(!b - 1) = 1 then 1 else -1;

    if !d = 0 then incr count;
    incr a; incr b
  done;
  !count

(* Question 12
 * 98
 * 806824
 * 7230 *)

let max_eqs v a b =
  let m = ref 0 in
  for j = 0 to b do
    for i = 0 to j do
      if delta v i j = 0 then m := max !m (j - i)
    done;   
  done;
  !m


let max_eqs v mini maxi =
  let m = ref 0 in
  let rec aux a b =
    if b = mini then ()
    else if a = mini || b - a < !m then aux (b - 1) (b - 1)
    else if delta v a b = 0 then m := max !m (b - a);
    aux (a - 1) b
  in aux 0 maxi;
  !m
  

let max_eqs v inf sup =
  let m = ref 0 in
  let a = ref inf in
  let b = ref sup in
  while !b >= inf do
    if !a = !b || !b - !a < !m then begin
      a := inf;
      b := !b - 2
    end
    else if delta v !a !b = 0 then begin
      m := max !m (!b - !a);
      b := !b - 2;
      a := inf
    end 
    else a := !a + 2
  done;
  !m

(* Question 13
 * (0, 806824)
 * (252, 806576)
 * (3157, 809597) *)



(* Question 14
 * 87032
 * 492348
 * 1912312 *)


(************)
(* Partie 5 *)
(************)


(* Question 15
 * 8
 * 35
 * 139 *)
