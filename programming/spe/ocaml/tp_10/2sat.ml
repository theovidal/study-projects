type litteral =
  | P of int
  | N of int

type clause = litteral * litteral
type twocnf = clause list
type valuation = bool array

let eval_litt l v =
  match l with
  | P i -> v.(i)
  | N i -> not v.(i)

let rec eval f v =
  match f with
  | [] -> true
  | (p, q) :: xs -> (eval_litt p v || eval_litt q v) && eval xs v

exception Last
let increment_valuation v =

let id = function
| P i -> 2 * i
| N i -> 2 * i + 1

let no = function
| P i -> N i
| N i -> P i

let rec max_id f =
  match f with
  | [] -> -1
  | (p, q) :: xs -> max (max (id p) (id q)) (max_id xs)

let graph_of_cnf f =
  let n = max_id f + 2 in
  let g = Array.make n [] in

  let rec aux = function
    | [] -> ()
    | (p, q) :: xs ->
      g.(id (no q)) <- (id p) :: g.(id (no q));
      g.(id (no p)) <- (id q) :: g.(id (no p)) ; aux xs

  in aux f;
  g

let satisfiable f = 
  let g = graph_of_cnf f in
  let comps = kosaraju g in
  List.iter (fun ) 

let f = [(P 0, N 2); (P 1, P 3); (N 1, P 2); (N 2, P 3); (P 3, N 0)]
