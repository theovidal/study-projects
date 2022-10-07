type etat = int
type lettre = int
type mot = lettre list

type afd =
  {m : int;
   n : int;
   init : etat;
   term : bool array;
   delta : etat array array}

let lire_automate ic =
  let scan = Scanf.bscanf (Scanf.Scanning.from_channel ic) in
  let get_int () =
    scan "%d " (fun x -> x) in
  let n = get_int () in
  let m = get_int () in
  let nb_term = get_int () in
  let init = get_int () in
  let term = Array.make n false in
  for i = 0 to nb_term - 1 do
    term.(get_int ()) <- true;
  done;
  let delta = Array.make_matrix n m 0 in
  for q = 0 to n - 1 do
    for x = 0 to m - 1 do
      delta.(q).(x) <- get_int ()
    done
  done;
  {n; m; delta; term; init}

let ecrire_automate oc a =
  let open Printf in
  let nb_term =
    Array.fold_left (fun acc b -> acc + if b then 1 else 0) 0 a.term in
  fprintf oc "%d %d %d\n" a.n a.m nb_term;
  fprintf oc "%d\n" a.init;
  for q = 0 to a.n - 1 do
    if a.term.(q) then printf "%d " q
  done;
  fprintf oc "\n";
  for q = 0 to a.n - 1 do
    for x = 0 to a.m - 1 do
      fprintf oc "%d " a.delta.(q).(x)
    done;
    fprintf oc "\n"
  done;
  flush oc

