(*
   ________  _____ ______            _______     
  |\   ___ \|\   _ \  _   \         /  ___  \    
  \ \  \_|\ \ \  \\\__\ \  \       /__/|_/  /|   
   \ \  \ \\ \ \  \\|__| \  \      |__|//  / /   
    \ \  \_\\ \ \  \    \ \  \         /  /_/__  
     \ \_______\ \__\    \ \__\       |\________\
      \|_______|\|__|     \|__|        \|_______|

        VIDAL Théo 861 — Pour le 4/01/2022
*)

      (* —————————————————————————————————————————— *)
      (*   Partie 1 — Comparaison de combinaisons   *)
      (* —————————————————————————————————————————— *)

(* Valeurs réelles du jeu, et surtout celles admissibles avant d'atteindre la limite de mémoire *)
let nb_pegs = 4
let nb_colors = 6
type combination = int array

(* Question 1 *)
let well_placed t u =
  let count = ref 0 in
  for i = 0 to Array.length t - 1 do
    if t.(i) = u.(i) then incr count
  done;
  !count

(* Question 2 *)
let histogram combo =
  let h = Array.make nb_colors 0 in
  for i = 0 to nb_pegs - 1 do
    h.(combo.(i)) <- h.(combo.(i)) + 1
  done;
  h

(* Question 3 *)
let well_placed_or_not t u =
  let hist_t = histogram t in
  let hist_u = histogram u in
  let count = ref 0 in
  for i = 0 to nb_colors - 1 do
    count := !count + min hist_t.(i) hist_u.(i)
  done;
  !count

(* Question 4 *)
type response = int * int

let compute_similarity t u =
  let well = well_placed t u in
  (well, well_placed_or_not t u - well)

      (* ———————————————————————— *)
      (*   Partie 2 — Précalcul   *)
      (* ———————————————————————— *)

(* Question 5 - Version récursive choisie arbitrairement *)
let rec pow x y =
  if y == 0 then 1
  else if y mod 2 = 0 then pow (x * x) (y / 2)
  else x * pow (x * x) ((y - 1) / 2)

(* Question 6 *)
let nb_combinations = pow nb_colors nb_pegs

(* Question 7 *)
(* Conversions de base 10 en base p
Dans les tableaux, le chiffre de poids faible est à gauche (indice 0). *)
type code = int

(* base p -> base 10 : Multiplication des "chiffres" par les poids *)
let int_of_combination u =
  let n = ref 0 in
  for i = Array.length u - 1 downto 0 do
    n := !n * nb_colors + u.(i)
  done;
  !n

(* base 10 -> base p : Divisions euclidiennes successives pour obtenir les "chiffres" *)
let combination_of_int n =
  let v = ref n in
  let u = Array.make nb_pegs 0 in
  for i = 0 to nb_pegs - 1 do
    if !v <> 0 then
      u.(i) <- !v mod nb_colors;
      v := !v / nb_colors;
  done;
  u

(*
  Question 8
  -> nous aurions pu calculer tous les combination_of_int avant, mais
  cette fonction étant exécutée en précalcul, cela n'a pas d'importance.
*)
let create_similarity_table () =
  Array.init nb_combinations (fun i ->
    Array.init nb_combinations (fun j ->
    compute_similarity (combination_of_int i) (combination_of_int j)
    )
  )

let similarity_table = create_similarity_table ()

let similarity i j = similarity_table.(i).(j)


      (* ——————————————————————————————— *)
      (*   Partie 3 — Stratégie simple   *)
      (* ——————————————————————————————— *)

(* Question 9 *)

(*
  Pour que c1 soit bien candidat, avec c de l'historique,
  il faut sim(c, goal) = sim(c, c1) (aller vers le même objectif,
  en quelque sorte).
*)
let rec is_compatible history candidate =
  match history with
  | [] -> true
  | (c, s) :: xs -> similarity c candidate = s && is_compatible xs candidate


(* Question 10
  Le code est légèrement "golfé", mais je trouvait cela plutôt élégant.
*)
let play_simple goal =
  let rec aux hist code =
    if code = nb_combinations then hist
    else match hist with
    | (_, s) :: _ when s = (nb_pegs, 0) -> hist
    | _ -> aux (
      (if is_compatible hist code then [(code, similarity code goal)]
      else []) @ hist) (code + 1)
  in List.rev (aux [] 0)


      (* —————————————————————————————————————— *)
      (*   Partie 4 — Analyse de la stratégie   *)
      (* —————————————————————————————————————— *)
      
(* Question 11 *)
let stats strategy =
  let avg = ref 0. in
  let worst_case = ref 0 in
  let max_moves = ref 0 in
  for code = 0 to nb_combinations - 1 do
    let nb_moves = List.length (strategy code) in
    avg := !avg +. float_of_int nb_moves;
    if nb_moves > !max_moves then (max_moves := nb_moves; worst_case := code) 
  done;
  (!avg /. float_of_int nb_combinations, !max_moves, !worst_case)

(* Question 12 *) 
(* (5.76466049382716061, 9, 1071) *)


      (* ———————————————————— *)
      (*   Partie 5 — Bonus   *)
      (* ———————————————————— *)

let int_of_similarity (wp, nwp) =
  wp * (nb_pegs + 1) + nwp

(* Question 13 *)

(*
  similarities_number calcule le nombre de couples de combinaisons qui
  donnent un même nombre de similarités.
  Les indices du tableau retourné sont donnés par int_of_similarity.
  *)
let similarities_number possible_goals candidate_move =
  let rec aux codes remaining =
    match remaining with
    | [] -> codes
    | b :: bs ->
      let sim = int_of_similarity (similarity b candidate_move) in
      codes.(sim) <- codes.(sim) + 1;
      aux codes bs 
  in aux (Array.make (pow (nb_pegs + 1) 2) 0) possible_goals

let max_card possible_goals candidate_move =
  let similarities = similarities_number possible_goals candidate_move in
  let max_card = ref 0 in
  for i = 0 to Array.length similarities - 1 do
    max_card := max !max_card similarities.(i)
  done;
  !max_card
  
(* Question 14 *)
let get_greedy_move possible_goals =
  let rec aux goals candidate card =
    match goals with
    | [] -> candidate
    | c :: cs ->
      let new_card = max_card possible_goals c in
      if new_card < card then aux cs c new_card
      else aux cs candidate card
  in aux possible_goals 0 max_int

(* Question 15 *)

(* Calcul de B'(but, c) *)
let get_possible_goals (c, s) = List.filter (fun b -> similarity b c = s)

(* Liste de toutes les combinaisons (de 0 à nb_combinations-1) (c'est un range) *)
let combinations_list =
  let rec aux u i =
    if i < 0 then u
    else aux (i :: u) (i - 1) in
  aux [] (nb_combinations - 1)

let play_greedy goal =
  let rec aux hist possibles code =
    if code = nb_combinations then hist
    else match hist with
    | [] ->
      let first = get_greedy_move combinations_list in
      aux [(first, (similarity first goal))] combinations_list 1
    | (_, s) :: _ when s = (4, 0) -> hist
    | previous :: _ ->
      let b' = get_possible_goals previous possibles in
      let move = get_greedy_move b' in
      aux ((move, (similarity move goal)) :: hist) b' (move + 1)
  in List.rev (aux [] combinations_list 0)

(* Question 16 *)
(* (4.49691358024691379, 6, 11) *)
