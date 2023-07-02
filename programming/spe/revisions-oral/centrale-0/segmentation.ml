
(********************************************************************)
(* Concours Centrale-Supélec                                        *)
(* Sujet 0 - MPI                                                    *)
(* https://www.concours-centrale-supelec.fr                         *)
(* CC BY-NC-SA 3.0                                                  *)
(********************************************************************)

let texte_preface = "préfacedanslaquelleilestétablique,malgréleursnomsenosetenis,leshérosdel'histoirequenousallonsavoirl'honneurderaconteranoslecteursn'ontriendemythologique."

type lexique = (string, int) Hashtbl.t

(* Lexique correspondant à l'exemple proposé dans le sujet *)
let dico_ex : lexique =
  let h = Hashtbl.create 4 in
  let add (m, c) = Hashtbl.add h m c in
  List.iter add [("a", 1); ("ab", 1); ("aba", 2); ("bb", 1)];
  h

(* Vérifie qu'un fichier de lexique est conforme au format demandé *)
let verifie_format nom_fichier =
  let f = open_in nom_fichier in
  begin
    try
      while true do
        match String.split_on_char ' ' (input_line f) with
        | [mot; occ] ->
           assert (String.length mot <= 100);
           assert (int_of_string occ >= 1);
        | _ -> failwith "Erreur de format"
      done
    with End_of_file -> close_in f
  end

let ouvre_lexique nom_fichier =
  verifie_format nom_fichier;
  let f = open_in nom_fichier in
  let h = Hashtbl.create 100 in
  let longueur_max = ref 0 in
  try
    while true do
      match String.split_on_char ' ' (input_line f) with
      | [mot; occ] ->
        Hashtbl.add h mot (int_of_string occ);
        longueur_max := max !longueur_max (String.length mot)
      | _ -> failwith "Erreur de format"
    done;
    h, 0
  with
  | End_of_file -> close_in f; h, !longueur_max

let est_mot h mot = Hashtbl.mem h mot

let score h mot =
  if est_mot h mot then Hashtbl.find h mot |> log
  else neg_infinity

let generer_segmentation texte indices =
  let n = String.length texte in
  let rec aux indices texte =
    match indices with
    | [] -> texte
    | x :: is when x = n - 1 -> aux is texte
    | i :: is ->
      (String.sub texte 0 (i+1)) ^ " " ^ (String.sub texte (i+1) (n - i - 1))
      |> aux is
  in aux indices texte
  

let segmentation lexique longueur_max texte =
  let n = String.length texte in
  let segmentations = ref [] in

  let rec aux debut indices =
    if debut = n then begin
      print_string "yep\n";
      segmentations := generer_segmentation texte indices :: !segmentations
    end
    else
    for i = 1 to longueur_max do
      if debut + i < n && Hashtbl.mem lexique (String.sub texte debut i)
        then aux (debut + i + 1) (debut + i :: indices)
    done
  in
  aux 0 [];
  !segmentations

let teste_segmentation () =
  let seg1 = segmentation dico_ex 3 "abaaba" in
  assert (List.length seg1 = 4);
  List.iter (fun s -> Printf.printf "%s\n" s) seg1;

  let seg2 = segmentation dico_ex 3 "babbab" in
  assert (List.length seg2 = 0)

let stats () =
  let h, longueur_max = ouvre_lexique "data/les_miserables.lex" in
  Printf.printf "Nombre de mots : %d\n" (Hashtbl.length h);
  let nb_occ_1 = ref 0 in
  Hashtbl.iter (fun mot occ ->
    if occ = 1 then incr nb_occ_1;
  ) h;

  Printf.printf "Mot le plus long : longueur %d\n" longueur_max;
  Printf.printf "Nombre de mots apparaissant une fois : %d\n" !nb_occ_1

let () =
  teste_segmentation ()
  (* pour après
  if Array.length Sys.argv < 2 then begin
    print_string "Usage: program <input_file>";
    exit (-1)
  end
  let lexique, longueur_max = ouvre_lexique (Sys.argv.(1)) in
  let seg = segmentation lexique longueur_max  in
  *)
