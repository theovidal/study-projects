(*
   _________  ________        ___    ___ ___    ___ 
  |\___   ___\\   __  \      |\  \  /  /|\  \  /  /|
  \|___ \  \_\ \  \|\  \     \ \  \/  / | \  \/  / /
       \ \  \ \ \   ____\     \ \    / / \ \    / / 
        \ \  \ \ \  \___|      /     \/   /     \/  
         \ \__\ \ \__\        /  /\   \  /  /\   \  
          \|__|  \|__|       /__/ /\ __\/__/ /\ __\ 
                             |__|/ \|__||__|/ \|__| 

              VIDAL Théo 861 — 17/12/2021
*)

type op =
  | Plus
  | Fois
  | Moins

type expr =
  | C of int
  | N of op * expr * expr


      (* —————————————— *)
      (*   Exercice 1   *)
      (* —————————————— *)

let e = N(
  Plus,
  N(
    Fois,
    C(6),
    C(9)
  ),
  C(19)
)

let applique op x y =
  match op with
  | Plus -> x + y
  | Moins -> x - y
  | Fois -> x * y

let rec eval expr =
  match expr with
  | C x -> x
  | N (op, exp1, exp2) -> applique op (eval exp1) (eval exp2)

      (* ———————————————— *)
      (*   Exercice 3+4   *)
      (* ———————————————— *)

(*
  Arbre du début : 
  - Infixe : (4 * (8 - 9)) + (6 + 7)
  - Préfixe : + * 4 - 8 9 + 6 7
  - Postfixe : 4 8 9 - * 6 7 + +

  1.
    a. - Préfixe : * 3 2 - 4
       - Postfixe : 3 2 - 4 *
    b. - Préfixe : * + 2 3 + 1 8
       - Postfixe : 2 3 + 1 8 + *
    c. - Préfixe : * + 2 + 3 4 - 5 6
       - Postfixe : 2 3 4 + + 5 6 - *

  2.
    a. 2 * 3 - (1 + 4)
    b. (4 - 5) * 6 + 7

  3.
    a. (2 + 3) - 4 * 5
    b. ((3 + 4) * 2 - 5) * 1
*)


      (* —————————————— *)
      (*   Exercice 5   *)
      (* —————————————— *)

type lexeme =
  | PO
  | PF
  | Op of op
  | Val of int

let rec prefixe arbre =
  match arbre with
  | C x -> [Val x]
  | N (op, expr1, expr2) -> (Op op) :: (prefixe expr1) @ (prefixe expr2)

let rec postfixe arbre =
  match arbre with
  | C x -> [Val x]
  | N (op, expr1, expr2) -> (postfixe expr1) @ (postfixe expr2) @ [Op op]

let rec infixe arbre =
  match arbre with
  | C x -> [Val x]
  | N (op, expr1, expr2) -> [PO] @ (infixe expr1) @ [Op op] @ (infixe expr2) @ [PF]

let e = N(
  Fois,
  N(
    Plus, C(2), C(3)
  ),
  N(
    Moins, C(1), C(8)
  )
)


      (* —————————————— *)
      (*   Exercice 6   *)
      (* —————————————— *)

let eval_post lexeme =
  let rec aux exp stack =
    match exp, stack with
    | [], [x] -> x
    | Op op :: tail, x :: y :: rest -> aux tail ((applique op y x) :: rest)
    | Val x :: tail, _ -> aux tail (x :: stack)
    | _ -> failwith "Lol, c'est faux!"
  in aux lexeme []


      (* —————————————— *)
      (*   Exercice 7   *)
      (* —————————————— *)

let arbre_of_post lexeme =
  let rec aux lex stack =
    match lex, stack with
    | [], [x] -> x
    | Op op :: tail, x :: y :: rest -> aux tail [N(op, x, y)]
    | Val x :: tail, _ -> aux tail ((C x) :: stack)
    | _ -> failwith "Lol, c'est faux!"
  in aux lexeme []


      (* —————————————— *)
      (*   Exercice 8   *)
      (* —————————————— *)

type var_exp =
  | N of op * var_exp * var_exp
  | C of int
  | V of int

type valuation = int array

let rec max_var expr =
  match expr with
  | C _ -> min_int
  | V i -> i
  | N (_, exp1, exp2) -> max (max_var exp1) (max_var exp2)

let rec eval_contexte expr valuation =
  match expr with
  | N (op, exp1, exp2) -> applique op (eval_contexte exp1 valuation) (eval_contexte exp2 valuation)
  | C x -> x
  | V x -> valuation.(x)

let g = N(
  Fois,
  N(
    Plus, C(2), V(0)
  ),
  N(
    Moins, V(1), C(8)
  )
)

let rec eval_partielle expr valuation =
  match expr with
  | C x -> expr
  | V x -> if x < Array.length valuation then C valuation.(x) else expr
  | N (op, exp1, exp2) ->
    match eval_partielle exp1 valuation, eval_partielle exp2 valuation with
    | C x, C y -> C (applique op x y)
    | exp1', exp2' -> N(op, exp1', exp2')
  

      (* ——————————————— *)
      (*   Exercice 10   *)
      (* ——————————————— *)

type opl = Plus | Fois

type exprl =
  | C of int
  | V of int
  | N of opl * exprl * exprl

type expr_naire =
  | Cn of int
  | Vn of int
  | Nn of opl * expr_naire list
