let m = (1 lsl 20) - 3

let genere_u () =
  let u = Array.make 2000000 42 in
  for i = 1 to 2000000 - 1 do
    u.(i) <- 1022 * u.(i - 1) mod m
  done;
  u
  
let u = genere_u ()

type coarbre_binaire =
  | F
  | N of bool * coarbre_binaire * coarbre_binaire

let rec cree_coarbre_binaire n k =
  if n = 1 then F else
  let i = 1 + (u.(k) mod (n - 1)) in 
  N (u.(k+1) mod 2 = 1, cree_coarbre_binaire i (k + 2), cree_coarbre_binaire (n - i) (k + 2 * i))
  
let rec hauteur = function
  | F -> 0
  | N (_, g, d) -> 1 + max (hauteur g) (hauteur d)

let rec nb_noeuds = function
  | F -> 1
  | N (_, g, d) -> 1 + nb_noeuds g + nb_noeuds d

let rec nb_feuilles = function
  | F -> 1
  | N (_, g, d) -> nb_feuilles g + nb_feuilles d

let degre t =
  (* Fonction auxiliaire renvoyant pour un arbre :
    - le nombre de feuilles, ce qui permet d'être plus efficace sur les calculs
    - le nombre d'arêtes
    - le degré maximum
  *)
  let rec aux = function
  | F -> (1, 0, 0)
  | N (k, g, d) ->
    let (n1, p1, m1) = aux g in
    let (n2, p2, m2) = aux d in
    if k = 0 then (* cas où aucune arête ne sera formée à ce noeud *)
      (n1 + n2, p1 + p2, max m1 m2)
    else (* cas où on forme des arêtes *)
      (n1 + n2, p1 + p2 + n1 * n2, max (m1 + n2) (m2 + n1))
  in 
  let (_, p, f) = aux t in
  p, f

let rec clique = function
  | F -> 1
  | N (k, g, d) ->
    if k = 0 then max (clique g) (clique d)
    else clique g + clique d

let rec moyenne n =
  let m = ref 0. in
  for k = 1 to 1000 do
    m := float_of_int (clique (cree_arbre n k)) /. 1000. +. !m
  done;
  !m

type coarbre =
  | L
  | I of bool * coarbre list

let remonte kp t =
  match t with
  | L -> [L]
  | I (k, u) when k = kp -> u
  | _ -> t

let rec canonise = function
  | F -> L
  | N (k, g, d) ->
    let tg = canonise g in
    let td = canonise d in
    I (k, remonte k tg @ remonte k td)
  
let rec nb_noeuds = function
  | L -> 1
  | I (_, c) -> List.fold_left (fun acc t -> nb_noeuds t + acc) 1 c

let plus_petit_k n =
  let t_ref = canonise (cree_coarbre_binaire n 0) in
  let rec aux k =
    if t_ref = canonise (cree_coarbre_binaire n k) then k
    else aux (k + 1)
  in aux 1
