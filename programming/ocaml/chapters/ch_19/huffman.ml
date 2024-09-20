module PriorityQueue :
sig
  type 'a t
  val extract_min : 'a t -> ('a * int)
  val insert : 'a t -> ('a * int) -> unit
  val length : 'a t -> int
  val of_list : ('a * int) list -> 'a t
end = struct

  type 'a t = {mutable last : int; heap : ('a * int) array}

  let length q = q.last + 1

  let swap t i j =
    let tmp = t.(i) in
    t.(i) <- t.(j);
    t.(j) <- tmp

  let rec sift_up t i =
    let parent = (i - 1) / 2 in
    if i > 0 && snd t.(i) < snd t.(parent) then
      begin
        swap t i parent;
        sift_up t parent
      end

  let insert q (x, prio) =
    let t = q.heap in
    if q.last >= Array.length t - 1 then failwith "insert"
    else
      begin
        q.last <- q.last + 1;
        t.(q.last) <- (x, prio);
        sift_up t q.last
      end

  let rec sift_down t i last =
    let left = 2 * i + 1 and right = 2 * i + 2 in
    let smallest = ref i in
    if left <= last && snd t.(left) < snd t.(i) then
      smallest := left;
    if right <= last && snd t.(right) < snd t.(!smallest) then
      smallest := right;
    if !smallest <> i then
      begin
        swap t i !smallest;
        sift_down t !smallest last
      end

  let extract_min q =
    if q.last < 0 then failwith "extract_min"
    else
      begin
        let t = q.heap in
        let min = t.(0) in
        swap t q.last 0;
        q.last <- q.last - 1;
        sift_down t 0 q.last;
        min
      end

  let heapify t =
    let q = {last = Array.length t - 1; heap = t} in
    for i = q.last / 2 downto 0 do
      sift_down t i q.last
    done;
    q

  let of_list u =
    let t = Array.of_list u in
    heapify t

  let make n x =
    {last = 0; heap = Array.make n x}
end

(* Comme PriorityQueue est un peu long, on crée un alias P. *)

module PrioQ = PriorityQueue


type arbre =
  | Feuille of int
  | Noeud of arbre * arbre

(* Renvoie un tableau de taille 256 donnant le nombre d'apparitions
 * de chaque caractère dans le fichier. *)
let table_occurrences (nomdefichier : string) : int array =
    let fichier = open_in_bin nomdefichier in
    let occs = Array.make 256 0 in
    begin
      try
        while true do
          let c = input_byte fichier in
          occs.(c) <- occs.(c) + 1
      done
      with
      | End_of_file -> ()
    end;
    close_in fichier;
    occs

(* Renvoie la liste des (Feuille c, occs.(c)) pour tous les caractères (i.e. entiers
 * de [0..255]) apparaissant au moins une fois. *)
let foret (occs : int array) : (arbre * int) list =
  let characters = List.filter (fun c -> occs.(c) > 0) (List.init 256 (fun i -> i)) in
  List.map (fun c -> Feuille c, occs.(c)) characters

(* Version récursive, moins dégueu *)
let foret occs =
  let rec aux k =
    if k = 256 then []
    else if occs.(k) > 0 then (Feuille k, occs.(k)) :: aux (k + 1) 
    else aux (k + 1)
  in aux 0

(* Renvoie l'arbre de Huffman associé à une table d'occurrences. *)
let construit_arbre (table_occs : int array) : arbre =
  let q = PrioQ.of_list (foret table_occs) in
  while PrioQ.length q > 1 do
    let a1, n1 = PrioQ.extract_min q in
    let a2, n2 = PrioQ.extract_min q in
    PrioQ.insert q (Noeud (a1, a2), n1 + n2)
  done;
  let f, _ = PrioQ.extract_min q in
  f

