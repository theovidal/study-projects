(*
   _________  ________        ___    ___ ___       ___      ___ 
  |\\___   ___\\\\   __  \\      |\\  \\  /  /|\\  \\     |\\  \\    /  /|
  \\|___ \\  \\_\\ \\  \\|\\  \\     \\ \\  \\/  / | \\  \\    \\ \\  \\  /  / /
       \\ \\  \\ \\ \\   ____\\     \\ \\    / / \\ \\  \\    \\ \\  \\/  / / 
        \\ \\  \\ \\ \\  \\___|      /     \\/   \\ \\  \\____\\ \\    / /  
         \\ \\__\\ \\ \\__\\        /  /\\   \\    \\ \\_______\\ \\__/ /   
          \\|__|  \\|__|       /__/ /\\ __\\    \\|_______|\\|__|/    
                             |__|/ \\|__|                        
                                                                
                            17/05/2022                                    
*)

type arbre =
  | Vide
  | Feuille of char
  | Noeud of arbre * arbre

let rec bien_forme = function
  | Vide | Feuille _ -> true
  | Noeud (Vide, Vide) -> false
  | Noeud (f, g) -> bien_forme f && bien_forme g


type arbre_code =
  | F of char
  | N of arbre_code * arbre_code

type bitstream = bool list

(* ––– Décodage ––– *)
let rec decode_caractere t s =
  match t, s with
  | F c, _ -> c, s
  | N (f, _), false :: xs -> decode_caractere f xs
  | N (_, g), true :: xs -> decode_caractere g xs
  | _ -> failwith "je m'en fout de l'ordre!!!!!! Vous écrivez vos matrices correctement!!!!"

let string_of_char_list u = String.of_seq (List.to_seq u)

let decode_texte code u =
  let rec aux stream acc =
    if stream = [] then acc else
    let next_char, s = decode_caractere code stream in
    aux s (next_char :: acc)
  in string_of_char_list (List.rev (aux u []))

(* ––– Encodage ––– *)
type table_code = bitstream array

let cree_table f =
  let table = Array.make 256 [] in
  let rec aux code stream =
    match code with
    | F c -> table.(int_of_char c) <- List.rev stream
    | N (f, g) -> aux f (false :: stream) ; aux g (true :: stream)

  in aux f [];
  table

let c = N (
  N (
    F 'c',
    N (
      F 'a',
      F 'b'
    )
  ),
  F 'd'
)

let encode code s =
  let rec aux i u =
    if i = String.length s then u
    else aux (i + 1) (u @ code.(int_of_char s.[i]))
  in aux 0 []

(* Algorithme de Huffman *)

let occurences s =
  let occ = Array.make 256 0 in
  for k = 0 to String.length s - 1 do
    let i = int_of_char s.[k] in
    occ.(i) <- occ.(i) + 1 
  done;
  occ

let foret s =
  let occ = occurences s in
  let rec aux i acc =
    if i = 256 then acc
    else if occ.(i) = 0 then aux (i + 1) acc
    else aux (i + 1) ((F (char_of_int i), occ.(i)) :: acc)
in aux 0 []

(* Module de queue de priorité récupéré dans le TP 42 *)

let left i = 2 * i + 1
let right i = 2 * i + 2
let up i = (i - 1) / 2

module PrioQ :
sig
  type t
  val extract_min : t -> (arbre_code * int)
  val insert : t -> (arbre_code * int) -> unit
  val length : t -> int
  val of_list : (arbre_code * int) list -> t
end = struct

  type t =
    {mutable last : int;
      keys : (arbre_code * int) array}

  let length q = q.last + 1

  let swap t i j =
    let tmp = t.(i) in
    t.(i) <- t.(j);
    t.(j) <- tmp

  (* Attention, les indices correspondent bien aux clés *)
  let rec sift_up q i =
    let up = up i in
    if i > 0 && snd q.keys.(i) < snd q.keys.(up) then begin
      swap q.keys i up;
      sift_up q up
    end

  (* Bien vérifier la capacité du tableau + faire le changement d'indice avant le sift_up *)
  let insert q x =
    let i = q.last + 1 in
    q.keys.(i) <- x;
    q.last <- i;
    sift_up q i

  let of_list t =
    let queue = {
      last = -1 ;
      keys = Array.make (List.length t) (F '\n', 0)
    } in
    List.iter (fun x -> insert queue x) t;
    queue

  let rec sift_down q i =
    let l = left i in
    let r = right i in
    let i_min = ref i in

    if l <= q.last && snd q.keys.(l) < snd q.keys.(!i_min) then i_min := l;
    if r <= q.last && snd q.keys.(r) < snd q.keys.(!i_min) then i_min := r;

    if !i_min <> i then begin
      swap q.keys i !i_min;
      sift_down q !i_min
    end

  let extract_min q =
    if q.last < 0 then failwith "vide";

    let (min, min_prio) = q.keys.(0) in
    swap q.keys 0 q.last;
    q.last <- q.last - 1;
    sift_down q 0;
    min, min_prio
end

(* File à implémenter correctement *)
let huffman s =
  let forest = PrioQ.of_list (foret s) in
  while PrioQ.length forest <> 1 do
    let t1, n1 = PrioQ.extract_min forest in
    let t2, n2 = PrioQ.extract_min forest in
    PrioQ.insert forest ((N (t1, t2)), (n1 + n2))
  done;
  fst (PrioQ.extract_min forest)

let compresse s =
  let code = huffman s in
  code, encode (cree_table code) s

(*nice code bro*)