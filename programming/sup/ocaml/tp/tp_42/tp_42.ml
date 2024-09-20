(*
   _________  ________        ___    ___ ___       ___  ___     
  |\___   ___\\   __  \      |\  \  /  /|\  \     |\  \|\  \    
  \|___ \  \_\ \  \|\  \     \ \  \/  / | \  \    \ \  \ \  \   
       \ \  \ \ \   ____\     \ \    / / \ \  \    \ \  \ \  \  
        \ \  \ \ \  \___|      /     \/   \ \  \____\ \  \ \  \ 
         \ \__\ \ \__\        /  /\   \    \ \_______\ \__\ \__\
          \|__|  \|__|       /__/ /\ __\    \|_______|\|__|\|__|
                             |__|/ \|__|                        
                                                                
                          3/05/2022                                                       
*)

(*
  Formules des indices :
  - fils gauche : 2i + 1
  - fils droit : 2i + 2
  - père : partie entière de (i - 1)/2
*)

let left i = 2 * i + 1
let right i = 2 * i + 2
let up i = (i - 1) / 2

module PrioQ :
sig
  type t
  val get_min : t -> (int * float)
  val extract_min : t -> (int * float)
  val insert : t -> (int * float) -> unit
  val length : t -> int
  val capacity : t -> int
  val make_empty : int -> t
  val decrease_priority : t -> (int * float) -> unit
  val mem : t -> int -> bool
