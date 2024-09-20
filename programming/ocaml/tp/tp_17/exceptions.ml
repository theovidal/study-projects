let somme_inverses t =
  let s = ref 0 in
  try
    for i = 0 to Array.length t do
      s := !s + 1 / t.(i)
    done;
    !s;
  with
  | Division_by_zero -> max_int

let _ =
  print_int (somme_inverses [|2; 0; 3|])
