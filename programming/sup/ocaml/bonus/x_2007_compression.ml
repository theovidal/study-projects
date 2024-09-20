let occurrences t n =
  let r = Array.make n 0 in
  for i = 0 to 255 do
    r.(t.(i)) <- r.(t.(i)) + 1
  done;
  r

let min t n =
  let r = occurrences t n in
  let m = ref max_int in
  for i = 0 to 255 do
    m := min !m r.(i)
  done;
  m

let taille_codage t n =
  let r = occurences t n in
  let ∆ = min t n

let compare_rotations t n i j =
  let res = ref 0 in
  let k = ref 1 in
  while !res = 0 && !k < n do
    let r_i = !k - i mod n in
    let r_j = !k - j mod n in
    if t.(r_i) > t.(r_j) then res := 1;
    if t.(r_i) < t.(r_j) then res := -1
  done;
  !res

Array.init 
