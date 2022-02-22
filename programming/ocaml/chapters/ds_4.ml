type delta = Z | P | M

type 'a avl =
  | E
  | N of delta * 'a * 'a avl * 'a avl

let rec member x avl =
  match avl with
  | E -> false
  | N (_, n, _, _) when x = n -> true
  | N (_, n, l, _) when x < n -> member x l
  | N (_, n, _, r) -> member x r


let elements avl =
  let rec aux avl tokens =
    match avl with
    | E -> tokens
    | N (_, n, l, r) ->
      aux l (n :: aux r tokens)
  in aux avl []


let check_order avl =
  let rec increasing = function
  | [] | [_] -> true
  | x :: y :: xs -> x < y && increasing xs
  in increasing (elements avl)

(* A la limite au lieu de calculer la hauteur et faire le match, simplement 
vérifier if b = M then ... avec la hauteur calculée en fonction de la situation *)
let check_balance t =
  let rec aux = function
  | E -> (-1, true)
  | N (b, _, l, r) ->
    let hl, bl = aux l in
    let hr, br = aux r in
    let height = 1 + max hl hr in
    height, bl && br && begin
      match b with
      | Z -> hl = hr
      | P -> hr = hl + 1
      | M -> hr = hl - 1
    end
  in
  let _, balanced = aux t in
  balanced

let check_avl t = check_order t && check_balance t

let rec height = function
  | E -> -1
  | N (Z, _, _, r) | N (P, _, _, r) -> 1 + height r
  | N (M, _, l, _) -> 1 + height l

let fix_MM = function
  | N (M, z, N(P, x, a, N(dy, y, b, c)), d) ->
    let dx = if dy = P then M else Z in
    let dz = if dy = M then P else Z in
    N (Z, y, N(dx, x, a, b), N(dz, z, c, d)), false
  | N (M, y, N(d, x, a, b), c) -> 
    let dx = if d = Z then P else Z in
    let dy = if d = Z then M else Z in
    let flag = (d = Z) in
    N (dx, x, a, N(dy, y, b, c)), flag
  | _ -> failwith "fix_MM : impossible"

let fix_PP = function
  | N (P, x, a, N (M, z, N(dy, y, b, c), d)) ->
    let dx = if dy = M then P else Z in
    let dz = if dy = P then M else Z in
    N (Z, y, N(dx, x, a, b), N(dz, z, b, c)), true
  | N (P, x, a, N(d, y, b, c)) ->
    let dx = if d = Z then P else Z in
    let dy = if d = Z then M else Z in
    let flag = (d = Z) in
    N(dy, y, N(dx, x, a, b), c), flag
  | _ -> failwith "fix_PP : impossible"

let rec ins_aux x = function
  | E -> N (Z, x, E, E), true
  | N (d, n, l, r) when x = n -> N (d, n, l, r), false
  | N (d, n, l, r) when x < n ->
    let l', flag = ins_aux x l in (* flag vaut true si on a augmenté la taille *)
    begin match d, flag with
      | _, false -> N (d, n, l', r), false (* à partir de là, flag vaut forcément true, car le false a été match *)
      | M, _ -> fix_MM (N (d, n, l', r)) (* fix renvoie false si ça a décru -> c'est parfait, ça veut dire que la taille est revenue à la normale *)
      | P, _ -> N (Z, n, l', r), false
      | Z, _ -> N (M, n, l', r), true
  end
  | N (d, n, l, r) ->
    let r', flag = ins_aux x r in
    begin match d, flag with
      | _, false -> N (d, n, l, r'), false
      | P, _ -> fix_PP (N (d, n, l, r'))
      | M, _ -> N (Z, n, l, r'), false
      | Z, _ -> N (P, n, l, r'), true
    end

let insert t x =
  let t', _ = ins_aux x t in t'

let build list =
  let rec aux t u =
    match u with
    | [] -> t
    | x :: xs -> aux (insert t x) xs
  in aux E list

let del_left flag t =
  match flag, t with
  | false, _ -> t, false
  | _, N (P, n, l, r) -> let t', flag = fix_PP (N (P, n, l, r)) in t', not flag (* false est renvoyé si la hauteur a décru, et on veut renvoyer true si del_left a modifié la hauteur*)
  | _, N (Z, n, l, r) -> N (P, n, l, r), false
  | _, N (M, n, l, r) -> N (Z, n, l, r), true
  | _, E -> failwith "del_left: empty"

let del_right flag t =
  match flag, t with
  | false, _ -> t, false
  | _, N (M, n, l, r) -> let t', flag = fix_MM (N (M, n, l, r)) in t', not flag
  | _, N (Z, n, l, r) -> N (M, n, l, r), false
  | _, N (P, n, l, r) -> N (Z, n, l, r), true
  | _, E -> failwith "del_right: empty"

let rec extract_min = function
  | E -> failwith "extract_min: empty"
  | N (d, n, E, r) -> (r, n, true)
  | N (d, n, l, r) ->
    let l', min, flag = extract_min l in
    let t, flag' = del_left flag (N (d, n, l', r)) in
    (t, min, flag')

let rec del_aux x = function
  | E -> E, false 
  | N (d, n, l, r) when x < n ->
    let l', flag = del_aux x l in
    del_left flag (N (d, n, l', r))
  | N (d, n, l, r) when x > n ->
    let r', flag = del_aux x r in
    del_right flag (N (d, n, l, r'))
  (* A partir d'ici, forcément égalité de x et n *)
  | N (_, _, a, E) | N (_, _, E, a) -> (a, true)
  | N (d, n, l, r) ->
    let r', min, flag = extract_min r in
    N (d, min, l, r'), flag

let delete t x =
  let t', _ = del_aux x t in t'
