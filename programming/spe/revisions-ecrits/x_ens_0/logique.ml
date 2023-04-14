type formula =
| True
| False
| If of int * formula * formula

let f1 = If(0, If(1, False, True), If(2, True, False))

let f2 = If(0, If(1, False, True), If(0, True, False))

let check n f =
  let rec aux i0 = function
    | True | False -> true
    | If (i, _, _) when i >= n -> false
    | If (i, _, _) when i <= i0 -> false
    | If (i, f, g) -> aux i f && aux i g
  in aux (-1) f

type assignment = bool array
type result = Tautology | Refutation of assignment

(* test qui allait devenir foireux *)
let trileen = | Vrai | Faux | Indetermine

let eval v = function
  | True -> Vrai
  | False -> Faux
  | If (i, f, g) -> begin
    match v.(i) with
    | Vrai -> eval n f
    | Faux -> eval n g
    | Indetermine -> Indetermine

exception Refuted

(* La formule étant ordonnée, il suffit de vérifier si elle contient un Faux *)
let decide n f =
  let v = Array.make n false in
  let rec aux = function
    | True -> ()
    | False -> raise Refuted
    | If (i, f', g') ->
      v.(i) <- true;
      aux f';
      v.(i) <- false;
      aux g'
  in try
    aux f;
    Tautology
  with
  | Refuted -> Refutation v

let rec mk_not = function
  | True -> False
  | False -> True
  | If (i, f, g) -> If (i, mk_not g, mk_not f)

let rec n_of_formula = function
  | True | False -> 0
  | If (i, f, g) -> max (i + 1) (max (n_of_formula f) (n_of_formula g))

(* Renvoie la formule associée aux choix de valeurs de vérité pour les variables indicées par 0,...,m *)
(* v est une valuation telle que les valeurs de vérité des m+1 premières variables ont été choisies (le reste étant ignoré) *)
let rec sub v m f =
  match f with
  | If (i, _, _) when i > m -> f
  | If (i, f, g) -> if v.(i) then sub v m f else sub v m g
  | _ -> f
  
let rec mk_or f g = 
  let n = max (n_of_formula f) (n_of_formula g) in
  let v = Array.make n false in
  let rec aux m = function
  | True -> True
  | False -> sub v m g
  | If (i, t', f') ->
    v.(i) <- true;
    let t'' = aux i t' in
    v.(i) <- false;
    let f'' = aux i f' in
    If (i, t'', f'')
  in aux 0 f
