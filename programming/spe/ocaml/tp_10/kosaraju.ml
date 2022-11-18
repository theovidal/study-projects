type vertex = int

type graph = vertex list array

let transpose g =
  let n = Array.length g in
  let g' = Array.make n [] in
  for i = 0 to n - 1 do
    List.iter (fun j -> g'.(j) <- i :: g'.(j)) g.(i)
  done;
  g'

let post_order g =
  let n = Array.length g in
  let l = ref [] in
  let seen = Array.make n false in

  let rec explore x =
    if not seen.(x) then begin
      seen.(x) <- true;
      List.iter (fun i -> explore i) g.(x) ;
      l := x :: !l
    end in

  for i = 0 to n - 1 do
    explore i
  done;
  !l

let dfs_mark g marked x0 =
  let n = Array.length g in
  let l = ref [] in
  let seen = Array.make n false in

  let rec explore x =
    if not marked.(x) && not seen.(x) then begin
      seen.(x) <- true;
      List.iter (fun i -> explore i) g.(x) ;
      l := x :: !l
    end in

  explore x0;
  !l

let accessible_lists g u =
  let n = Array.length g in
  let marked = Array.make n false in
  let l = ref [] in
  List.iter (fun i ->
    if not marked.(i) then begin
      let acc = dfs_mark g marked i in
      List.iter (fun y -> marked.(y) <- true) acc;
      l := acc :: !l
    end
  ) u;
  !l

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

let kosaraju g =
  let g' = transpose g in
  let l = post_order g in
  accessible_lists g' l

let read_graph () =
  Scanf.scanf "%d %d\n" (fun n p ->
    let g = Array.make n [] in
    for i = 0 to p - 1 do
      Scanf.scanf "%d %d" (fun x y -> g.(x) <- y :: g.(x))
    done;
    g
  )

let () =
    let g = read_graph () in
    let n = ref 0 in
    let max = ref 0 in
    List.iter (fun c ->
      incr n;
      let size = List.length c in
      if size > !max then max := size
      ) (kosaraju g);
    Printf.printf "Nombre: %d ; Taille max : %d" !n !max

