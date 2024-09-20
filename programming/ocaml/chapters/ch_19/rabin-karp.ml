let is_prefix text substring =
  let n, k = String.length text, String.length substring in
  if k > n then false
  else
    let i = ref 0 in
    while !i < k && text.[!i] = substring.[!i] do
      incr i
    done;
    !i = k

let occurrences text substring = failwith "à implémenter"

let b = 256
let p = 23

let rabin t s =
  let n, k = String.length t, String.length s in
  if n > k then []
  else
    let d = int_of_float (float_of_int b ** (float_of_int k -. 1.)) mod p in
    let target = ref 0 in
    let h = ref 0 in
    for i = 0 to k - 1 do
      target := (b * !target + (int_of_char s.[i])) mod p;
      h := (b * !h + (int_of_char t.[i])) mod p
    done;
    let occurrences = ref [] in
    for i = 0 to n - k do
      if !h = !target && String.sub t i k = s then
        occurrences := i :: !occurrences;
      if i + k < n then
        h := (b * (!h - d * (int_of_char t.[i])) + (int_of_char t.[i + k])) mod p
    done;
    !occurrences
