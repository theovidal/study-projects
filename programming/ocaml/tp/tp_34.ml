(* Exercice 3 *)
let p_ex = [|3; 8; 5; 1; 6; 1; 2; 6; 6; 1; 7; 8; 9; 12; 4; 1; 5; 7; 11; 4; 1; 5; 12; 13|]
let v_ex = [|1; 2; 6; 3; 7; 8; 2; 3; 4; 7; 5; 2; 12; 8; 5; 3; 7; 10; 8; 7; 4; 15; 7; 20|]

let sac p v pmax =
  let rec aux k d =
    match k, d with
    | _, d when d < 0 -> min_int
    | 0, d -> 0
    | _ ->
      let valeur_sans = aux (k - 1) d in
      let valeur_avec = v.(k - 1) + aux (k - 1) (d - p.(k - 1)) in
      max valeur_sans valeur_avec
  in aux (Array.length p) pmax

(* Exercice 4 *)
let sac_instrumente p v pmax =
  let nb_appels = ref 0 in
  let rec aux k d =
    incr nb_appels ;
    match k, d with
    | _, d when d < 0 -> min_int
    | 0, d -> 0
    | _ ->
      let valeur_sans = aux (k - 1) d in
      let valeur_avec = v.(k - 1) + aux (k - 1) (d - p.(k - 1)) in
      max valeur_sans valeur_avec
  in let valeur = aux (Array.length p) pmax in
  valeur, !nb_appels


(* Exercice 5 *)
let sac_mem p v pmax =
  let n = Array.length p in
  let t = Array.make_matrix (n + 1) (pmax + 1) (None, []) in
  let rec aux k d = (* comme il y a le match du Option, on ne garde que lui et on fait un if au-dessus *)
    if d < 0 then (min_int, [])
    else if k = 0 then 0, []
    else
      match t.(k).(d) with
      | (Some valeur), t -> valeur, t
      | None, _ ->
        let vs, ts = aux (k - 1) d in
        let v_temp, ta = aux (k - 1) (d - p.(k - 1)) in
        let va = v_temp + v.(k - 1) in
        if vs > va then begin
          t.(k).(d) <- Some vs, ts ; vs, ts
        end
        else begin
          t.(k).(d) <- Some va, (k - 1) :: ta ; va, (k - 1) :: ta
        end
  in aux n pmax 

let sac_dyn p v pmax =
  let n = Array.length p in
  let t = Array.make_matrix (n + 1) (pmax + 1) (-1) in
  for d = 0 to pmax do
    t.(0).(d) <- 0
  done;
  let score k d = if d < 0 then min_int else t.(k).(d) in
  for k = 1 to n do
    for d = 0 to pmax do
      let valeur_sans = score (k - 1) d in
      let valeur_avec =
        v.(k - 1) + score (k - 1) (d - p.(k - 1))
      in t.(k).(d) <- max valeur_sans valeur_avec
    done;
  done;
  t.(n).(pmax)
