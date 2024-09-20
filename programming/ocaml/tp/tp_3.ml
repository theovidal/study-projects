(*
    -------------------
    TP N°3 - 21/09/2021
    -------------------
*)

(* 1.1 *)

(* méthode barbare *)
let extrema l =
  let min = ref l.(0) in
  let max = ref l.(0) in
  Array.iter (fun x -> begin
    if x < !min then min := x;
    if x > !max then max := x
  end
    ) l;
  (!min, !max);;

(* méthode smart avec builtins *)
let extrema l =
  let minL = ref l.(0) in
  let maxL = ref l.(0) in
  Array.iter (fun x -> minL := min x !minL; maxL := max x !maxL) l;
  (!minL, !maxL);;

extrema [| 4; 1; 7; 2; 10; 6 |]

(* 1.2.a *)

let nb_occs x t =
  let occs = ref 0 in
  Array.iter (fun n -> if n = x then incr occs ) t; (* incr -> incrémenter une référence d'entier *)
  !occs;;

nb_occs 5 [| 1; 2; 5; 4; 5; 12; 18 |]

(* 1.2.b *)

(* version for *)
let tab_occs t =
  let n = Array.length t in
  let occs = Array.make n 0 in
  for i = 0 to (n - 1) do
    occs.(i) <- nb_occs i t
  done;
  occs;;

(* version iter *)
let tab_occs t =
  let n = Array.length t in
  let occs = Array.make n 0 in
  Array.iteri (fun i _ -> occs.(i) <- nb_occs i t) occs;
  occs;;

tab_occs [| 1; 2; 5; 4; 5; 12; 18|]

(* 1.2.d *)

let tab_occs_eff t =
  let n = Array.length t in
  let occs = Array.make n 0 in
  Array.iter (fun x -> if x < n then occs.(x) <- occs.(x) + 1) t;
  occs;;

tab_occs_eff [| 1; 2; 5; 4; 5; 12; 6|]

(* 2 *)

(* version iter *)
let sommes_cumulees t =
  let cumulees = Array.make (Array.length t) 0 in
  Array.iteri (fun i x ->
    cumulees.(i) <- x +
    if i > 0 then cumulees.(i - 1) else 0
    ) t;
  cumulees;;

(* version for *)
let sommes_cumulees t =
  let n = Array.length t in
  let cumulees = Array.make n t.(0) in
  for i = 1 to (n - 1) do
    cumulees.(i) <- t.(i) + cumulees.(i - 1)
  done;
  cumulees;;

sommes_cumulees [|2; 1; 0; 7; 10|]

(* 3.1 *)

let map f t =
  let n = Array.length t in
  let m = Array.make n (f t.(0)) in (* Bien utiliser la fonction pour obtenir le type b *)
  for i = 0 to (n - 1) do
    m.(i) <- f t.(i)
  done;
  m;;

map (fun i -> 2 * i) [|1; 2; 3; 4|]

(* 3.2 *)

let init n f =
  let t = Array.make n (f 0) in
  for i = 1 to (n - 1) do
    t.(i) <- f i
  done;
  t;;

init 5 (fun i -> i * i)

(* 3.3 *)

let to_list t =
  let l = ref [] in
  for i = (Array.length t) - 1 downto 0 do
    l := t.(i) :: !l
  done;
  !l;;

to_list [|2; 5; 1|]

(* 3.4 *)

let of_list u =
  match u with
  | [] -> [||]
  | x :: xs ->
    let n = List.length u in
    let t = Array.make n x in
    let rec aux v k = (* quand on parcours une liste, il faut une fonction auxiliaire pour garder l'indice *)
      match v with
      | [] -> t
      | y :: ys -> t.(k) <- y; aux ys (k + 1) in
    aux xs 1;;

of_list [2; 5; 1; 3; 4]

(* 4.1 *)

let somme u = List.fold_left (fun a x -> a + x) 0 u;;
let produit u = List.fold_left (fun a x -> a * x) 1 u;;

(* 4.2 *)

let applatit l = List.fold_right (fun u res -> u @ res) l [];;
applatit [[2; 3]; [5; 5]; [2]]

(* 4.3 *)

let max_liste l = match l with
  | [] -> min_int
  | _ -> List.fold_left (fun a x -> max a x) 0 l;;
 
max_liste [4; 2; 7; 6; 1; 8; 2; 9; 3; 5]

(* 4.4 *)

let rec reduction f  
