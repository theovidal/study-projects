(* https://discord.com/channels/876742071900340254/909509896532283462/910566896057872385 *)
(* Déterminer l'indice i tel que la somme de i à i+k des éléments du tableau soit maximal *)

let max_inter_sum t k =
  let n = Array.length t in
  let i = ref 0 in
  let value = ref 0 in
  for j = 0 to k - 1 do
    value := !value + t.(j)
  done;
  for j = 0 to n - k do
    let new_value = !value - t.(j) + t.(j + k) in
    if new_value > !value then
      i := j;
      value := new_value
  done;
  !i

let max_inter t k =
  let n = Array.length t in
  let max1 = ref t.(0) in
  let max2 = ref t.(0) in
  
  for j = 1 to k - 1 do
    max1 := max !max1 t.(j);
    if t.(j) <= !max1 && t.(j) > !max2 then max2 := t.(j);
  done;
  print_int !max1; print_newline ();

  for j = 1 to n - 1 - k do
    if t.(j - 1) = !max1 then max1 := !max2;

    let new_el = t.(j + k - 1) in
    if new_el > !max1 then max1 := new_el
    else if new_el <= !max1 && new_el > !max2 then max2 := new_el;
    print_int !max1; print_newline ()
  done
