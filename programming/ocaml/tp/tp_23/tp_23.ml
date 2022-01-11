(************)
(* Partie 1 *)
(************)

type dict =
  | V
  | N of char * dict * dict


let mots = ["diane"; "dire"; "diva"; "divan"; "divin"; "do"; "dodo";
            "dodu"; "don"; "donc"; "dont"; "ame"; "ames"; "amen"]

let d_mots =
  N ('a',
     N ('m',
        N ('e',
           N ('n',
              N ('$', V, V),
              N ('s',
                 N ('$', V, V),
                 N ('$', V, V))),
           V),
        V),
     N ('d',
        N ('o',
           N ('n',
              N ('t',
                 N ('$', V, V),
                 N ('c',
                    N ('$', V, V),
                    N ('$', V, V))),
              N ('d',
                 N ('u',
                    N ('$', V, V),
                    N ('o',
                       N ('$', V, V),
                       V)),
                 N ('$', V, V))),
           N ('i',
              N ('v',
                 N ('i',
                    N ('n',
                       N ('$', V, V),
                       V),
                    N ('a',
                       N ('n',
                          N ('$', V, V),
                          N ('$', V, V)),
                       V)),
                 N ('r',
                    N ('e',
                       N ('$', V, V),
                       V),
                    N ('a',
                       N ('n',
                          N ('e',
                             N ('$', V, V),
                             V),
                          V),
                       V))),
              V)),
        V))

let exemple =
  ["ame"; "ames"; "amen"; "amer"; "ami"; "amis";
   "amie"; "amies"; "ane"; "anes"; "annee"; "annees";
   "anti"; "avide"; "mais"; "misa"; "misas"; "mesa";
   "same"; "tian"; "tina"; "nain"; "nina"; "isthme";
   "medisant"; "ultime"; "magique"; "essai"; "est"; "qui"]

(* Exercice 1 *)

let rec est_bien_forme = function
  | V | N ('$', V, _) -> true
  | N ('$', _, _) -> false
  | N (_, g, d) -> est_bien_forme g && est_bien_forme d


(************)
(* Partie 2 *)
(************)

(* Exercice 3 *)

type mot = char list

let mot_of_string s =
  String.fold_right (fun c list -> c :: list) s ['$']

let rec afficher = function
  | ['$'] -> print_newline ()
  | c :: cs -> print_char c; afficher cs
  | _ -> failwith "mot mal formé"


(************)
(* Partie 3 *)
(************)

(* Exercice 4 *)

