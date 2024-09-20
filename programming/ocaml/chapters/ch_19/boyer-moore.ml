let make_bct s =
  let t = Array.make 256 (-1) in
  for i = 0 to String.length s - 1 do
    let c = int_of_char s.[i] in
    t.(c) <- i
  done;
  t

exception BadChar of (int * int)

let boyer_moore_horspool t m =
  let bct = make_bct m in
  let k = String.length m in (* O(1) car OCaml stocke la longueur de la chaine *)
  let n = String.length t in
  let rec aux shift occs =
    if shift + k > n then occs
    else try
      for j = k - 1 downto 0 do
        if t.[shift + j] <> m.[j] then raise (BadChar (int_of_char t.[shift + j], j))
      done;
      aux (shift + 1) (shift :: occs)
    with
    | BadChar (x, i) -> aux (shift + (max 1 (i - bct.(x)))) occs
  in
  aux 0 []
