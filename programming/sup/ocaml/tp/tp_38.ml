(*
   _________  ________        ___    ___ ___    ___ ___    ___ ___      ___ ___  ___  ___     
  |\___   ___\\   __  \      |\  \  /  /|\  \  /  /|\  \  /  /|\  \    /  /|\  \|\  \|\  \    
  \|___ \  \_\ \  \|\  \     \ \  \/  / | \  \/  / | \  \/  / | \  \  /  / | \  \ \  \ \  \   
       \ \  \ \ \   ____\     \ \    / / \ \    / / \ \    / / \ \  \/  / / \ \  \ \  \ \  \  
        \ \  \ \ \  \___|      /     \/   /     \/   /     \/   \ \    / /   \ \  \ \  \ \  \ 
         \ \__\ \ \__\        /  /\   \  /  /\   \  /  /\   \    \ \__/ /     \ \__\ \__\ \__\
          \|__|  \|__|       /__/ /\ __\/__/ /\ __\/__/ /\ __\    \|__|/       \|__|\|__|\|__|
                             |__|/ \|__||__|/ \|__||__|/ \|__|                                
                                                                                              
                                      5/04/2022                                                        
*)

type sommet = int
type graphe = sommet list array

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

let g1 = 
  [| [1; 4];
     [0; 2; 4; 7];
     [1; 5];
     [6; 8];
     [0; 1];
     [2; 7; 8];
     [3; 8];
     [1; 5; 8];
     [3; 5; 6; 7];
     [] |]

let g2 =
  [| [1; 2];
     [0; 2];
     [0; 1];
     [7];
     [8];
     [8];
     [];
     [3];
     [4; 5] |]

let g3 =
  [| [1; 2; 3];
     [0; 3];
     [0];
     [0; 1] |]

(* ———————————— *)
(*  Exercice 1  *)
(* ———————————— *)

let dfs pre post g x0 =
  let n = Array.length g in
  let vus = Array.make n 0 in

  let rec explore x =
    if vus.(x) = 0 then begin
      vus.(x) <- 1;
      pre x;
      List.iter (fun i -> explore i) g.(x);
      post x
    end
  in
  explore x0

(* ———————————— *)
(*  Exercice 3  *)
(* ———————————— *)

let bfs f g x0 =
  let ouverts = Queue.create () in
  Queue.push x0 ouverts;

  let vus = Array.make (Array.length g) 0 in
  vus.(x0) <- 1;

  while not (Queue.is_empty ouverts) do
    let x = Queue.pop ouverts in
    f x;
    List.iter (fun y ->
      if vus.(y) = 0 then begin
        vus.(y) <- 1;
        Queue.push y ouverts
      end
    ) g.(x)
  done

(* ———————————— *)
(*  Exercice 4  *)
(* ———————————— *)

let largeur_front f g x0 =
  let vus = Array.make (Array.length g) 0 in
  vus.(x0) <- 1;

  let rec aux frontiere nouveaux =
    match frontiere, nouveaux with
    | [], [] -> ()
    | [], _ -> aux nouveaux []
    | x :: xs, _ ->
      f x;
      (* Ajouter les voisins seulement s'ils n'ont pas été déjà explorés *)
      (* Cette fonction évite une concaténation *)
      let rec voisins a_traiter nouveaux =
        match a_traiter with
        | [] -> aux xs nouveaux
        | y :: ys when vus.(y) = 1 -> voisins ys nouveaux
        | y :: ys ->
          vus.(y) <- 1;
          voisins ys (y :: nouveaux)
      (* List.rev pour que notre fonction ajoute bien les éléments dans l'ordre décroissant,
      comme ça à l'exploration ça sera dans l'ordre croissant *)
      in voisins (List.rev g.(x)) nouveaux
  in aux [x0] []

(* ———————————— *)
(*  Exercice 5  *)
(* ———————————— *)

