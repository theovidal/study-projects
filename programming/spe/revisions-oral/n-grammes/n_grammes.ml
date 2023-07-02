type successeurs = {
  occurences : (int, int) Hashtbl.t;
  somme_occurences : int;
  (* Somme * caractère *)
  sommes : (int * int) array
}

type n_gramme = (string, successeurs) Hashtbl.t

type modele = int * successeurs * n_gramme

(* Prend une hashtable d'occurences et un nombre total de caractères *)
let construit_sommes table =
  let nb_caracteres = Hashtbl.length table in
  let sommes = Array.make nb_caracteres (0, 0) in
  let somme_occurences = ref 0 in
  let current = ref 0 in
  Hashtbl.iter (fun character value ->
    if !current = 0 then sommes.(0) <- (value, character)
    else begin
      let previous, _ = sommes.(!current - 1) in
      sommes.(!current) <- (previous + value, character)
    end;
    incr current;
    somme_occurences := value + !somme_occurences
  ) table;
  sommes, !somme_occurences
    
let construit_probas (nb_caracteres, zero_gramme, n_gramme) =
  let n_gramme_probas = Hashtbl.create 100 in
  
  Hashtbl.iter (fun substring occurences ->
    let sommes, somme_occurences = construit_sommes occurences in
    
    Hashtbl.add n_gramme_probas substring {
      occurences = occurences;
      somme_occurences = somme_occurences;
      sommes = sommes
    }
  ) n_gramme;
  let sommes_zero, somme_occurences_zero = construit_sommes zero_gramme in

  nb_caracteres, {
    occurences = zero_gramme;
    sommes = sommes_zero;
    somme_occurences = somme_occurences_zero
  }, n_gramme_probas
            
let construit_ngramme texte n =
  let n_gramme = Hashtbl.create 100 in
  let zero_gramme = Hashtbl.create 20 in
  let nb_caracteres_texte = ref 0 in

  let increment_zero_gramme c =
    match Hashtbl.find_opt zero_gramme c with
    | None -> Hashtbl.add zero_gramme c 1; incr nb_caracteres_texte
    | Some v -> Hashtbl.replace zero_gramme c (v + 1)
  in
  increment_zero_gramme (int_of_char texte.[0]);

  for i = 1 to String.length texte - 1 do
    let c = int_of_char texte.[i] in
    increment_zero_gramme c;
    for k = i - 1 downto max (i - n) 0 do
      let substring = String.sub texte k (i - k) in
      match Hashtbl.find_opt n_gramme substring with
      | None -> 
        let occurences = Hashtbl.create 10 in
        Hashtbl.add occurences c 1;
        Hashtbl.add n_gramme substring occurences
      | Some occurences -> begin
        match Hashtbl.find_opt occurences c with
        | None -> Hashtbl.add occurences c 1
        | Some v -> Hashtbl.replace occurences c (v + 1)
        end;
    done
  done;
  construit_probas (!nb_caracteres_texte, zero_gramme, n_gramme)

let teste_construit_ngramme () =
  let (nb_caracteres, zero_gramme, n_gramme) = construit_ngramme "ababaacb aab, ab" 2 in
  assert (nb_caracteres = 5);
  assert (7 = Hashtbl.find zero_gramme.occurences (int_of_char 'a'));
  let successeurs = Hashtbl.find n_gramme "ab" in
  assert (Hashtbl.find successeurs.occurences (int_of_char ',') = 1);
  assert (Hashtbl.find successeurs.occurences (int_of_char 'a') = 2);

  assert (successeurs.somme_occurences = 3);

  let successeurs' = Hashtbl.find n_gramme "a" in
  assert (Hashtbl.find_opt successeurs'.occurences (int_of_char ',') = None);
  assert (Hashtbl.find successeurs'.occurences (int_of_char 'a') = 2);
  assert (successeurs'.somme_occurences = 7);

  print_string "All tests passed\n"


let rec plus_petit_superieur tab x i =
  let s, _ = tab.(i) in
  if s >= x then plus_petit_superieur tab x (i - 1)
  else if i = Array.length tab then i
  else i + 1

(* Dichotomie dans le tableau des sommes :*)
(* choisir un entier aléatoire et trouver le caractère correspondant *)
(* dont le nombre d'occurences suit immédiatement ce choix aléatoire *)
let choisit_aleatoirement succ =
  let target = Random.int succ.somme_occurences in
  let nb_caracteres = Hashtbl.length succ.occurences in
  
  let rec dicho inf sup =
    let m = (inf + sup) / 2 in
    let sum, character = succ.sommes.(m) in
    if sum == target then character
    else if sup - inf <= 1 then begin
      let indice = plus_petit_superieur succ.sommes sum m in
      let _, new_character = succ.sommes.(indice) in
      new_character
    end
    else if sum > target then dicho inf (m - 1)
    else dicho (m + 1) sup
    
  in dicho 0 (nb_caracteres - 1)
              
exception Found of int

let predit_caractere (_, zero_gramme, n_gramme) motif =
  let n = String.length motif in
  try
    (* Test des N-grammes, (N-1)-grammes, ..., 1-grammes *)
    for i = n downto 1 do
      let g = String.sub motif (n - i) i in
      match Hashtbl.find_opt n_gramme g with
      | None -> ()
      | Some successeurs ->
        raise (Found (choisit_aleatoirement successeurs))
    done;
    (* On en a trouvé aucun : on se rabat sur les 0-grammes *)
    raise (Found (choisit_aleatoirement zero_gramme))

  with 
  | Found c -> c

let generate_text model n text threshold =
  let len = String.length text in
  let result = ref text in
  for i = len to threshold do
    let n_gramme = String.sub !result (i - n - 1) n in
    let next = char_of_int (predit_caractere model n_gramme) in
    result := Printf.sprintf "%s%c" !result next
  done;
  !result

let () =
  teste_construit_ngramme ();
  
  if Array.length Sys.argv < 4 then begin
    print_string "Usage: program <n> <input> <threshold>";
    exit 1;
  end;
  Random.self_init ();
  let n = int_of_string Sys.argv.(1) in
  let input = open_in Sys.argv.(2) in
  let text = input_line input in
  let threshold = int_of_string Sys.argv.(3) in

  let model = construit_ngramme text n in
  let result = generate_text model n "Bonjour" threshold in
  print_string result
  