end = struct

  type t =
    {mutable last : int;
     priorities : float array;
     keys : int array;
     mapping : int array}

  let length q = q.last + 1

  let capacity q = Array.length q.keys

  let make_empty n =
    {last = -1;
     priorities = Array.make n nan;
     keys = Array.make n 0;
     mapping = Array.make n (-1)}

  let mem q x =
    q.mapping.(x) >= 0

  let swap t i j =
    let tmp = t.(i) in
    t.(i) <- t.(j);
    t.(j) <- tmp

  let full_swap q i j =
    swap q.keys i j;
    swap q.priorities i j;
    swap q.mapping q.keys.(i) q.keys.(j) (* Bien échanger par rapport aux indices des clés dans mapping *)

  let get_min q = (q.keys.(0), q.priorities.(0))

  (* Attention, les indices correspondent bien aux clés *)
  let rec sift_up q i =
    let up = up i in
    if i > 0 && q.priorities.(i) < q.priorities.(up) then begin
      full_swap q i up;
      sift_up q up
    end

  (* Bien vérifier la capacité du tableau + faire le changement d'indice avant le sift_up *)
  let insert q (x, prio) =
    if length q = capacity q then failwith "dépassement de capacité";

    let i = q.last + 1 in
    q.priorities.(i) <- prio;
    q.keys.(i) <- x;
    q.mapping.(x) <- i;
    q.last <- i;
    sift_up q i

  let rec sift_down q i =
    let l = left i in
    let r = right i in
    let i_min = ref i in

    if l <= q.last && q.priorities.(l) < q.priorities.(!i_min) then i_min := l;
    if r <= q.last && q.priorities.(r) < q.priorities.(!i_min) then i_min := r;

    if !i_min <> i then begin
      full_swap q i !i_min;
      sift_down q !i_min
    end

  let extract_min q =
    if q.last < 0 then failwith "vide";

    let min = q.keys.(0) in
    let prio = q.priorities.(0) in
    full_swap q 0 q.last; (* d'abord faire le full swap *)
    q.mapping.(min) <- -1;
    q.last <- q.last - 1;
    sift_down q 0;
    min, prio

  (* Vérifier qu'on a bien une diminution de priorité *)
  let decrease_priority q (x, prio) =
    let i = q.mapping.(x) in
    assert (mem q x && prio <= q.priorities.(i));
    q.priorities.(i) <- prio;
    sift_up q i
end


type weighted_graph = (int * float) list array

let g0 : weighted_graph =
  [| [(1, 15.); (2, 16.); (3, 13.); (4, 9.)];
     [(0, 15.); (4, 7.); (5, 1.)];
     [(0, 16.); (3, 5.); (4, 5.); (5, 6.)];
     [(0, 13.); (2, 5.); (4, 3.)];
     [(0, 9.); (1, 7.); (2, 5.); (3, 3.)];
     [(1, 1.); (2, 6.)] |]

let random_graph n avg_outdegree =
  Random.init 0;
  let weight () = Random.float 100. in
  let build_adj i =
    let rec aux j =
      if j = n then
        []
      else if (i <> j) && Random.int (n - 1) < avg_outdegree then
        (j, weight ()) :: aux (j + 1)
      else aux (j + 1) in
    aux 0 in
  Array.init n build_adj

let g1 = random_graph 20 2

let g2 = random_graph 1000 10


let dijkstra g i =
  let n = Array.length g in
  let dist = Array.make n infinity in
  dist.(i) <- 0.;

  let prio = PrioQ.make_empty n in
  PrioQ.insert prio (i, 0.);

  while PrioQ.length prio <> 0 do
    let (j, dj) = PrioQ.extract_min prio in
    List.iter (fun (k, dk) ->
      let d = dj +. dk in
      if d < dist.(k) then begin
        if PrioQ.mem prio k then PrioQ.decrease_priority prio (k, d)
        else PrioQ.insert prio (k, d);

        dist.(k) <- d
      end
    ) g.(j)
  done;
  dist

let test_dijkstra () =
  let array_sum = Array.fold_left (+.) 0. in
  let t =
    [|infinity; 81.7504732238099763; 0.; 143.075476397307966; infinity;
      287.497339971473707; infinity; infinity; infinity; 217.478348335512379;
      infinity; infinity; infinity; 256.889526772049521; 87.4875853046628578;
      infinity; infinity; 146.271960347437471; 81.8422628400316654;
      infinity|] in
  assert (dijkstra g1 2 = t);
  assert (array_sum (dijkstra g2 10) = 73114.7316078792);
  print_endline "OK"


let dijkstra_tree g i =
  let n = Array.length g in
  let dist = Array.make n infinity in
  dist.(i) <- 0.;

  let prio = PrioQ.make_empty n in
  PrioQ.insert prio (i, 0.);

  let tree = Array.make n None in
  tree.(i) <- Some i;

  while PrioQ.length prio <> 0 do
    let (j, dj) = PrioQ.extract_min prio in
    List.iter (fun (k, dk) ->
      let d = dj +. dk in
      if d < dist.(k) then begin
        if PrioQ.mem prio k then PrioQ.decrease_priority prio (k, d)
        else PrioQ.insert prio (k, d);

        dist.(k) <- d;
        tree.(k) <- Some j
      end
    ) g.(j)
  done;
  dist, tree


let test_dijkstra_tree () =
  let _, tree = dijkstra_tree g1 2 in
  let t =
    [|None; Some 2; Some 2; Some 14; None; Some 13; None; None; None; Some 17;
    None; None; None; Some 9; Some 2; None; None; Some 18; Some 2; None|] in
  assert (t = tree);
  print_endline "OK"

let reconstruct_path p goal =
  let rec aux current =
    match p.(current) with
    | None -> failwith "non accessible"
    | Some j when j = current -> [current] (* Cas de base : on est arrivé au sommet de départ (qui se désigne par lui-même dans l'arbre de parcours) *)
    | Some j -> current :: aux j (* Attention : on mets le current, et on fait aux sur le suivant ! *)
  in List.rev (aux goal)


let test_reconstruct_path () =
  let _, t = dijkstra_tree g2 10 in
  let path = [10; 524; 54; 625; 343; 118; 771; 12] in
  assert (path = reconstruct_path t 12);
  print_endline "OK"

type commune =
  {id : int;
   insee : string;
   nom : string;
   pop : int;
   dep : string}


let lire_communes nom_fichier =
  let stream = open_in nom_fichier in
  let communes = ref [] in
  try
    while true do
      let next = input_line stream in
      Scanf.sscanf next "%d;%s@;%s@;%s@;%d" (fun id insee nom dep pop ->
        let com = {
          id; insee; nom; pop; dep
        } in
        communes := com :: !communes
      )
    done;
    assert false
  with
  | End_of_file -> close_in stream; Array.of_list (List.rev !communes)

let lire_graphe nb_communes fichier_adjacence =
  let stream = open_in fichier_adjacence in
  let gph = Array.make nb_communes [] in
  try
    while true do
      let next = input_line stream in
      Scanf.sscanf next "%d;%d" (fun x y ->
        gph.(x) <- y :: gph.(x);
        gph.(y) <- x :: gph.(y))
    done;
    assert false
  with
  | End_of_file -> close_in stream; gph

let tab_communes = lire_communes "communes.csv"

let g_adj = lire_graphe (Array.length tab_communes) "adjacences.csv"

let affiche chemin =
  let affiche_commune i =
    let c = tab_communes.(i) in
    Printf.printf "%s (%s) : %d\n" c.nom c.dep c.pop in
  List.iter affiche_commune chemin


exception Gagne of int
let saute_canton init =
  let n = Array.length tab_communes in
  let arbre = Array.make n None in
  arbre.(init) <- Some init;

  let opened = Queue.create () in
  Queue.push init opened;
  try
    while not (Queue.is_empty opened) do
      let x = Queue.pop opened in
      if tab_communes.(x).pop >= 50000 then raise (Gagne x);
      List.iter (fun y ->
        if arbre.(y) = None then begin
          arbre.(y) <- Some x;
          Queue.push y opened;
        end
      ) g_adj.(x)
    done;
    []
  with
  | Gagne x -> reconstruct_path arbre x

let commune_perdue =
  let max_dist = ref 0 in
  let communes = ref [[]] in
  for i = 0 to Array.length tab_communes - 1 do
    let dist = List.length (saute_canton i) in
    if dist = !max_dist then begin
      match !communes with
      | [] -> failwith "impossible"
      | x :: xs -> communes := (i :: x) :: xs
    end
    else if dist > !max_dist then begin
      communes := [i] :: !communes;
      max_dist := dist
    end
  done;
  List.hd !communes


let misanthrope g i =
  let n = Array.length g in
  let dist = Array.make n infinity in
  dist.(i) <- 0.;

  let prio = PrioQ.make_empty n in
  PrioQ.insert prio (i, float_of_int tab_communes.(i).pop);

  let tree = Array.make n None in
  tree.(i) <- Some i;

  while PrioQ.length prio <> 0 do
    let (j, pj) = PrioQ.extract_min prio in
    List.iter (fun k ->
      let pk = float_of_int tab_communes.(k).pop in
      let pop = pj +. pk in
      if pop < dist.(k) then begin
        if PrioQ.mem prio k then PrioQ.decrease_priority prio (k, pop)
        else PrioQ.insert prio (k, pop);

        dist.(k) <- pop;
        tree.(k) <- Some j
      end
    ) g.(j)
  done;
  dist, tree
  
