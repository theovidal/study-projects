(*
    --------------------------
    DM N°1 - Pour le 28/09/2021
    ---------------------------
*)

(* 2.1 *)

let rec nb_occs x u = match u with
  | [] -> 0
  | y :: ys when x = y -> 1 + nb_occs x ys
  | _ :: ys -> nb_occs x ys

let rec nb_condition predicat u = match u with
  | [] -> 0
  | y :: ys when predicat y -> 1 + nb_condition predicat ys
  | _ :: ys -> nb_condition predicat ys;;

let rec nb_occs x u = nb_condition (fun y -> y = x) u;;

(* 2.2 *)

let rec nb_distincts u = match u with
  | [] -> 0
  | y :: ys -> nb_distincts ys + 
    if nb_occs y ys = 0 then 1 else 0

let rec nb_distincts_triee u = match u with
  | [] -> 0
  | [_] -> 1
  | x :: y :: ys when x <> y -> 1 + nb_distincts_triee (y :: ys)
  | _ :: ys -> nb_distincts_triee ys

(* version foireuse *)

let max_occs_triee u =
  match u with
  | [] -> 0
  | x :: xs ->
    let rec aux u x n occs = match u with
      | [] -> occs
      | [y] -> if y = x then max n occs else max 1 occs
      | y :: z :: xs when y <> z -> aux xs z 1 (occs + 1)
      | y :: ys ->
        let incr = n + 1 in
        if incr > occs then aux ys y incr incr
        else aux ys x incr occs in
    aux xs x 1 1;;

(* version "clean" *)

let max_occs_triee u =
  let rec aux u n occs = match u with
    | [] -> occs
    | x :: y :: [] when x = y -> max (n + 2) occs
    | x :: y :: [] -> max 1 occs
    | x :: y :: xs when x <> y -> aux (y :: xs) 0 (max (n + 1) occs)
    | _ :: xs -> aux xs (n + 1) (max (n + 1) occs) in
  aux u 0 0;;
  
max_occs_triee [1; 2; 2; 3; 3];;                 (* -> 2 *)
max_occs_triee [2; 1; 1; 1];;                    (* -> 3 *)
max_occs_triee [2; 2; 3; 3; 3; 4; 5; 5];;        (* -> 3 *)
max_occs_triee [2; 2; 3; 3; 3; 4; 5; 5; 5];;     (* -> 3 *)
max_occs_triee [2; 2; 3; 3; 3; 4; 5; 5; 5; 5];;  (* -> 4 *)

(* 3.1 *)

let somme_par_ligne t =
  let n = Array.length t
  let s = Array.make n 0 in
  Array.iteri (fun i x -> s.(i) <- Array.fold_left (fun acc y -> y + acc) 0 x) t;
  s;;

somme_par_ligne [| [|1; 2; 3|]; [|4; 10|]; [||]; [|7|] |]

(* 3.2 *)

let somme_partielle t deb fin =
  let s = ref 0 in
  for k = deb to fin - 1 do
    s := !s + t.(k)
  done;
  !s;;

somme_partielle [| 1; 1; 1; 1; 1; 1; 1|] 1 5

let somme_max t =
  let n = Array.length t in
  let res = ref 0 in
  for j = 0 to n do
    for i = 0 to j do
      res := max (somme_partielle t i j) !res
    done;
  done;
  !res;;

somme_max [| -1000; 300; -200; 500; -1000 |]
somme_max [| 1; 7; 6; 2; 5; 4; 3; 8|] (* Résultat : 36 *)

let somme_max_rapide t =
  let current = ref 0 in
  let m = ref 0 in
  for i = 0 to Array.length t - 1 do
    current := max 0 (!current + t.(i));
    m := max !current !m
  done;
  !m;;

somme_max_rapide [|1; 3; -7; 10; 9; -3; 2|]
somme_max_rapide [| -1000; 300; -200; 500; -1000 |]
