let max u =
  let rec max_aux u n =
    match u with
    | [] -> n
    | x :: xs when x > n -> max_aux xs x
    | _ :: xs -> max_aux xs n in
  max_aux u min_int

let extrema u =
  let rec extrema_aux u min max =
    match u with
    | [] -> min, max
    | x :: xs when x <= min && x >= max -> extrema_aux xs x x (* pas sûr que ce cas soit juste *)
    | x :: xs when x < min -> extrema_aux xs x max
    | x :: xs when x > max -> extrema_aux xs min x
    | _ :: xs -> extrema_aux xs min max in
  extrema_aux u max_int min_int

let (<|>) a b =
  let rec aux u i =
    if i < a then u
    else aux (i :: u) (i - 1) in
  aux [] (b - 1)

(* rev append en récursion terminale *)
let (<@|) u v =
  let rec aux u v =
    match u with
    | [] -> v
    | x :: xs -> aux xs (x :: v) in
  aux u v

let (@|) u v = (u <@| []) <@| v

let map f u =
  let rec aux u l =
    match u with
    | [] -> l
    | x :: xs -> aux xs (f x :: l) in
  aux u [] <@| []


(* Est récursive terminale *)
let rec fold_left f acc u =
  match u with
  | [] -> acc
  | x :: xs -> fold_left f (f acc x) xs

(* N'est pas récursive terminale *)
(* On peut le faire en effectuant d'abord un miroir de la liste *)
let rec fold_right f u acc =
  match u with
  | [] -> acc
  | x :: xs -> f x (fold_right f xs acc)

let fold_right f u acc = fold_left f acc (u <@| [])

let produit_liste u = fold_left (fun x acc -> x * acc) 1 u
let nb_positifs u = fold_left (fun acc x -> if x < 0 then acc else 1 + acc) 0 u

let flatten u = fold_left (fun acc xs -> acc @| xs) [] u

let flatten_right u = fold_right (fun acc xs -> xs @| acc) u []

(* Non récursive terminale *)
let rec partitionne_nt u f =
  match u with
  | [] -> [], []
  | x :: xs ->
    let oui, non = partitionne_nt xs f in
    if f x then x :: oui, non
    else oui, x :: non

(* Récursive terminale *)
let partitionne u f =
  let rec aux u oui non =
    match u with
    | [] -> oui, non
    | x :: xs when f x -> aux xs (x :: oui) non
    | x :: xs -> aux xs oui (x :: non) in
  aux (u <@| []) [] []

let rec separe u =
  let rec aux u one two =
    match u with
    | [] -> one, two
    | [x] -> x :: one, two
    | x :: y :: xs -> aux xs (x :: one) (y :: two) in
  aux u [] []

let rec fusionne u v =
  let rec aux u v l =
    match u, v with
    | [], _ -> l <@| v
    | _, [] -> l <@| u
    | x :: xs, y :: ys ->
      if x <= y then aux xs v (x :: l)
      else aux u ys (y :: l) in
  aux u v []

let rec tri_fusion = function
  | [] -> []
  | [x] -> [x]
  | u ->
    let a, b = separe u in
    fusionne (tri_fusion a) (tri_fusion b)
