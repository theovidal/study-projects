(*
 _________  ________        ___    ___ ___    ___ ___    ___ ___      ___ ___     
|\___   ___\\   __  \      |\  \  /  /|\  \  /  /|\  \  /  /|\  \    /  /|\  \    
\|___ \  \_\ \  \|\  \     \ \  \/  / | \  \/  / | \  \/  / | \  \  /  / | \  \   
     \ \  \ \ \   ____\     \ \    / / \ \    / / \ \    / / \ \  \/  / / \ \  \  
      \ \  \ \ \  \___|      /     \/   /     \/   /     \/   \ \    / /   \ \  \ 
       \ \__\ \ \__\        /  /\   \  /  /\   \  /  /\   \    \ \__/ /     \ \__\
        \|__|  \|__|       /__/ /\ __\/__/ /\ __\/__/ /\ __\    \|__|/       \|__|
                           |__|/ \|__||__|/ \|__||__|/ \|__|                      

                                  – 22/03/2022 –                                                              
*)

(* ————————————————————————————————————————— *)
(*  II. Méthode par programmation dynamique  *)
(* ————————————————————————————————————————— *)

(* Version avec cas de base obvious et stockage du minimum des valeurs *)
let rec aux_dyn s =
  let n = Array.length s in
  let longueurs = Array.make n 1 in
  let min_s = ref s.(0) in
  for k = 1 to n - 1 do
    if s.(k) < !min_s then
      min_s := s.(k)
    else begin
      let max_l = ref 1 in
      for i = 0 to k - 1 do
        max_l := max !max_l (if s.(i) <= s.(k) then longueurs.(i) else 0)
      done;
      longueurs.(k) <- 1 + !max_l
    end
  done;
  longueurs

(* Version sans distinction de cas *)
let rec aux_dyn s =
  let n = Array.length s in
  let longueurs = Array.make n 1 in
  for k = 1 to n - 1 do
    let max_l = ref 0 in
    for i = 0 to k - 1 do
      (* Réinitialisation du max si on trouve un élément plus grand -> plus de croissance *)
      max_l := max !max_l (if s.(i) <= s.(k) then longueurs.(i) else 0)
    done;
    (* si le max vaut 0, on se ramène au premier cas *)
    longueurs.(k) <- 1 + !max_l
  done;
  longueurs


let l_seq_dyn s =
  let longueurs = aux_dyn s in
  let m = ref 0 in
  for i = 0 to Array.length s - 1 do
    m := max !m longueurs.(i)
  done;
  !m, longueurs


let rec sous_sequence_dyn s =
  let l_seq, longueurs = l_seq_dyn s in
  let l = ref l_seq in
  let i = ref (Array.length s - 1) in
  let res = Array.make l_seq 0 in
  while !l > 0 do
    if longueurs.(!i) = !l then begin
      res.(!l - 1) <- s.(!i);
      decr l
    end;
    decr i
  done;
  res

(* ————————————————————————————— *)
(*  III. Méthode de la patience  *)
(* ————————————————————————————— *)

type config = int list array

let patience s =
  let rec aux s cfg i =
    match s, cfg.(i) with
    | [], _ -> cfg
    | x :: xs, y :: ys when x >= y -> aux s cfg (i + 1) (* Tant qu'on ne peut pas empiler, on parcourt le tableau *)
    | x :: xs, u -> (* Si on peut empiler, ou qu'on a une pile vide, on peut insérer *)
    cfg.(i) <- x :: u;
    aux xs cfg 0
  in aux s (Array.make (List.length s) []) 0


(* Recherche de l'indice d'une pile pour insérer à l'aide d'une recherche dichotomique *)
let find_num_pile carte cfg =
  let rec aux deb fin =
    if fin - deb < 1 then fin
    else
      let mid = (fin + deb) / 2 in
      match cfg.(mid) with
      | [] -> aux deb mid
      | hd :: _ ->
        if hd <= carte then aux (mid + 1) fin
        else aux deb mid
  in aux 0 (Array.length cfg - 1)

let patience_opt s =
  let rec aux s cfg =
    match s with
    | [] -> cfg
    | x :: xs ->
      let i = find_num_pile x cfg in
      cfg.(i) <- x :: cfg.(i);
      aux xs cfg
  in aux s (Array.make (List.length s) [])

let l_seq_patience s =
  let cfg = patience_opt s in
  Array.length cfg

let sous_sequence_patience s =
  let cfg = patience_opt s in
  let rec aux u i =
    if i < 0 then u else
    match cfg.(i) with
    | [] -> aux u (i - 1)
    | x :: xs -> aux (x :: u) (i - 1)
  in aux [] (Array.length cfg - 1)
