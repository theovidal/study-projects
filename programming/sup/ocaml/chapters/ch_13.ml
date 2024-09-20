(* Exercice 13.16 *)

let indice_pic t =
  assert (Array.length t > 0);
  let rec aux deb fin =
    if fin - deb = 2 then max t.(deb) t.(deb + 1)
    else if fin - deb = 1 then deb
    else
      let mil = (fin + deb) / 2 in
      if t.(mil) >= t.(mil - 1) && t.(mil) >= t.(mil + 1) then mil
      else if t.(mil) < t.(mil - 1) then aux deb mil
      else aux (mil + 1) fin
  in aux 0 (Array.length t - 1)

(* Exercice 13.17 *)

let partitions n =
  let t = Array.make_matrix (n + 1) (n + 1) (-1) in
  let rec aux n k =
    match n, k with
    | n, k when n < 0 -> 0 (* On ne peut pas représenter un négatif avec des positifs *)
    | 0, k -> 1 (* Une seule manière de représenter 0 *)
    | n, 0 -> 0 (* On ne peut pas représenter un entier naturel qu'avec des zéros (sauf 0 lui-même) *)
    | _ -> 
      if t.(n).(k) = -1 then t.(n).(k) <- aux n (k - 1) + aux (n - k) k;
      t.(n).(k)
  in aux n n
