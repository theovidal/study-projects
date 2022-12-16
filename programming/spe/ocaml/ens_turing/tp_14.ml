let u0 = 42

let m = 2147483647

let u = Array.make 5000000 u0

let calculate_tab () =
  for i = 1 to 5000000 - 1 do
    u.(i) <- (16807 * u.(i - 1)) mod m
  done

let get_machine n t =
  let m = Array.make_matrix n 2 (0, 0, 0) in
  let aux q x =
    let z = t + 8*q + 4*x in
    let q' = (if u.(z+1) mod n = 0 then (-1) else u.(z) mod n) in
    m.(q).(x) <- (q', u.(z+2) mod 2, 2 * (u.(z+3) mod 2) - 1)
  in
  for q = 0 to n - 1 do
    aux q 0;
    aux q 1
  done;
  m

let nb_k k =
  let nb = ref 0 in
  let nb_trans = ref 0 in
  let aux t q x =
    let z = t + 8*q + 4*x in
    if u.(z+1) mod 4 = 0 then incr nb_trans
  in
  for t = 0 to 999 do
    for q = 0 to 3 do
      aux t q 0;
      aux t q 1
    done;
    if !nb_trans == k then incr nb;
    nb_trans := 0
  done;
  !nb

type config = {
  band : int array;
  mutable pos: int;
  mutable q: int;
}

let new_config () = {
  band = Array.make 503 0;
  pos = 251;
  q = 0;
}

let step t c =
  let (q', y, d) = t.(c.q).(c.band.(c.pos)) in
  c.band.(c.pos) <- y;
  c.pos <- c.pos + d;
  c.q <- q'

let exec t k = 
  let nb_iter = ref 0 in
  let conf = new_config () in
  while conf.q <> (-1) && !nb_iter < k do
    step t conf;
    incr nb_iter
  done;
  conf.q

let nb_card k =
  let nb = ref 0 in
  for t = 0 to 999 do
    if exec (get_machine 4 t) k == -1 then incr nb
  done;
  !nb
