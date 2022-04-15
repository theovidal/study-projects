(*
   _________  ________        ___    ___ ___       ___     
  |\___   ___\\   __  \      |\  \  /  /|\  \     |\  \    
  \|___ \  \_\ \  \|\  \     \ \  \/  / | \  \    \ \  \   
       \ \  \ \ \   ____\     \ \    / / \ \  \    \ \  \  
        \ \  \ \ \  \___|      /     \/   \ \  \____\ \  \ 
         \ \__\ \ \__\        /  /\   \    \ \_______\ \__\
          \|__|  \|__|       /__/ /\ __\    \|_______|\|__|
                             |__|/ \|__|                   
                                                           
                        15/04/2022
*)

type formule =
  | Const of bool
  | Var of string
  | Et of formule * formule
  | Ou of formule * formule
  | Non of formule

let antinomie =
  Et (Non (Var "x"),
      Et (Ou (Et (Var "z", Var "x"),
              Var "y"),
          Et (Non (Var "y"),
              Non (Var "z")
              )
          )
  )
let ex1 =
  Et (Var "x",
      Et (Var "y",
          Et (Non (Var "z"),
              Var "t")
          )
  )
let ex2 =
  Et (
    Et (Var "x",
        Ou (Non (Var "y"),
            Ou (Var "z",
                Non (Var "x"))
            )
        ),
    Non (Var "t")
  )
let ex3 =
  Et (
    Non (Var "t"),
    Et (Ou (Ou (Var "z",
                Non (Var "x")),
            Non (Var "y")),
        Var "x")
  )
let gros_ex1 =
  Ou (antinomie,
      Et (ex1,
          Et (ex2, ex2)
          )
    )
let gros_ex2 =
  Ou (Et (Et (ex3, ex1),
          ex2),
      antinomie)
let gros_ex3 =
  Ou (Et (Non ex1, Ou (Var "u", Var "x")), Ou (gros_ex1, gros_ex2))  

let rec string_of_formule = function
  | Const b -> Printf.sprintf "%b" b
  | Var v -> v
  | Et (f, g) -> Printf.sprintf "(%s et %s)" (string_of_formule f) (string_of_formule g)
  | Ou (f, g) -> Printf.sprintf "(%s ou %s)" (string_of_formule f) (string_of_formule g)
  | Non f -> Printf.sprintf "non %s" (string_of_formule f)

let priorite = function
  | Var _ | Const _ -> max_int
  | Ou _ -> 0
  | Et _ -> 1
  | Non _ -> 2

let rec string_priorite u =
  let rec aux f prio_parent =
    (* Attention au sens de l'inégalité! Si la priorité de l'enfant est inférieure, il faut parenthéser autour *)
    if priorite f < prio_parent then Printf.sprintf "(%s)" (string_priorite f)
    else string_priorite f
  in
  match u with
  | Const b -> Printf.sprintf "%b" b
  | Var v -> v
  | Ou (f, g) -> Printf.sprintf "%s ou %s" (aux f 0) (aux g 0)
  | Et (f, g) -> Printf.sprintf "%s et %s" (aux f 1) (aux g 1)
  | Non f -> Printf.sprintf "non %s" (aux f 2)


(* Exercice 2 *)

let rec egal_com f g =
  match f, g with
  | Var u, Var v -> u = v
  | Const b, Const b' -> b = b'
  (* Vérifier séparément l'égalité composante à composante OU composantes croisées *)
  | Et (f1, f2), Et (g1, g2) | Ou (f1, f2), Ou (g1, g2) -> (egal_com f1 g2 && egal_com f2 g1) || (egal_com f1 g1 && egal_com f2 g2)
  | Non f1, Non g1 -> egal_com f1 g1
  | _ -> false

(* Exercice 3 *)

type formule_asso =
  | C of bool
  | V of string
  | EtA of formule_asso list
  | OuA of formule_asso list
  | N of formule_asso

let rec insere x u =
  match u with
  | [] -> [x]
  | y :: ys when y <= x -> y :: insere x ys
  | y :: ys -> x :: y :: ys

let rec fusionne u v =
  match u, v with
  | [], l | l, [] -> l
  | x :: xs, y :: ys when x < y -> x :: fusionne xs v
  | x :: xs, y :: ys -> y :: fusionne u ys

(* Exercice 4 *)

let rec canonique = function
   | Const b -> C b
   | Var v -> V v
   | Non f -> N (canonique f)
   | Et (f, g) -> 
    let can_f = canonique f in
    let can_g = canonique g in begin
      match can_f, can_g with
      | EtA f', EtA g' -> EtA (fusionne f' g')

      (* Si une autre expression parmi un Et, on l'insère au milieu (pour que ça soit trié) *)
      | EtA f', _ -> EtA (insere can_g f')
      | _, EtA g' -> EtA (insere can_f g')
    
      (* On veut trié dans tous les cas -> utiliser fusionne *)
      | _ -> EtA (fusionne [can_f] [can_g])
    end
  | Ou (f, g) ->
    let can_f = canonique f in
    let can_g = canonique g in begin
      match can_f, can_g with
      | OuA f', OuA g' -> OuA (fusionne f' g')
      | OuA u', _ -> OuA (insere can_g u')
      | _, OuA u' -> OuA (insere can_f u')
      | _ -> OuA (fusionne [can_f] [can_g])
    end

let ex =
  Et(
    Et(Const true, Const true),
    Const true
  )

(* La forme canonique est définie de manière unique, *)
(* donc on a juste à vérifier l'égalité *)
let egal_syntaxe f g = (canonique f) = (canonique g)
