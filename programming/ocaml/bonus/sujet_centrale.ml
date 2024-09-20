type candidat = int
type bulletin = candidat list
type urne = bulletin list

let rec duel c1 c2 u =
  let rec aux n1 n2 u =
    match u with
    | [] -> n1 - n2
    | x :: xs ->
      let rec classe = function
      | [] -> failwith "impossible"
      | c :: cs when c = c1 -> aux (n1 + 1) n2
      | c :: cs when c = c2 -> aux n1 (n2 + 1)
      | _ :: cs -> classe cs
      in classe x xs
  in aux 0 0 u

let depouillement n u =
  let mat = Array.make_matrix n n 0 in
  for i = 1 to n - 1 do
    for j = 0 to i - 1 do
      let diff = duel i j u in
      mat.(i).(j) <- diff;
      mat.(j).(i) <- -diff
    done;
  done;
  mat

let range n = List.init n (fun i -> i)

(* Fonction supprime à faire *)
let rec supprime u x =
  match u with
  | [] -> []
  | y :: ys when y = x -> ys
  | y :: ys -> y :: supprime ys x
 
let mcgarvey mat =
  let urne = ref [] in
  let n = Array.length mat in
  for i = 1 to n - 1 do
    for j = 0 to i - 1 do
      let p = mat.(i).(j) / 2 in
      for k = 1 to p do
        let b1 = ref [] in
        let b2 = ref [] in
        for  = 0 to n - 1 do
          
        done;
      done;
    done;
  done;
  !urne

let condorcet m =
  let vainqueurs = ref [] in
  for i = 0 to n - 1 do
    let est_vainqueur = ref true in
    for j = 0 to n - 1 do
      if m.(i).(j) < 0 then vainqueur := false
    done;
    if !est_vainqueur then vainqueurs := i :: !vainqueurs
  done;
  !vainqueurs


