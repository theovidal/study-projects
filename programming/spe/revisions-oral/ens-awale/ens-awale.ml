let u0 = 42
let n = 10000000

let a = 1103515245
let c = 12345
let m = (1 lsl 31)

let genere_u () =
  let u = Array.make n u0 in
  for i = 1 to n - 1 do
    u.(i) <- (a * u.(i - 1) + c) mod m
  done;
  u

let genere_autres u =
  let v7 = Array.make n 0 in
  let v24 = Array.make n 0 in
  let w7 = Array.make n 0 in
  let w24 = Array.make n 0 in
  for i = 0 to n - 1 do
    v7.(i) <- (3432 * u.(i)) lsr 31;
    v24.(i) <- (2629575 * u.(i)) lsr 31;
    w7.(i) <- 7 + 25 * v7.(i);
    w24.(i) <- 24 + 25 * v24.(i)
  done;
  v7, v24, w7, w24

let u = genere_u ()
let v7, v24, w7, w24 = genere_autres u

let rec binom k n =
  if k < 0 || k > n then 0
  else if k = n then 1
  else binom (k - 1) (n - 1) + binom k (n - 1)

let greatest_to_verify f =
  let n = ref 1 in
  while f !n do
    incr n
  done;
  !n - 1

let enc c =
  let value = ref 0 in
  for i = 1 to 7 do
    value := !value + binom i c.(i - 1)
  done;
  !value

let dec g =
  let c = Array.make 7 0 in
  let g' = ref g in
  for i = 6 downto 0 do
    if i != 6 then g' := !g' - binom (i + 2) c.(i + 1);
    c.(i) <- greatest_to_verify (fun n -> binom (i + 1) n <= !g')
  done;
  c

let config g =
  let nb_graines = g mod 25 in
  let c = dec (g/25) in
  let cases = Array.make 8 c.(0) in
  let total = ref c.(0) in
  for i = 1 to 6 do
    cases.(i) <- c.(i) - c.(i - 1) - 1;
    total := !total + cases.(i);
  done;
  cases.(7) <- nb_graines - !total;
  cases
