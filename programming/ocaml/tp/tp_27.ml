type 'a bst =
  | V
  | N of 'a * 'a bst * 'a bst

let exemple = N(
  12,
  N(5, 
    N(3, V, V),
    N(7, V, V)
  ),
  N(14, V, V)
)

(* Exercice 1 *)

let rec insert t a =
  match t with
  | V -> N (a, V, V)
  | N (x, l, r) when x = a -> N (x, l, r)
  | N (x, l, r) when a < x -> N (x, insert l a, r)
  | N (x, l, r) -> N (x, l, insert r a)

let rec contains t a =
  match t with
  | V -> false
  | N (x, _, _) when x = a -> true
  | N (x, l, _) when a < x -> contains l a
  | N (x, _, r) -> contains r a

let rec cardinal = function
  | V -> 0
  | N (_, l, r) -> 1 + cardinal l + cardinal r

(* Exercice 2 *)

let build u =
  let rec aux u t =
    match u with
    | [] -> t
    | x :: xs -> aux xs (insert t x)
  in aux u V

(* Éviter les List.rev : on traite la droite, puis la gauche avec résultat+x *)
let elements t =
  let rec aux u t =
    match t with
    | V -> u
    | N (x, l, r) ->
      let r' = aux u r in
      aux (x :: r') l in
  aux [] t


(* Exercice 3 *)

let rec extract_min t =
  match t with
  | V -> failwith "arbre vide"
  | N (x, V, V) -> (x, V)
  | N (x, l, r) ->
    let (min, rest) = extract_min l in
    (min, N (x, rest, r))

let rec delete t a =
  match t with
  | V -> V
  | N (x, l, V) -> l
  | N (x, V, r) -> r
  | N (x, l, r) when a < x -> N (x, delete l a, r)
  | N (x, l, r) when a > x -> N (x, l, delete r a)
  | N (x, l, r) ->
    let (min, r') = extract_min r in
    N (min, l, r')


(* Exercice 4 *)

let rec split t a =
  match t with
  | V -> (V, V)
  (* ici, on traite le gauche car le droit est entièrement supérieur *)
  (* Le supérieur est constitué à gauche du sup_l et à droite de r pour garder la prop d'ABR (max gauche inférieur au min droite) *)
  | N (x, l, r) when a <= x ->
    let inf_l, sup_l = split l a in
    inf_l, N (x, sup_l, r)
  | N (x, l, r) ->
    let inf_r, sup_r = split r a in
    N (x, l, inf_r), sup_r


(* Exercice 5 *)
(* Complexité O(|t|) *)
let verifie_abr t =
    let rec croissant = function
    | x :: y :: xs -> (x < y) && croissant xs
    | _ -> true
  in croissant (elements t)

let tab_elements t = Array.of_list (elements t)

(* Complexité O(h(t)) *)


(* Exercice 6 *)

type ('k, 'v) dict =
  | Empty
  | Node of ('k, 'v) dict * 'k * 'v * ('k, 'v) dict

let rec get dict x =
  match dict with
  | Empty -> None
  | Node (l, k, _, _) when x < k -> get l x
  | Node (_, k, _, r) when x > k -> get r x
  | Node (_, _, v, _) -> Some v

let rec set dict key x =
  match dict with
  | Empty -> Node (Empty, key, x, Empty)
  | Node (l, k, v, r) when key < k -> Node (set l key x, k, v, r)
  | Node (l, k, v, r) when key > k -> Node (l, k, v, set r key x)
  | Node (l, k, v, r) -> Node (l, k, x, r)

let rec extract_min_dict dict =
  match dict with
  | Empty -> failwith "empty dict"
  | Node (Empty, k, v, r) -> (k, v), r
  | Node (l, k, v, r) ->
    let min, l' = extract_min_dict l in
    min, Node (l', k, v, r)

let rec remove dict key =
  match dict with
  | Empty -> Empty
  | Node (Empty, k, v, r) -> r
  | Node (l, k, v, Empty) -> l
  | Node (l, k, v, r) when key < k -> Node (remove l key, k, v, r) 
  | Node (l, k, v, r) when key > k -> Node (l, k, v, remove r key)
  | Node (l, k, v, r) -> 
    let (k_min, v_min), r' = extract_min_dict r in
    Node (l, k_min, v_min, r')

let get_occurrences dict key =
  match get dict key with
  | None -> 0
  | Some i -> i

let add_occurrence dict key = set dict key (get_occurrences dict key + 1)
let rem_occurrence dict key =
  let occurrence = get_occurrences dict key in
  if occurrence <> 0 then set dict key (occurrence - 1)
  else remove dict key

let rec size = function
  | Empty -> 0
  | Node (l, _, v, r) -> v + size l + size r


(* Exercice 8 *)

type 'a multiset =
  | Empty
  | Node of int * 'a multiset * 'a * int * 'a multiset

let rec get_occurrences set key =
  match set with
  | Empty -> 0
  | Node (_, _, k, v, _) when k = key -> v
  | Node (_, l, k, _, _) when k < key -> get_occurrences l key
  | Node (_, _, _, _, r) -> get_occurrences r key
  
let rec add_occurrence set key = 
  match set with
  | Empty -> Node (1, Empty, key, 1, Empty)
  | Node (n, l, k, v, r) when k = key -> Node (n + 1, l, k, v + 1, r)
  | Node (n, l, k, v, r) when k < key -> Node (n + 1, add_occurrence l key, k, v, r)
  | Node (n, l, k, v, r) -> Node (n + 1, l, k, v, add_occurrence r key)

let rec extract_min_set = function
  | Empty -> failwith "empty set"
  | Node (_, Empty, k, v, r) -> (k, v), r
  | Node (n, l, k, v, r) ->
    let min, l' = extract_min_set l in
    min, Node (n - 1, l', k, v, r)

let rec remove_occurrence set key =
  match set with
  | Empty -> Empty
  | Node (_, Empty, _, _, m') | Node (_, m', _, _, Empty) -> m'
  | Node (n, l, k, v, r) when key < k -> Node (n - 1, remove_occurrence l key, k, v, r)
  | Node (n, l, k, v, r) when key > k -> Node (n - 1, l, k, v, remove_occurrence r key)
  | Node (n, l, k, v, r) ->
    let (k_min, v_min), r' = extract_min_set r in
    Node (n - 1, l, k_min, v_min, r')

let size = function
  | Empty -> 0
  | Node (n, _, _, _, _) -> n

let rec select set i =
  match set with
  | Empty -> failwith "invalid index"
  | Node (_, l, k, v, r) ->
    if i < size l then select l i
    else if i < size l + v then k
    else select r (i - size l - v)