(* Renvoie un t : bool list array de taille 256 tel que t.(c) soit le code
 * associé à l'octet c. *)
let table_code (arbre : arbre) : bool list array =
  let t = Array.make 256 [] in
  let rec aux arbre path =
    match arbre with
    | Feuille c -> t.(c) <- List.rev path
    | Noeud (g, d) -> aux g (false :: path); aux d (true :: path)
  in aux arbre [];
  t

(* Sérialisation et dé-sérialisation de l'arbre. *)

(* Écrit la version sérialisée de l'arbre  *)
let rec output_arbre (f : out_channel) (a : arbre) : unit =
  match a with
  | Feuille c -> output_byte f 1; output_byte f c
  | Noeud (g, d) ->
    output_byte f 0; output_arbre f g;
    output_byte f 0; output_arbre f d

let rec input_arbre (f : in_channel) : arbre =
  let c = input_byte f in
  if c = 1 then Feuille (input_byte f)
  else
    (* Pas besoin de savoir quand ça s'arrête : ça va le faire naturellement (deux feuilles d'afilée) car l'arbre est complet *)
    let g = input_arbre f in 
    let d = input_arbre f in
    Noeud (g, d) (* On ne peut pas mettre les input_arbre directement dans le Noeud :
                  on ne sait pas dans quel ordre les appels seront faits *)


(* Écriture dans un fichier *)

type out_channel_bits = {
    o_fichier : out_channel;
    mutable o_accumulateur : int;
    mutable o_bits_accumules : int
}

let open_out_bits fn =
    {o_fichier = open_out_bin fn;
     o_accumulateur = 0;
     o_bits_accumules = 0}

(* Attention de bien mettre le if après, pour enregistrer le dernier octet *)
let output_bit (f : out_channel_bits) (b : bool) : unit =
  (* acc <- acc + b.2^i *)
  if b then f.o_accumulateur <- f.o_accumulateur + (1 lsl f.o_bits_accumules);
  f.o_bits_accumules <- f.o_bits_accumules + 1;
  if f.o_bits_accumules = 8 then begin
    output_byte f.o_fichier f.o_accumulateur;
    f.o_accumulateur <- 0;
    f.o_bits_accumules <- 0
  end

let close_out_bits (f : out_channel_bits) : unit =
  if f.o_bits_accumules = 0 then
    output_byte f.o_fichier 0
  else begin
    output_byte f.o_fichier f.o_accumulateur; (* On a accumulé avec poids faible à droite : pas besoin de décaller vers la gauche, les zéros sont déjà en bout *)
    output_byte f.o_fichier (8 - f.o_bits_accumules)
  end;
  close_out f.o_fichier

(* Lecture dans un fichier *)

type in_channel_bits = {
    i_fichier : in_channel;
    mutable i_accumulateur : int;
    mutable i_bits_accumules : int;
    i_taille : int
}

let open_in_bits fn =
    let fichier = open_in_bin fn in
    {i_fichier = fichier;
     i_accumulateur = 0;
     i_bits_accumules = 0;
     i_taille = in_channel_length fichier}

let input_bit (f : in_channel_bits) : bool =
  if f.i_bits_accumules = 0 then begin
    f.i_accumulateur <- input_byte f.i_fichier;
    f.i_bits_accumules <- 8;
    (* Si on vient de lire le dernier octet, enlever les zéros rembourrés *)
    if pos_in f.i_fichier = f.i_taille - 1 then begin
      let pad = input_byte f.i_fichier in (* Le dernier octet indique le nombre de zéros de padding *)
      f.i_bits_accumules <- f.i_bits_accumules - pad
    end
  end;
  (* On récupère le poids faible : s'il vaut 1 c'est impair, sinon c'est pair *)
  let b = f.i_accumulateur mod 2 = 1 in
  f.i_accumulateur <- f.i_accumulateur / 2;
  f.i_bits_accumules <- f.i_bits_accumules - 1;
  b


let close_in_bits f = close_in f.i_fichier


(* Compression d'un octet *)

let compresse_byte (f : out_channel_bits) (a_plat : bool list array) (c : int) =
  List.iter (fun b -> output_bit f b) a_plat.(c)

let rec decompresse_byte (f : in_channel_bits) (a : arbre) : int =
  match a with
  | Feuille c -> c
  | Noeud (d, g) ->
    decompresse_byte f (if input_bit f then g else d)

let compresse_fichier (nom_in : string) (nom_out : string) : unit =
  let f_in = open_in_bin nom_in in
  let f_out = open_out_bits nom_out in
  let tree = construit_arbre (table_occurrences nom_in) in
  let code = table_code tree in
  output_arbre f_out.o_fichier tree;
  try
    while true do
      let c = input_byte f_in in
      compresse_byte f_out code c
    done
  with
  | End_of_file -> ();
  close_in f_in;
  close_out_bits f_out


let decompresse_fichier (nom_in : string) (nom_out : string) : unit =
  let f_in = open_in_bits nom_in in
  let f_out = open_out_bin nom_out in
  let a = input_arbre f_in.i_fichier in
  try
    while true do
      let c = decompresse_byte f_in a in
      output_byte f_out c
    done
  with
  | End_of_file -> ();
  close_in_bits f_in;
  close_out f_out


let main () =
  let error_and_exit () =
    let command_name = Sys.argv.(0) in
    Printf.eprintf "Usage : \n";
    Printf.eprintf
      "%s compress <input-file> <compressed-output-file>\n"
      command_name;
    Printf.eprintf
      "%s decompress <compressed-input-file> <output-file>\n"
      command_name;
    exit 1 in
  if Array.length Sys.argv < 4 then error_and_exit ();
  let commande = Sys.argv.(1) in
  let nom_in = Sys.argv.(2) in
  let nom_out = Sys.argv.(3) in
  if commande = "compress" then
    compresse_fichier nom_in nom_out
  else if commande = "decompress" then
    decompresse_fichier nom_in nom_out
  else error_and_exit ()

let () = main ()

