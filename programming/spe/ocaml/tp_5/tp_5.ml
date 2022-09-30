type state = int

type nfa =
  {delta : state list array array;
  accepting : bool array}

let graphviz_nfa a filename =
  let open Printf in
  let n = Array.length a.delta in
  let m = Array.length a.delta.(0) in
  let out = open_out filename in
  fprintf out "digraph a {\nrankdir = LR;\n";
  (* noms des états *)
  let lettre i = String.make 1 (char_of_int (i + int_of_char 'a')) in
  (* etats *)
  for q = 0 to n - 1 do
    let shape = if a.accepting.(q) then "doublecircle" else "circle" in
    fprintf out "node [shape = %s, label = %d] %d;\n" shape q q
  done;
  (* etat initial *)
  fprintf out "node [shape = point]; I\n";
  fprintf out "I -> %i;\n" 0;
  (* transitions *)
    let labels = Array.make_matrix n n [] in
  for q = 0 to n - 1 do
    for x = m - 1 downto 0 do
      let ajoute q' = labels.(q).(q') <- lettre x :: labels.(q).(q') in
      List.iter ajoute a.delta.(q).(x)
    done
  done;
  for q = 0 to n - 1 do
    for q' = 0 to n - 1 do
      let s = String.concat "," labels.(q).(q') in
      if s <> "" then
        fprintf out "%i -> %i [ label = \"%s\" ];\n" q q' s
    done
  done;
  fprintf out "}\n";
  close_out out

let genere_pdf input_file output_file =
  Sys.command (Printf.sprintf "dot -Tpdf %s -o %s" input_file output_file)


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


type dfa =
  {delta_d : state array array;
  accepting_d : bool array}

let to_nfa a =
  let n = Array.length a.delta_d in
  let m = Array.length a.delta_d.(0) in
  let delta = Array.make_matrix n m [] in
  for q = 0 to n - 1 do
    for x = 0 to m - 1 do
      delta.(q).(x) <- [a.delta_d.(q).(x)]
    done
  done;
  {delta = delta; accepting = a.accepting_d}

let graphviz_dfa a = graphviz_nfa (to_nfa a)

(* --------------- *)
(*  Préliminaires  *)
(* --------------- *)

let rec merge u v =
  match u, v with
  | l, [] | [], l -> l
  | x :: xs, y :: ys when x = y -> x :: merge xs ys
  | x :: xs, y :: ys when x < y -> x :: merge xs v
  | x :: xs, y :: ys -> y :: merge u ys

(* Complexité min(|u| + |v|) *)

let rec is_empty = function
  | Empty -> true
  | Eps | Letter _ -> false
  | Sum (r1, r2) -> is_empty r1 && is_empty r2
  | Concat (r1, r2) -> is_empty r1 || is_empty r2
  | Star _ -> false

let rec contains_epsilon = function
  | Empty | Letter _ -> false
  | Eps | Star _ -> true
  | Sum (r1, r2) -> contains_epsilon r1 || contains_epsilon r2
  | Concat (r1, r2) -> contains_epsilon r1 && contains_epsilon r2

(* Complexité |r| *)

(* ------------------------------ *)
(*  Calcul des ensembles P, S, F  *)
(* ------------------------------ *)

let rec prefix = function
  | Empty | Eps -> []
  | Letter c -> [c]
  | Sum (r1, r2) -> merge (prefix r1) (prefix r2)
  | Concat (r1, r2) -> 
    if is_empty r1 || is_empty r2 then []
    else if contains_epsilon r1 then merge (prefix r1) (prefix r2)
    else prefix r1
  | Star r -> prefix r

let rec suffix = function
  | Empty | Eps -> []
  | Letter c -> [c]
  | Sum (r1, r2) -> merge (suffix r1) (suffix r2)
  | Concat (r1, r2) ->
    if is_empty r1 || is_empty r2 then []
    else if contains_epsilon r2 then merge (suffix r1) (suffix r2)
    else suffix r2
  | Star r -> suffix r

let rec make_couples c u =
  match u with
  | [] -> []
  | x :: xs -> (c, x) :: make_couples c xs

let rec combine a b =
  match a with
  | [] -> []
  | x :: xs -> make_couples x b @ combine xs b

let rec factor = function
  | Letter _ | Eps | Empty -> []
  | Sum (r1, r2) -> factor r1 @ factor r2
  | Concat (r1, r2) ->
    if is_empty r1 || is_empty r2 then []
    else
      let others = merge (factor r1) (factor r2) in
    merge others (combine (suffix r1) (prefix r2))
  | Star r -> 
    merge (factor r) (combine (suffix r) (prefix r))

let rec number_of_letters = function
  | Empty | Eps -> 0
  | Letter c -> 1
  | Sum (r1, r2) | Concat (r1, r2) -> number_of_letters r1 + number_of_letters r2
  | Star r -> number_of_letters r

let linearize regex =
  let rec aux i = function
    | Empty -> Empty, i
    | Eps -> Eps, i
    | Letter c -> (Letter (c, i)), i + 1
    | Sum (r1, r2) ->
      let l1, i1 = aux i r1 in
      let l2, i2 = aux i1 r2 in
      Sum (l1, l2), i2 
    | Concat (r1, r2) ->
      let l1, i1 = aux i r1 in
      let l2, i2 = aux i1 r2 in
      Concat (l1, l2), i2 
    | Star r ->
      let l1, i1 = aux i r in
      Star l1, i1
  in 
  let lin, _ = aux 1 regex in
  lin

let r_test = Concat (
  Sum(Letter 2, Letter 0),
  Star( Concat (
    Letter 1,
    Sum (Letter 0, Letter 2)
  ))
)

let r2 = Sum (
  Concat (
    Star ( Concat (Letter 0, Letter 1)),
    Letter 2
  ),
  Concat (
    Letter 3,
    Concat (
      Letter 0,
      Sum (
        Eps,
        Letter 0
      )
    )
  )
)

let r3 = Concat (
  Star (Sum (
    Concat (Letter 0, Letter 1),
    Letter 0
  )),
  Star (Letter 2)
)

let rec max_letter = function
  | Empty | Eps -> -1
  | Letter i -> i
  | Sum (r1, r2) | Concat (r1, r2) -> max (max_letter r1) (max_letter r2)
  | Star r -> max_letter r

(* Les transitions étiquetées par "c" (et le fait de l'avoir gardé lors de la linéarisation)
   permet de ne pas mettre de marques sur les transitions : l'automate fonctionne tout de suite. *)
let glushkov r =
  let lin = linearize r in
  let n = number_of_letters r + 1 in
  let m = max_letter r + 1 in
  let delta = Array.make_matrix n m [] in
  let accepting = Array.make n false in
  let add_transition i x j = delta.(i).(x) <- j :: delta.(i).(x) in

  List.iter (fun (c, i) -> add_transition 0 c i) (prefix lin);
  List.iter (fun (_, i) -> accepting.(i) <- true) (suffix lin);
  List.iter (fun ((_, i1), (c2, i2)) -> add_transition i1 c2 i2) (factor lin);
  if contains_epsilon r then accepting.(0) <- true;
  { delta ; accepting }

let delta_set a arr x =
  let n = Array.length arr in
  let t = Array.make n false in
  for i = 0 to n - 1 do
    if arr.(i) then List.iter (fun x -> t.(x) <- true) a.delta.(i).(x)
  done;
  t

let has_accepting_state a t =
  let has_accept = ref false in
  let i = ref 0 in
  while !i < Array.length t && not (!has_accept) do
    if t.(!i) && a.accepting.(!i) then has_accept := true;
    incr i
  done;
  !has_accept

let nfa_accept a u =
  let set = ref (Array.init (Array.length a.delta) (fun i -> i = 0)) in
  List.iter (fun x -> set := delta_set a !set x) u;
  has_accepting_state a !set

let build_set a s x =
  let n = Array.length a.delta in
  let s_array = Array.make n false in
  List.iter (fun i -> s_array.(i) <- true) s;
  let res_array = delta_set a s_array x in
  let res = ref [] in
  for i = n - 1 downto 0 do
    if res_array.(i) then res := i :: !res
  done;
  !res

(* Version directe, n'utilisant pas delta_set :
   pas de construction de deux arrays intermédiaires *)
let build_set d s x =
  let n = Array.length d.accepting_d in
  let u = Array.make n false in
  let process_transition i =
    List.iter (fun j -> u.(j) <- true) delta.(i).(x)
  in List.iter process_transition s;
  let res = ref [] in
  for i = n - 1 downto 0 do
    if u.(i) then res <- i :: !res
  done;
  !res

let rec contains_final a = function
  | [] -> false
  | x :: _ when a.accepting.(x) -> true
  | _ :: xs -> contains_final a xs

let powerset a =
  let m = Array.length a.delta.(0) in
  let n = Array.length a.delta in
  let sets = Hashtbl.create n in
  Hashtbl.add sets [0] 0;
  let k = ref 1 in
  let transitions = ref [] in
  let opened = ref [[0]] in
  let nb_opened = ref 1 in
  while !nb_opened > 0 do
    let news = ref [] in
    nb_opened := 0;
    List.iter (fun s ->
      for c = 0 to m - 1 do
        let s' = build_set a s c in
        if not (Hashtbl.mem sets s') then begin
          Hashtbl.add sets s' !k;
          news := s' :: !news;
          incr nb_opened;
          incr k
        end;
        let id = Hashtbl.find sets s in
        let id' = Hashtbl.find sets s' in
        transitions := (id, c, id') :: !transitions
      done;
      ) !opened;
      opened := !news
  done;
  let delta_d = Array.make_matrix !k m (-1) in
  List.iter (fun (i, c, j) -> delta_d.(i).(c) <- j) !transitions;
  let accepting_d = Array.make !k false in
  Hashtbl.iter (fun s id -> if contains_final a s then accepting_d.(id) <- true) sets;

  { delta_d ; accepting_d }

(* Version bien plus propre : on remarque qu'on réalise un
   parcours en profondeur du graphe associé à l'automate ! *)

let powerset a =
  let n = Array.length a.accepting_d in
  let m = Array.length a.delta.(0) in
  let transitions = ref [] in
  let sets = Hashtbl.create n in
  Hashtbl.add sets [0] 0;
  let id = ref 0 in
  
  (* Fonction auxiliaire utile pour l'ajout dans la
     hashtbl : s'occupe de tout! *)
  let add_set s =
    try
      false, Hashtbl.find sets s
    with
    | Not_found ->
      incr id;
      Hashtbl.add sets s !id;
      true, !id

  let rec explore q i =
    for x = 0 to m - 1 do
      let q' = build_set a q x in
      let is_new, j = add_set q' in
      transitions := (i, x, j) :: !transitions;
      if is_new then explore q' j
    done
  in explore [0] 0;

  let delta = Array.make_matrix (!id + 1) m (-1) in
  List.iter (fun i x j -> delta.(i).(x) <- j) !transitions;

  let accepting = Array.make (!id + 1) false in
  let rec has_accepting = function
    | [] -> false
    | x :: xs -> a.accepting.(x) || has_accepting xs
  in Hashtbl.iter (fun s i -> accepting.(i) <- has_accepting s);

  { delta = delta ; accepting = accepting }
