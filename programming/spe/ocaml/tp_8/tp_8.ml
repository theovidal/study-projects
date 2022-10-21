let u0 = 42

let rec u t =
  if t = 0 then u0
  else 19999999 * (u (t - 1)) mod 19999981

let rec num n p =
  let u = ref u0 in
  let sum = ref 0 in
  for i = 0 to n*(n-1)/2 - 1 do
    if !u mod 10000 < p then incr sum;
    u := 19999999 * !u mod 19999981
  done;
  !sum

let rec num_composante n p =
  let u = ref u0 in
  let in = Array.make n false in
  let sum = ref 0 in
  let edge = ref 0 in
  let threshold = ref (n - 1) in
  for i = 0 to n*(n-1)/2 - 1 do
    if i = !threshold then begin
      incr edge;
      theshold := !theshold + n - 1 - !edge
    end;
    let b_edge = !threshold - i ... in
    if !u mod 10000 < p then incr sum;
    u := 19999999 * !u mod 19999981
  done;
  !sum



let rec dist u v =
  match u, v with
  | [], _ | _, [] -> 0
  | x :: xs, y :: ys when x <> y -> dist xs ys + 1
  | _ :: xs, _ :: ys -> dist xs ys

type regex =
| Epsilon
| Empty
| Letter of bool
| Concat of regex * regex
| Sum of regex * regex
| Star of regex

let rec h = function
  | Epsilon | Empty -> Empty
  | Letter i -> Letter (not i) 
  | Concat (e1, e2) -> Sum (
    Concat (h e1, e2),
    Concat (e1, h e2)
  )
  | Sum (e1, e2) -> Sum (h e1, h e2)
  | Star e1 -> Concat (Star e1, Concat (h e1, Star e1))
