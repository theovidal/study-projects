open Scanf
open PQ


(* La fonction lit_graphe renvoie un tableau de liste de paires
  représentant le graphe en liste d'ajacence c'est à dire que si x est
  voisin de y à distance d alors la fonction renverra un tableau t tel
  que la liste t.(x) contiendra la paire (y,d) et t.(y) contiendra la
  paire (x,d) *)   
let lit_graphe () = 
  let fp_graphe = Scanning.open_in "graphe.txt" in
  let read_int () = bscanf fp_graphe "%d" (fun x:int -> x) in
  let read_arete () = bscanf fp_graphe " %d %f" (fun x y -> (x,y)) in
  let read_newline () = bscanf fp_graphe "%c" (fun x -> ()) in
  let nb_noeuds = read_int () in
  let _ = read_newline () in
  let graphe = Array.make nb_noeuds [] in
  for i = 0 to nb_noeuds-1 do
    let nb_voisins = read_int () in
    for j = 0 to nb_voisins-1 do
      graphe.(i) <- read_arete () :: graphe.(i)
    done ;
    read_newline () 
  done ;
  Scanning.close_in fp_graphe ;
  graphe

let lit_position () =
  let fp_pos = Scanning.open_in "positions.txt" in
  let read_int () = bscanf fp_pos "%d%c" (fun x _ -> x) in
  let read_paire x = bscanf fp_pos " %f %f%c" (fun x y _-> (x,y)) in
  let nb_noeuds = read_int () in
  let positions = Array.init nb_noeuds read_paire in
  Scanning.close_in fp_pos ;
  positions

  
let graphe = lit_graphe ()
let positions = lit_position () 

let diametre_terre = 12742.
let degres_vers_radians = 2. *. acos 0. /. 180.

let composantes () =
  let n = Array.length graphe in
  let c = Array.make n (-1) in
  let queue = Queue.create () in

  let rec explore num =
    while not (Queue.is_empty queue) do
      let x = Queue.pop queue in
      List.iter (fun (y, _) ->
        if c.(y) = -1 then begin
          c.(y) <- num;
          Queue.push y queue;
        end
      ) graphe.(x);
    done
  in
  let num = ref 0 in
  for i = 0 to n - 1 do
    if c.(i) = -1 then begin
      Queue.push i queue;
      explore !num;
      incr num
    end
  done;
  !num

exception Found of float

let dijkstra a b =
  let n = Array.length graphe in
  let dist = Array.make n infinity in
  dist.(a) <- 0.;
  let nb_explores = ref 0 in
  let queue = ref (ajoute file_vide a 0.) in

  try
    while true do
      let x, _ = recupere_min !queue in
      queue := retire_min !queue;
      incr nb_explores;
      if x = b then raise (Found dist.(b));
      List.iter (fun (y, seg) ->
        let d = dist.(x) +. seg in
        if d < dist.(y) then begin
          dist.(y) <- d;
          queue := ajoute !queue y d
        end
      ) graphe.(x)
    done;
    failwith "noeud non trouvé"
  with
  | Found d -> d, !nb_explores

let h (y1, x1) (y2, x2) =
  let y1' = y1 *. degres_vers_radians in
  let y2' = y2 *. degres_vers_radians in
  let x1' = x1 *. degres_vers_radians in
  let x2' = x2 *. degres_vers_radians in
  diametre_terre *. 1000. *. asin ( sqrt (
    (sin ((y1' -. y2')/. 2.)) ** 2.
    +. (cos y1') *. (cos y2') *. (sin ((x1' -. x2')/. 2.)) ** 2.
  ))

let astar a b =
  let n = Array.length graphe in
  let dist = Array.make n infinity in
  dist.(a) <- 0.;
  let nb_explores = ref 0 in
  let queue = ref (ajoute file_vide a 0.) in

  try
    while true do
      let x, _ = recupere_min !queue in
      queue := retire_min !queue;
      incr nb_explores;
      if x = b then raise (Found dist.(b));
      List.iter (fun (y, seg) ->
        let d = dist.(x) +. seg in
        if d < dist.(y) then begin
          dist.(y) <- d;
          h positions.(y) positions.(b)
          |> print_float;
          print_newline ();
          queue := ajoute !queue y (h positions.(y) positions.(b) +. d)
        end
      ) graphe.(x)
    done;
    failwith "noeud non trouvé"
  with
  | Found d -> d, !nb_explores


let () = 
  let d1, n1 = astar 819913 282392 in
  let d2, n2 = dijkstra 819913 282392 in
  Printf.printf "A* : %.3f (%d noeuds)\n Dijsktra : %.3f (%d noeuds)" d1 n1 d2 n2
