(* I. Nombres en binaire *)

type bit = Z | U
type nombre = bit list

let rec succ = function
  | [] -> [U]
  | U :: xs -> Z :: (succ xs)
  | Z :: xs -> U :: xs

let rec pred = function
  | [] -> failwith "Nombre vide"
  | U :: xs -> Z :: xs
  | Z :: xs -> U :: (pred xs)


(* II. Listes binaires à accès direct *)

type 'a arbre =
  | F of 'a
  | N of int * 'a arbre * 'a arbre

let exemple = N(
  8,
  N( 4, 
    N(2, F 1, F 4),
    N(2, F 9, F 16)
  ),
  N( 4,
    N(2, F 25, F 36),
    N(2, F 49, F 64)
    )
)

let rec get_arbre u i =
  match u with
  | F a -> a
  | N (size, _, _) when i >= size -> failwith "dépassement"
  | N (size, _, right) when i >= size / 2 -> get_arbre right (i - size/2)
  | N (size, left, _) -> get_arbre left i

let rec set_arbre u i x =
  match u with
  | F _ -> F x
  | N (size, _, _) when i >= size -> failwith "dépassement"
  | N (size, left, right) when i >= size / 2 -> N (size, left, set_arbre right (i - size / 2) x)
  | N (size, left, right) -> N (size, set_arbre left (i - size / 2) x, right)

type 'a chiffre = Ze | Un of 'a arbre
type 'a liste_binaire = 'a chiffre list

let a = F 100
let b = N (2, F 50, F 25)
let c = exemple
let li = [Un a; Un b; Ze; Un c]
let size = function
  | F _ -> 1
  | N (n, _, _) -> n

(* A chaque arbre qui ne correspond pas, on soustrait sa taille à l'indice (taille = nombre d'éléments) *)
let rec get li i =
  match li with
  | [] -> failwith "dépassement"
  | Ze :: xs -> get xs i
  | Un arbre :: xs when size arbre <= i -> get xs (i - size arbre)
  | Un arbre :: xs -> get_arbre arbre i

let rec set li i x =
  match li with
  | [] -> failwith "dépassement"
  | Ze :: xs -> Ze :: (set xs i x)
  | Un arbre :: xs when size arbre <= i -> Un arbre :: set xs (i - size arbre) x
  | Un arbre :: xs -> Un (set_arbre arbre i x) :: xs

(* Opère la fusion successive des arbres (comme la fonction successeur, mais pas avec des chiffres) *)
let rec cons_arbre li a =
  match li with
  | [] -> [Un a]
  | Ze :: xs -> Un a :: xs
  | Un x :: xs -> Ze :: cons_arbre xs (N (2 * size x, a, x))

let cons li x = cons_arbre li (F x)

(* À chaque appel, on laisse le droite dans la liste, et on extrait le gauche *)
let rec uncons_arbre = function
  | [] -> failwith "dépassement"
  | Un a :: xs -> (a, Ze :: xs)
  | Ze :: xs ->
    let t, ts = uncons_arbre xs in
    match t with
    | N (_, g, d) -> (g, Un d :: ts)
    | _ -> failwith "impossible"


let rec uncons t =
  match t with
  | [Un (F x)] -> x, []
  | _ ->
    match uncons_arbre t with
    | (F x, xs) -> x, xs
    | _ -> failwith "impossible"

let head t = fst (uncons t)
let tail t = snd (uncons t)
