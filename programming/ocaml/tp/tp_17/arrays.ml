let premiere_occ_while x t =
  let i = ref 0 in
  let res = ref None in
  let n = Array.length t in
  while !res = None && !i < n do
    if t.(!i) = x then res := Some !i;
    incr i;
  done;
  !res

let premiere_occ_rec x t =
  let n = Array.length t in
  let rec aux i =
    if i = n then None
    else if t.(i) = x then Some i
    else aux (i + 1) in
  aux 0

exception Found of int
let premiere_occ_for x t =
  try
    for i = 0 to Array.length t - 1 do
      if t.(i) = x then raise (Found i)
    done;
    None
  with
  | Found i -> Some i

let cherche_matrice_while x m =
  let res = ref None in
  let i = ref 0 in
  let j = ref 0 in
  while !res = None && !i < Array.length m do
    while !res = None && !j < Array.length m.(!i) do
      if m.(!i).(!j) = x then res := Some (!i, !j);
      incr j
    done;
    incr i;
    j := 0;
  done;
  !res

let cherche_matrice_rec x m =
  let rec aux i j =
    if i = Array.length m then None
    else if j = Array.length m.(i) then aux (i + 1) 0
    else if m.(i).(j) = x then Some (i, j)
    else aux i (j + 1) in
  aux 0 0

exception Found of (int * int)

let cherche_matrice_for x m =
  try
    for i = 0 to Array.length m - 1 do
      for j = 0 to Array.length m.(i) - 1 do
        if m.(i).(j) = x then raise (Found (i, j))
      done;
    done;
    None
  with
  | Found (i, j) -> Some (i, j)