let accessible_naif g x y =
  let vus = Array.make (Array.length g) 0 in
  largeur_front (fun i -> vus.(i) <- 1) g x;
  vus.(y) = 1

exception Found
let accessible g x y =
  try
    largeur_front (fun i -> if i = y then raise Found) g x;
    false
  with
  | Found -> true

(* ———————————— *)
(*  Exercice 6  *)
(* ———————————— *)

let tab_composantes g =
  let n = Array.length g in
  let connexes = Array.make n (-1) in

  let rec explore x start =
    if connexes.(x) = -1 then begin
      connexes.(x) <- start;
      List.iter (fun y -> explore y start) g.(x)
    end
  in
  for x = 0 to n - 1 do
    explore x x
  done;
  connexes

let liste_composantes g =
  let n = Array.length g in
  let vus = Array.make n 0 in
  let connexes = ref [] in

  let rec explore x comp =
    if vus.(x) = 0 then begin
      vus.(x) <- 1;
      comp := x :: !comp;
      List.iter (fun y -> explore y comp) g.(x);
    end
  in
  for x = 0 to n - 1 do
    if vus.(x) = 0 then begin
      let comp = ref [] in
      explore x comp;
      connexes := !comp :: !connexes
    end
  done;
  !connexes

(* ———————————— *)
(*  Exercice 7  *)
(* ———————————— *)

let arbre_dfs g x0 =
  let n = Array.length g in
  let parcours = Array.make n (-1) in

  let rec explore x parent =
    if parcours.(x) = -1 then begin
      parcours.(x) <- parent;
      List.iter (fun i -> explore i x) g.(x);
    end
  in
  explore x0 x0;
  parcours

let arbre_bfs g x0 =
  let ouverts = Queue.create () in
  Queue.push x0 ouverts;

  let parcours = Array.make (Array.length g) (-1) in
  parcours.(x0) <- x0;

  while not (Queue.is_empty ouverts) do
    let x = Queue.pop ouverts in
    List.iter (fun y ->
      if parcours.(y) = -1 then begin
        parcours.(y) <- x;
        Queue.push y ouverts
      end
    ) g.(x)
  done;
  parcours

let chemin g x =
  let p = ref [x] in
  let i = ref x in
  while g.(!i) != !i && g.(!i) != -1 do
    p := g.(!i) :: !p;
    i := g.(!i)
  done;
  match !p with
  | [x] -> None
  | _ -> Some !p

(* ———————————— *)
(*  Exercice 8  *)
(* ———————————— *)

let dfs_pile pre g i =
  let visites = Array.make (Array.length g) false in
  let rec traite pile =
    match pile with
    | [] -> ()
    | x :: xs when not visites.(x) ->
      visites.(x) <- true;
      pre x;
      (* Pile à droite de rev_append : on ajoute au-dessus! *)
      (* Si on veut dans l'ordre croissant, on reverse g avant *)
      traite (List.rev_append g.(x) pile)
    | x :: xs -> traite xs
  in traite [i]

let dfs_it pre g i =
  let n = Array.length g in
  let vus = Array.make n false in
  let traite = Stack.create () in
  Stack.push i traite;

  while not (Stack.is_empty traite) do
    let x = Stack.pop traite in
    if vus.(x) = false then begin
      vus.(x) <- true;
      pre x;
      List.iter (fun y -> Stack.push y traite) g.(x)
    end
  done

(* ———————————— *)
(*  Exercice 9  *)
(* ———————————— *)

let pseudo_dfs pre g i =
  let n = Array.length g in
  let vus = Array.make n false in
  vus.(i) <- true;

  let traite = Stack.create () in
  Stack.push i traite;

  let rec ajoute x =
    if not vus.(x) then begin
      Stack.push x traite;
      vus.(x) <- true
    end
  in

  while not (Stack.is_empty traite) do
    let x = Stack.pop traite in
    pre x;
    List.iter ajoute g.(x)
  done

let small = [|
  [1; 2; 3];
  [0; 3];
  [0];
  [3]
|]

