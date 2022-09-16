(*
  TP 3  
*)

type etat = int
type lettre = int
type mot = lettre list

type afd =
  {m : int;
   n : int;
   init : etat;
   term : bool array;
   delta : etat array array}

type description =
  {initial : etat;
   acceptants : etat list;
   transitions : (etat * lettre * etat) list}


let construit d =
  let rec aux = function
    | [] -> min_int, min_int
    | (q, x, q') :: v -> let maxq, maxx = aux v in
      (max maxq (max q q'), max maxx x) in
  let etat_max, lettre_max = aux d.transitions in
  let n = etat_max + 1 in
  let m = lettre_max + 1 in
  let term = Array.make n false in
  let delta = Array.make_matrix n m (-1) in
  List.iter (fun i -> term.(i) <- true) d.acceptants;
  List.iter (fun (q, x, q') -> delta.(q).(x) <- q') d.transitions;
  {n = n;
   m = m;
   term = term;
   init = d.initial;
   delta = delta}


let graphviz a ?etats:(etats=[||]) ?lettres:(lettres=[||]) filename =
  let open Printf in
  let out = open_out filename in
  fprintf out "digraph a {\nrankdir = LR;\n";
  (* noms des états *)
  let nom_etat =
    if etats = [||] then string_of_int
    else (fun i -> etats.(i)) in
  (* noms des lettres *)
  let nom_lettre =
    if lettres = [||] then string_of_int
    else (fun i -> lettres.(i)) in
  (* etats *)
  for q = 0 to a.n - 1 do
    let shape = if a.term.(q) then "doublecircle" else "circle" in
    fprintf out "node [shape = %s, label = %s] %i;\n" shape (nom_etat q) q
  done;
  (* etat initial *)
  fprintf out "node [shape = point]; I\n";
  fprintf out "I -> %i;\n" a.init;
  (* transitions *)
  let labels = Array.make_matrix a.n a.n [] in
  for q = 0 to a.n - 1 do
    for x = a.m - 1 downto 0 do
      let q' = a.delta.(q).(x) in
      if q' <> -1 then
        labels.(q).(q') <- nom_lettre x :: labels.(q).(q')
    done
  done;
  for q = 0 to a.n - 1 do
    for q' = 0 to a.n - 1 do
      let s = String.concat "," labels.(q).(q') in
      if s <> "" then
        fprintf out "%i -> %i [ label = \"%s\" ];\n" q q' s
    done
  done;
  fprintf out "}\n";
  close_out out

let genere_pdf input_file output_file =
  Sys.command (Printf.sprintf "dot -Tpdf %s -o %s" input_file output_file)

  let description_a1 =
    {initial = 0;
     acceptants = [2];
     transitions = [(0, 0, 2); (0, 1, 0);
                    (1, 0, 0); (1, 2, 2);
                    (2, 0, 2); (2, 2, 1)]}

let description_a2 =
  {initial = 0;
  acceptants = [2];
  transitions = [(0, int_of_char 'a', 2); (2, int_of_char 'c', 1); (2, int_of_char 'b', 2)]
  }

let rec delta_star a q u =
  match u with
  | [] -> q
  | x :: xs ->
    let q' = a.delta.(q).(x) in
    if q' = -1 then -1
    else delta_star a q' xs

let accepte a mot = delta_star a a.init mot <> -1

let accessibles a =
  let vus = Array.make a.n false in

  let rec explore q =
    if vus.(q) = false then begin
      vus.(q) <- true;
      for i = 0 to a.m - 1 do
        if a.delta.(q).(i) <> -1 then explore a.delta.(q).(i)
      done
    end

  in explore a.init;
  vus

let langage_non_vide a =
  let acc = accessibles a in
  let non_vide = ref false in
  for i = 0 to a.n - 1 do
    if acc.(i) && a.term.(i) then non_vide := true
  done;
  !non_vide

let inverse a =
  let g = Array.make_matrix a.n a.n 0 in
  for q = 0 to a.n - 1 do
    for x = 0 to a.m - 1 do
      let q' = a.delta.(q).(x) in
      (* Arc ssi q->q' ET q≠q' ! *)
      if q' <> -1 && q <> q' then g.(q').(q) <- 1
    done;
  done;
  g

let coaccessibles a =
  let g = inverse a in
  let vus = Array.make a.n false in

  let rec explore q =
    if vus.(q) = false then begin
      vus.(q) <- true;
      for i = 0 to a.n - 1 do
        if g.(q).(i) = 1 then explore i
      done
    end

  in
  Array.iteri (fun q term -> if term then explore q) a.term;
  vus

let est_emonde a =
  let acc = accessibles a in
  let coacc = coaccessibles a in

  let emonde = ref true in
  let i = ref 0 in
  while !i < a.n - 1 && acc.(!i) && coacc.(!i) do
    incr i
  done;
  if not acc.(!i) || not coacc.(!i) then
    emonde := false;
  !emonde

(* Exercice 3.5 *)
let complementaire a =
  {
    m = a.m;
    n = a.n;
    init = a.init;
    term = Array.map (fun q -> not q) a.term;
    delta = a.delta
  }

(* Exercice 3.6 *)
let complete_delta a =
  let d' = Array.make_matrix (a.n + 1) a.m 0 in
  for q = 0 to a.n - 1 do
    for x = 0 to a.m - 1 do
      d'.(q).(x) <- if a.delta.(q).(x) = -1 then a.n else a.delta.(q).(x)
    done;
  done;
  d'

let complete a =
  {
    m = a.m;
    n = a.n + 1;
    init = a.init;
    term = Array.append a.term [|false|];
    delta = complete_delta a
  }

(* Exercice 3.7 *)
(* a1 et a1 supposés complets; numéro d'un état = n1+n2*n *)
let build_term a1 a2 =
  let term = Array.make (a1.n * a2.n) false in
  for i = 0 to a1.n - 1 do
    for j = 0 to a2.n - 1 do
      term.(i + a1.n * j) <- a1.term.(i) && a2.term.(j)
    done;
  done;
  term

let build_delta a b =
  let eta = Array.make_matrix (a.n * b.n) a.m 0 in
  for i = 0 to a.n - 1 do
    for j = 0 to b.n - 1 do
      for x = 0 to a.m - 1 do
        let q1 = a.delta.(i).(x) in
        let q2 = b.delta.(j).(x) in
        eta.(i + a.n * j).(x) <- if q1 = -1 || q2 = -1 then -1 else q1 + a.n * q2
      done;
    done;
  done;
  eta
  

let auto_inter a1 a2 =
{
  m = a1.m;
  n = a1.n * a2.n;
  init = a1.init + a2.init * a1.n;
  term = build_term a1 a2;
  delta = build_delta a1 a2
}

let description_0pair = {
initial = 0;
acceptants = [0];
transitions = [(0, 0, 1); (1, 0, 0); (0, 1, 0); (1, 1, 1)]
}
let description_mod2 = {
initial = 0;
acceptants = [2];
transitions = [(0, 1, 1); (1, 1, 2); (2, 1, 0); (0, 0, 0); (1, 0, 1); (2, 0, 2)]
}


(* Exercice 3.8 *)
(* A inclus dans B équivalent à A inter (B barre) = Ø *)
let inclus a b =
  not (langage_non_vide (auto_inter a (complementaire b)))

let equivalent a b = inclus a b && inclus b a
