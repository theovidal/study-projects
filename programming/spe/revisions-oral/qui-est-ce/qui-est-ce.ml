let u0 = 395
let taille = 10000000

let calcule_u () =
  let u = Array.make taille u0 in 
  for i = 1 to taille - 1 do
    u.(i) <- (900_007 * u.(i - 1)) mod 1_000_000_007
  done;
  u

let b u p d i k =
  if u.(i * d + k) mod p = 0 then 0 else 1