let ecrire_graphviz oc a =
  let open Printf in
  let n = Array.length a.delta in
  let m = Array.length a.delta.(0) in
  fprintf oc "digraph a {\nrankdir = LR;\n";
  (* noms des états *)
  let lettre i = String.make 1 (char_of_int (i + int_of_char 'a')) in
  (* etats *)
  for q = 0 to n - 1 do
    let shape = if a.term.(q) then "doublecircle" else "circle" in
    fprintf oc "node [shape = %s, label = %d] %d;\n" shape q q
  done;
  (* etat initial *)
  fprintf oc "node [shape = point]; I\n";
  fprintf oc "I -> %i;\n" a.init;
  (* transitions *)
  let labels = Array.make_matrix n n [] in
  for q = 0 to n - 1 do
    for x = m - 1 downto 0 do
      let q' = a.delta.(q).(x) in
      labels.(q).(q') <- lettre x :: labels.(q).(q');
    done
  done;

  for q = 0 to n - 1 do
    for q' = 0 to n - 1 do
      let l = String.concat "," labels.(q).(q') in
      if l <> "" then
        fprintf oc "%i -> %i [ label = \"%s\" ];\n" q q' l
    done
  done;
  fprintf oc "}\n"


let rec delta_star a q mot =
  match mot with
  | [] -> q
  | x :: xs ->
    let q' = a.delta.(q).(x) in
    if q' = -1 then -1
    else delta_star a q' xs

let accepte a mot =
  let q = delta_star a a.init mot in
  q <> -1 && a.term.(q)

(* On fait un parcours en profondeur à partir de l'état initial. *)

let complet a =
  let flag = ref true in
  for q = 0 to a.n - 1 do
    for x = 0 to a.m - 1 do
      flag := !flag && a.delta.(q).(x) <> -1
    done
  done;
  !flag

let accessibles a =
  let vus = Array.make a.n false in
  let rec dfs q =
    if q <> -1 && not vus.(q) then begin
      vus.(q) <- true;
      Array.iter dfs a.delta.(q)
    end in
  dfs a.init;
  vus

let langage_non_vide a =
  let vus = accessibles a in
  let q = ref 0 in
  while !q < a.n && not (vus.(!q) && a.term.(!q)) do
    incr q
  done;
  !q < a.n

let inverse a =
  let g = Array.make_matrix a.n a.n false in
  for q = 0 to a.n - 1 do
    for x = 0 to a.m - 1 do
      let q' = a.delta.(q).(x) in
      if q' <> -1 then g.(q').(q) <- true
    done
  done;
  g

let coaccessibles a =
  let g_inv = inverse a in
  let vus = Array.make a.n false in
  let rec dfs q =
    if not vus.(q) then begin
      vus.(q) <- true;
      for q' = 0 to a.n - 1 do
        if g_inv.(q).(q') then dfs q'
      done
    end in
  for q = 0 to a.n - 1 do
    if a.term.(q) then dfs q
  done;
  vus

let est_emonde a =
  let tous = Array.make a.n true in
  (accessibles a = tous) && (coaccessibles a = tous)

let complementaire a =
  let n = a.n in
  let m = a.m in
  let delta = Array.init n (fun i -> Array.copy a.delta.(i)) in
  let init = a.init in
  let term = Array.map not a.term in
  {n; m; delta; init; term}

let complete a =
  let term = Array.make (a.n + 1) false in
  for q = 0 to a.n - 1 do
    term.(q) <- a.term.(q)
  done;
  let delta = Array.make_matrix (a.n + 1) a.m a.n in
  for q = 0 to a.n - 1 do
    for x = 0 to a.m - 1 do
      let q' = a.delta.(q).(x) in
      if q' = -1 then delta.(q).(x) <- a.n
      else delta.(q).(x) <- q'
    done
  done;
  {n = a.n + 1; m = a.m; init = a.init; term; delta}

let auto_inter a1 a2 =
  let n = a1.n * a2.n in
  let m = min a1.m a2.m in
  let delta = Array.make_matrix n m (-1) in
  let f i j = i * a2.n + j in
  for i = 0 to a1.n - 1 do
    for j = 0 to a2.n - 1 do
      for x = 0 to m - 1 do
        let q = f i j in
        let q' = f a1.delta.(i).(x) a2.delta.(j).(x) in
        delta.(q).(x) <- q'
      done
    done;
  done;
  let init = f a1.init a2.init in
  let term = Array.make n false in
  for i = 0 to a1.n - 1 do
    for j = 0 to a2.n - 1 do
      term.(f i j) <- a1.term.(i) && a2.term.(j)
    done
  done;
  {n; m; delta; init; term}


let inclus a1 a2 =
  let a2c = complementaire a2 in
  let a1_inter_a2c = auto_inter a1 a2c in
  not (langage_non_vide a1_inter_a2c)

let equivalent a1 a2 =
  let a1_complet = complete a1 in
  let a2_complet = complete a2 in
  inclus a1_complet a2_complet && inclus a2_complet a1_complet


type state = int

type nfa =
  {delta : state list array array;
  accepting : bool array}

let rec merge u v =
  match u, v with
  | [], _ -> v
  | _, [] -> u
  | x :: xs, y :: ys ->
    if x = y then x :: merge xs ys
    else if x < y then x :: merge xs v
    else y :: merge u ys

type 'a regex =
  | Empty
  | Eps
  | Letter of 'a
  | Sum of 'a regex * 'a regex
  | Concat of 'a regex * 'a regex
  | Star of 'a regex


(* Parses a string into an int regex.
 * The alphabet is assumed to be a subset of a..z, and is converted
 * to [0..25] (a -> 0, b -> 1...),
 * Charcater '&' stands for "epsilon", and character '#' for "empty".
 * Spaces are ignored, and the usual priority rules apply.
 *)

let parse string =
  let open Printf in
  let to_int c =
    assert ('a' <= c && c <= 'z');
    int_of_char c - int_of_char 'a' in
  let s = Stream.of_string string in
  let rec peek () =
    match Stream.peek s with
    | Some ' ' -> Stream.junk s; peek ()
    | Some c -> Some c
    | None -> None in
  let eat x =
    match peek () with
    | Some y when y = x -> Stream.junk s; ()
    | Some y -> failwith (sprintf "expected %c, got %c" x y)
    | None -> failwith "incomplete" in
  let rec regex () =
    let t = term () in
    match peek () with
    | Some '|' -> eat '|'; Sum (t, regex ())
    | _ -> t
  and term () =
    let f = factor () in
    match peek () with
    | None | Some ')' | Some '|' -> f
    | _ -> Concat (f, term ())
 and factor () =
    let rec aux acc =
      match peek () with
      | Some '*' -> eat '*'; aux (Star acc)
      | _ -> acc in
    aux (base ())
  and base () =
    match peek () with
    | Some '(' -> eat '('; let r = regex () in eat ')'; r
    | Some '&' -> eat '&'; Eps
    | Some '#' -> eat '#'; Empty
    | Some (')' | '|' | '*' as c) -> failwith (sprintf "unexpected '%c'" c)
    | Some c -> eat c; Letter (to_int c)
    | None -> failwith "unexpected end of string" in
  let r = regex () in
  try Stream.empty s; r
  with _ -> failwith "trailing ')' ?"


let rec string_of_regex e =
  let open Printf in
  let to_char i =
    char_of_int (i + int_of_char 'a') in
  let priorite = function
    | Sum (_, _) -> 1
    | Concat (_, _) -> 2
    | Star _ -> 3
    | _ -> 4 in
  let parenthese expr parent =
    if priorite expr < priorite parent then
      sprintf "(%s)" (string_of_regex expr)
    else string_of_regex expr in
  match e with
  | Empty -> "#"
  | Eps -> "&"
  | Letter x -> sprintf "%c" (to_char x)
  | Sum (f, f') -> sprintf "%s|%s" (parenthese f e) (parenthese f' e)
  | Concat (f, f') -> sprintf "%s%s" (parenthese f e) (parenthese f' e)
  | Star f -> sprintf "%s*" (parenthese f e)



let rec is_empty = function
  | Empty -> true
  | Sum (e, f) -> is_empty e && is_empty f
  | Concat (e, f) -> is_empty e || is_empty f
  | _ -> false


let rec contains_epsilon = function
  | Eps | Star _ -> true
  | Letter _ | Empty -> false
  | Sum (e, f) -> contains_epsilon e || contains_epsilon f
  | Concat (e, f) -> contains_epsilon e && contains_epsilon f


let rec prefix = function
  | Eps | Empty -> []
  | Letter x -> [x]
  | Sum (e, f) -> merge (prefix e) (prefix f)
  | Concat (e, f) ->
    if is_empty e || is_empty f then []
    else if contains_epsilon e then merge (prefix e) (prefix f)
    else prefix e
  | Star e -> prefix e

let rec suffix = function
  | Eps | Empty -> []
  | Letter x -> [x]
  | Sum (e, f) -> merge (suffix e) (suffix f)
  | Concat (e, f) ->
    if is_empty e || is_empty f then []
    else if contains_epsilon f then merge (suffix e) (suffix f)
    else suffix f
  | Star e -> suffix e

let rec combine l1 l2 =
  match l1 with
  | [] -> []
  | x :: xs ->
    let with_x = List.map (fun y -> (x, y)) l2 in
    with_x @ combine xs l2

let rec factor = function
  | Eps | Empty -> []
  | Letter _ -> []
  | Sum (e, f) -> merge (factor e) (factor f)
  | Concat (e, f) ->
    if is_empty e || is_empty f then []
    else
      let isolated = merge (factor e) (factor f) in
      merge isolated (combine (suffix e) (prefix f))
  | Star e ->
    merge (factor e) (combine (suffix e) (prefix e))


let rec number_of_letters = function
  | Empty | Eps -> 0
  | Letter _ -> 1
  | Star e -> number_of_letters e
  | Concat (e, f) | Sum (e, f) -> number_of_letters e + number_of_letters f

let linearize e =
  let i = ref 0 in
  let rec aux = function
    | Empty -> Empty
    | Eps -> Eps
    | Letter x -> incr i; Letter (x, !i)
    | Sum (e, f) ->
      let e' = aux e in
      Sum (e', aux f)
    | Concat (e, f) ->
      let e' = aux e in
      Concat (e', aux f)
    | Star e -> Star (aux e) in
  aux e

let rec max_letter = function
  | Empty | Eps -> -1
  | Star e -> max_letter e
  | Concat (e, f) | Sum (e, f) -> max (max_letter e) (max_letter f)
  | Letter i -> i

let glushkov e : nfa =
  let e_lin = linearize e in
  let pref = prefix e_lin in
  let fact = factor e_lin in
  let suf = suffix e_lin in
  let n = number_of_letters e in
  let m = max_letter e in

  (* one state per letter  plus the initial state *)
  (* size of alphabet : m + 1 (from 0 to m inclusive) *)
  let delta = Array.make_matrix (n + 1) (m + 1) [] in

  (* add_transition i x j adds j to the set delta(i, x) *)
  let add_transition i x j = delta.(i).(x) <- j :: delta.(i).(x) in

  (* add all the transitions from the authorized factors *)
  List.iter (fun ((_, i), (x, j)) -> add_transition i x j) fact;
  (* add the transitions from the initial state (authorized prefixes) *)
  List.iter (fun (x, i) -> add_transition 0 x i) pref;
  (* choose the accepting states according to the authorized suffixes *)
  let final = Array.make (n + 1) false in
  List.iter (fun (_, i) -> final.(i) <- true) suf;
  (* make the initial state accepting iff epsilon is in the language *)
  if contains_epsilon e then final.(0) <- true;

  {delta = delta; accepting = final}

let rec delta_set a set x =
  let n = Array.length set in
  let new_set = Array.make n false in
  let add_state s = new_set.(s) <- true in
  for q = 0 to n - 1 do
    if set.(q) then List.iter add_state a.delta.(q).(x)
  done;
  new_set

let has_accepting_state a set =
  let n = Array.length set in
  let rec loop i =
    if i = n then false
    else if set.(i) && a.accepting.(i) then true
    else loop (i + 1) in
  loop 0


let nfa_accept a word =
  let n = Array.length a.delta in
  let rec delta_star_set set word =
    match word with
    | [] -> set
    | x :: xs ->
      let new_set = delta_set a set x in
      delta_star_set new_set xs in
  let initial_states = Array.make n false in
  initial_states.(0) <- true;
  let final_states = delta_star_set initial_states word in
  has_accepting_state a final_states




(* takes s, an ordered list of nfa states, and returns delta(s, letter) as on
 * ordered list of nfa states. *)
let build_set (a : nfa) s letter =
  let n = Array.length a.delta in
  (* t.(q) will become true if q is part of delta(s) *)
  let t = Array.make n false in
  let process_state q =
    List.iter (fun q' -> t.(q') <- true) a.delta.(q).(letter) in
  List.iter process_state s;
  (* convert t to an ordered list of states *)
  let new_set = ref [] in
  for q = n - 1 downto 0 do
    if t.(q) then new_set := q :: !new_set
  done;
  !new_set

type dfa =
  {delta_d : state array array;
  accepting_d : bool array}

let to_afd (a : dfa) : afd =
  {n = Array.length a.delta_d;
   m = Array.length a.delta_d.(0);
   init = 0;
   term = a.accepting_d;
   delta = a.delta_d}


let powerset (a : nfa) : afd =
  let n = Array.length a.delta in
  let m = Array.length a.delta.(0) in

  (* key = dfa state, as an ordered list of nfa states
   * value = index of the state in the dfa
   * We immediately add the initial dfa state *)
  let sets = Hashtbl.create n in
  Hashtbl.add sets [0] 0;

  (* last_set is equal to the index of the last dfa state we added *)
  let last_set = ref 0 in

  (* dfa transitions : list of triples (i, x, j), meaning delta(i, x) = j *)
  let transitions = ref [] in

  (* takes a dfa state s (ordered list of nfa states), returns (b, i) where :
   * - b is true if s is a new state, false if it was already in sets
   * - i is the value associated with s in sets (either pre-existing or
   *   newly added) *)
  let add_set s =
    try
      false, Hashtbl.find sets s
    with
    | Not_found ->
      incr last_set;
      Hashtbl.add sets s !last_set;
      true, !last_set in

  (* depth-first search of the dfa
   * - s if an existing dfa state (already in sets)
   * - i is its associated value (to avoid a hashtable lookup)
   * new dfa states are added to sets as they are discovered *)
  let rec explore s i =
    for letter = 0 to m - 1 do
      let new_set = build_set a s letter in
      let is_new, j = add_set new_set in
      transitions := (i, letter, j) :: !transitions;
      if is_new then explore new_set j
    done in
  (* explore from the initial state *)
  explore [0] 0;

  (* we build the actual dfa from the information we computed *)

  (* number of states of the dfa *)
  let n' = !last_set + 1 in

  (* transition matrix of the dfa *)
  let delta' = Array.make_matrix n' m (-1) in
  List.iter (fun (i, x, j) -> delta'.(i).(x) <- j) !transitions;

  (* accepting states of the dfa *)

  (* a dfa state is accepting iff it contains at least one accepting
   * nfa state *)
  let rec is_accepting = function
    | [] -> false
    | q :: qs -> a.accepting.(q) || is_accepting qs in

  let accepting' = Array.make n' false in
  Hashtbl.iter (fun s i -> accepting'.(i) <- is_accepting s) sets;

  to_afd {delta_d = delta'; accepting_d = accepting'}