(* On suppose l'arbre bien formé donc Un dollar = Un mot *)
let rec cardinal = function
  | V -> 0
  | N (c, left, right) -> cardinal left + cardinal right + (if c = '$' then 1 else 0)

let teste_cardinal () =
  assert (cardinal d_mots = 14);
  print_endline "Test ok"

let rec appartient dict mot =
  match dict, mot with
  | V, [] -> true (* On passe déjà une liste de char, qui contient donc un dollar à la fin -> on match bien un V *)
  | N (c, left, right), x :: xs ->
    if x = c then appartient left xs else appartient right mot
  | _ -> false

let appartient_string dict s =
  appartient dict (mot_of_string s)

let teste_appartient () =
  let f s = assert (appartient_string d_mots s) in
  let g s = assert (not (appartient_string d_mots s)) in
  List.iter f mots;
  g "amee";
  g "";
  g "am";
  g "amena";
  g "amen$";
  print_endline "Test ok"

(* Exercice 5 *)

let rec make_dict = function
| [] -> V
| x :: xs -> N (x, make_dict xs, V)

(* Si on a la bonne lettre, on continue de parcourir à gauche (les enfants)
Sinon, on cherche à droite (dans les frères) *)
let rec ajouter dict mot =
  match dict, mot with
  | V, [] -> dict (* Le mot est déjà présent *)
  | V, x :: xs -> N (x, ajouter V xs, V)
  | N (c, left, right), x :: xs ->
    if x = c then N (c, ajouter left xs, right)
    else N (c, left, ajouter right mot)
  | _ -> failwith "mal formé"

let rec dict_of_list = function
  | [] -> V
  | x :: xs -> ajouter (dict_of_list xs) (mot_of_string x)

let teste_dict_of_list () =
  let d = dict_of_list mots in
  assert (cardinal d = 14);
  List.iter (fun s -> assert (appartient_string d s)) mots;
  let d_ex = dict_of_list exemple in
  assert (cardinal d_ex = 30);
  List.iter (fun s -> assert (appartient_string d_ex s)) exemple;
  print_endline "Test ok"

(* Exercice 6 *)

(* On accumule les caractères, et on affiche tout dès qu'on a un dollar
(un peu le principe du trie quoi) *)
(* À droite on ne rajoute pas le caractère au préfixe (ce sont des frères, ils n'ont pas cette lettre) *)
let rec afficher_mots mots =
  let rec aux mots prefixe =
    match mots with
    | V -> ()
    | N ('$', V, right) ->
      afficher (List.rev prefixe);
      aux right prefixe;
    | N (c, left, right) ->
      aux left (c :: prefixe);
      aux right prefixe;
  in aux mots []

(* On ne traite pas le cas $ séparement *)
(* À gauche on ajoute 1 à la longueur car c'est la suite du mot; à droite non car de la même longueur*)
let rec longueur_maximale = function
  | V -> -1
  | N (_, left, right) -> max (1 + longueur_maximale left) (longueur_maximale right)

let afficher_mots_longs dict n =
  let rec aux mots prefixe longueur =
    match mots with
    | V -> ()
    | N ('$', V, right) ->
      if longueur > n then afficher (List.rev prefixe);
      aux right prefixe longueur;
    | N (c, left, right) ->
      aux left (c :: prefixe) (longueur + 1);
      aux right prefixe longueur;
  in aux dict [] 1

(************)
(* Partie 4 *)
(************)

(* Exercice 7 *)

let lire_fichier f =
  let dict = ref V in 
  let stream = open_in f in
  try
    while true do
      let next = input_line stream in
      dict := ajouter !dict (mot_of_string next)
    done;
    V
  with
    | End_of_file -> close_in stream; !dict

(************)
(* Partie 5 *)
(************)

(* Exercice 8 *)

let calculer_occurrences s =
  let t = Array.make 256 0 in
  String.iter (fun c -> let i = int_of_char c in t.(i) <- t.(i) + 1) s;
  t

let afficher_condition predicat dict s =
  let rec aux occs prefixe = function
    | V -> ()
    | N ('$', V, right) ->
      if predicat occs then afficher (List.rev prefixe);
      aux occs prefixe right
    | N (c, left, right) ->
      let i = int_of_char c in
      aux occs prefixe right;
      if occs.(i) <> 0 then begin
        let new_occs = Array.copy occs in (* faire une copie, sinon les lettres consommées ne sont pas rendues *)
        new_occs.(i) <- new_occs.(i) - 1;
        aux new_occs (c :: prefixe) left
      end
  in aux (calculer_occurrences s) [] dict

let afficher_mots_contenus = afficher_condition (fun _ -> true)
let afficher_anagrammes = afficher_condition (fun occs ->
  let vide = ref true in
  for i = 0 to 255 do
    vide := !vide && occs.(i) = 0
  done;
  !vide
)

(* Exercice 9 *)

let rec filtrer_mots_contenus dict occs =
  match dict with
  | V -> V
  | N ('$', V, right) ->
    N ('$', V, filtrer_mots_contenus right occs)
  | N (c, left, right) when occs.(int_of_char c) = 0 ->
    filtrer_mots_contenus right occs
  | N (c, l, r) ->
    let i = int_of_char c in
    let r' = filtrer_mots_contenus r occs in
    occs.(i) <- occs.(i) - 1;
    let l' = filtrer_mots_contenus l occs in
    if l' = V then r' (* Si à gauche c'est un V, il ne faut pas l'inclure car le caractère n'est pas un dollar *)
    else N (c, l', r')

let filtrer_mots_contenant dict s = failwith "à implémenter"

let filtrer_anagrammes dict s = failwith "à implémenter"


(************)
(* Partie 6 *)
(************)

(* Exercice 10 *)

let afficher_decompositions dict mot = failwith "à implémenter"

let decompose_anagrammes dict mot = failwith "à implémenter"

(* Exercice 11 *)

let decompose_anagrammes_unique dict mot = failwith "à implémenter"

