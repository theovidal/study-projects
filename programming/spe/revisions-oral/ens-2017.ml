let m = (1 lsl 31) - 1

let u0 = 42

let genere_u () =
  let u = Array.make 10000 u0 in
  for i = 1 to 9999 do
    u.(i) <- (16807 * u.(i - 1) + 17) mod m
  done;
  u

let genere_v u =
  let v = Array.make_matrix 62 10000 0 in
  for k = 0 to 61 do
    let dp = 1 lsl k in
    for n = 0 to 9999 do
      v.(k).(n) <- (u.(n) mod dp) + dp
    done;
  done;
  v

type ternaire = 
  | Z
  | U
  | N of ternaire * int * ternaire * ternaire

let rec construit_arbre n =
  match n with
  | 0 -> Z
  | 1 -> U
  | n ->
    let p = plus_grand_p_divisant n in
    let dp = 1 lsl (1 lsl p) in
    N (
      construit_arbre (n mod dp),
      p,
      construit_arbre p,
      construit_arbre (n / dp)
    )

let construit_v_arbre k n = construit_arbre v.(k).(n)

let rec signature = function
  | Z -> 0
  | U -> u.(10) mod 97
  | N (g, p, _, d) when p mod 2 = 0 -> (signature g + u.(30) * (signature d)) mod 97
  | N (g, p, _, d) -> (signature g + u.(20) * (signature d)) mod 97

let log22 n =
  let p = ref 0 in
  let v = ref 2 in
  while !v <= n do
    incr p;
    v := !v * (!v)
  done;
  !p - 1

let log2 n =
  let p = ref 0 in
  let v = ref 1 in
  while !v <= n do
    incr p;
    v := !v lsl 1
  done;
  !p - 1

let rec signature_directe = function
  | 0 -> 0
  | 1 -> u.(10) mod 97
  | n ->
    let p = log22 n in
    let dp = 1 lsl (1 lsl p) in

    let g = n mod dp in
    let d = n / dp in

    if p mod 2 = 0 then (signature_directe g + u.(30) * (signature_directe d)) mod 97
    else (signature_directe g + u.(20) * (signature_directe d)) mod 97


