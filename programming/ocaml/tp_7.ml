(*
    -------------------
    TP N°7 - 12/10/2021
    -------------------
*)

(* Exercice 1 *)

(* 1.1 *)
let rec pour_tout pred u = match u with
  | [] -> true
  | x :: xs -> pred x && pour_tout pred xs

let () =
  assert (pour_tout (fun x -> x mod 2 = 0) [2; 4; 6; 8; 10] = true);
  assert (pour_tout (fun x -> x mod 2 = 0) [2; 4; 6; 7; 10] = false)


(* 1.2 *)
let rec existe pred u = match u with
  | [] -> false
  | x :: xs -> pred x || existe pred xs

let () =
  assert (existe (fun x -> x mod 2 = 1) [2; 4; 6; 8; 10] = false);
  assert (existe (fun x -> x mod 2 = 0) [2; 4; 6; 7; 10] = true)


(* 1.3 *)
let rec filtre pred u = match u with
  | [] -> []
  | x :: xs when pred x -> x :: filtre pred xs
  | _ :: xs -> filtre pred xs

let () =
  assert (filtre (fun x -> x mod 2 = 0) [1; 2; 3; 4; 5] = [2; 4]);
  assert (filtre (fun x -> x mod 2 = 1) [1; 2; 3; 4; 5] = [1; 3; 5]);


(* Exercice 2 *)

(* 2.1 -> on peut remplacer le fun... par (=) *)
let appartient u n = existe (fun x -> x = n) u

(* 2.2 -> tous les éléments de u sont représentés au moins une fois dans v *)
let inclus u v = pour_tout (appartient v) u

(* 2.3 -> double inclusion *)
let egal u v = inclus u v && inclus v u

(* 
  inclus est en complexité O(|u| * |v|)
  donc egal est en complexité O(|u| * |v|)
*)

(* 2.4 -> on peut curryfier en enlevant le u *)
let inter v u = filtre (appartient v) u

(* 
  filtre est en complexité n, appartient est en complexité p
  donc inter est en complexité O(|u| * |v|)
*)

(* 2.5 *)
let prive_de v = filtre (fun x -> not (appartient v x))

let () =
  assert (prive_de [1; 3; 5] [1; 2; 3; 4] = [2; 4])

(* 2.6 *)
let union u v = u @ v
let union = (@)

(* union est en complexité O(|u|) *)


(* Exercice 3 *)

(* 3.1 -> rajout du cas d'égalité par rapport au tri fusion pour conserver la croissance stricte *)
let rec union u v = match u, v with
  | [], x | x, [] -> x
  | x :: xs, y :: ys when x < y -> x :: union xs v
  | x :: xs, y :: ys when x = y -> y :: union xs ys (* Les listes sont strictement croissantes : éléments uniques donc on en mets un et on passe au reste*)
  | x :: xs, y :: ys -> y :: union u ys

let () =
  assert (union [1; 2; 3; 5; 7] [2; 3; 4; 8] = [1; 2; 3; 4; 5; 7; 8])

(* 3.2 -> on exploite la croissance pour avancer une liste ou l'autre en fonction de qui est plus grand *)
let rec inter u v = match u, v with
  | [], _ | _, [] -> []
  | x :: xs, y :: ys when x = y -> x :: inter xs ys
  | x :: xs, y :: _ when x < y -> inter xs v
  | _, _ :: ys -> inter u ys

let () =
  assert (inter [1; 3; 4; 5; 6] [2; 4; 6; 8] = [4; 6])

(* 3.3 *)
let rec prive_de u v = match u, v with
  | [], _ | _, [] -> u
  | x :: xs, y :: ys when x = y -> prive_de xs ys
  | x :: xs, y :: ys when x < y -> x :: prive_de xs v
  | x :: xs, y :: ys -> prive_de u ys

prive_de [1; 2; 4; 5; 9; 10] [2; 4; 6; 8]


(* Exercice 4 *)

(* 4.1 *)
let rec inclus u v = match u, v with
  | [], _ -> true
  | _, [] -> false
  | x :: xs, y :: ys when x = y -> inclus xs ys
  | x :: _, y :: ys when x < y -> inclus u ys
  | x :: _, y :: _ -> false

(* 4.2 -> listes strictement croissantes : pas de doublons -> les listes peuvent donc être strictement égales *)
let egal = (=)

(* 4.3
  inclus parcours entièremment les deux listes dans le pire des cas, sa complexité est O(|u| + |v|)
  egal parcours entièremment la liste la plus petite, sa complexité est O(|u|) ou O(|v|) (linéaire)
*)

(* Exercice 5 *)

let rec eclate u = match u with
  | [] -> [], []
  | [x] -> [x], []
  | x :: y :: xs -> let a, b = eclate xs in x :: a, y :: b

let rec tri_uniques u = match u with
  | [] | [_] -> u
  | _ -> let a, b = eclate u in
    union (tri_uniques a) (tri_uniques b)

tri_uniques [4; 6; 2; 8; 2; 9; 0; 1; 3]
