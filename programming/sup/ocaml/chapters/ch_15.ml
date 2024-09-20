open Printf

let mat = [|
  [|false; true; true; false; false; false|];
  [|false; false; false; false; false; false|];
  [|false; true; false; false; false; false|];
  [|false; true; false; false; false; true|];
  [|true; false; false; false; false; false|];
  [|false; false; true; true; true; false|];
|]

let graphe_15_2 = 
[| [2];
  [2; 6];
  [0; 1; 4; 6];
  [4; 7];
  [2; 3; 7];
  [4; 6; 8];
  [1; 2; 5; 8];
  [3; 4; 9];
  [5; 6];
  [7] |]

let g_non_connexe = 
[| [1; 2];
    [0; 2];
    [0; 1];
    [7];
    [8];
    [8];
    [];
    [3];
    [4; 5] |]
    
let g0 =
[| [1; 2];
    [2; 3; 4];
    [];
    [0; 5];
    [1; 2];
    [10];
    [1; 9];
    [8];
    [6];
    [7; 10];
    [11];
    [5] |]
        
        
let g0_miroir =
  [|[3];
    [6; 4; 0];
    [4; 1; 0];
    [1];
    [1];
    [11; 3];
    [8];
    [9];
    [7];
    [6];
    [9; 5];
    [10]|]

(* Exercice 15.2 *)

let liste_of_matrice m =
  let n = Array.length m in
  let m_list = Array.make n [] in
  for i = 0 to n - 1 do
    for j = n - 1 downto 0 do
      if m.(i).(j) then m_list.(i) <- j :: m_list.(i)
    done;
  done;
  m_list

let matrice_of_liste l =
  let n = Array.length l in
  let m = Array.make_matrix n n false in
  for i = 0 to n - 1 do
    let rec aux = function
    | [] -> ()
    | j :: xs -> m.(i).(j) <- true ; aux xs
    in aux l.(i)
  done;
  m

(* Exercice 15.5 *)

let dfs_complet m pre post =
  let n = Array.length m in
  let seen = Array.make n 0 in
  let rec explore x succ =
    if seen.(x) = 0 then begin
      seen.(x) <- 1 ;
      pre x ;
      let rec aux succ =
        match succ with
        | [] -> ()
        | y :: ys -> explore y m.(y) ; aux ys
      in aux succ ;
      post x ;
    end
  in
  for i = 0 to n - 1 do
    explore i m.(i)
  done

let affiche_dfs m =
  dfs_complet m
  (fun x -> printf "Ouverture %d\n" x)
  (fun x -> printf "Fermeture %d\n" x)

(* Exercice 15.8 *)

let bfs g start f =
  let n = Array.length g in
  let seen = Array.make n 0 in
  let opened = Queue.create () in
  seen.(start) <- 1;
  Queue.push start opened;
  while not (Queue.is_empty opened) do
    let x = Queue.pop opened in
    f x;
    List.iter (fun i ->
      if seen.(i) = 0 then begin
        seen.(i) <- 1 ; Queue.push i opened
      end) g.(x)
  done


(* Exercice 15.9 *)

let tableau_distances m x =
  let n = Array.length m in
  let dist = Array.make n (-1) in (* Si non traité, c'est à -1, sinon c'est la distance *)
  dist.(x) <- 0;
  let actual = ref [x] in
  while !actual <> [] do
    let nouveaux = ref [] in
    List.iter (fun x ->
      List.iter (fun y ->
        if dist.(y) = -1 then begin
          dist.(y) <- dist.(x) + 1;
          nouveaux := y :: !nouveaux
        end
      ) m.(x);
    ) !actual;
      actual := !nouveaux
  done;
  dist

(* Exercice 15.11 *)
type state = Vierge | Ferme | Ouvert

exception Cycle

let est_dag g =
  let n = Array.length g in
  let seen = Array.make n Vierge in
  seen.(0) <- Ouvert;

  let rec explore x =
    match seen.(x) with
    | Ferme -> ()
    | Ouvert -> raise Cycle
    | Vierge ->
      seen.(x) <- Ouvert;
      List.iter (fun y -> explore y) g.(x);
      seen.(x) <- Ferme
    end
  in try
    for i = 0 to n - 1 do
      explore i
    done;
    true
  with
  | Cycle -> false

let tri_topologique g =
  let n = Array.length g in
  let seen = Array.make n Vierge in
  seen.(0) <- Ouvert;
  let tri = ref [] in

  let rec explore x =
    match seen.(x) with
    | Ferme -> ()
    | Ouvert -> raise Cycle
    | Vierge ->
      seen.(x) <- Ouvert;
      List.iter explore g.(x);
      seen.(x) <- Ferme;
      tri := x :: !tri
  in
    for i = 0 to n - 1 do
      explore i
    done;
  !tri


(* Exercice 15.13 *)

let ex = [|
  [|3.; infinity; infinity; infinity|];
  [|infinity; infinity; infinity; infinity|];
  [|infinity; 4.; infinity; infinity|];
  [|infinity; 8.; 2.; infinity|]
|]

let floyd_warshall m =
  let n = Array.length m in
  let d = Array.make_matrix n n 0. in
  let suivants = Array.make_matrix n n None in
  for i = 0 to n - 1 do
    for j = 0 to n - 1 do
      d.(i).(j) <- m.(i).(j); (* Copie de la matrice d'adjacence *)
      if m.(i).(j) <> infinity then suivants.(i).(j) <- Some j (* Cas de base : tous les sommets distants d'un seul arc (None sur la diagonale si pas de bouclage sur soi-même) *)
    done;
  done;
  for k = 0 to n - 1 do
    for i = 0 to n - 1 do
      for j = 0 to n - 1 do
        let with_k = d.(i).(k) +. d.(k).(j) in
        if with_k <= d.(i).(j) then begin
          d.(i).(j) <- with_k;
          suivants.(i).(j) <- suivants.(i).(k)
        end
      done;
    done;
  done;
  d, suivants

let reconstruit prochain i j =
  if i = j then [i] (* Un sommet est toujours accessible depuis lui-même *)
  else match prochain.(i).(j) with
  | None -> failwith "Pas accessible"
  | Some k -> k :: reconstruit prochain k j
