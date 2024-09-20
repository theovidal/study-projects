let lire_dimacs ic =
  let rec get_next () =
    let s = input_line ic in
    if s.[0] = 'c' then get_next ()
    else s in
  let n, _ = Scanf.sscanf (get_next ()) "p edge %d %d" (fun n p -> (n, p)) in
  let g = Array.make n [] in
  try
    while true do
      let i, j =
        Scanf.sscanf
          (get_next ())
          "e %d %d"
          (fun i j -> (i - 1, j - 1)) in
      if not (List.mem j g.(i)) then g.(i) <- j :: g.(i);
      if not (List.mem i g.(j)) then g.(j) <- i :: g.(j)
    done;
    assert false
  with
  | End_of_file -> g

let petersen =
  [|
    [4; 5; 6];
    [6; 7; 8];
    [5; 8; 9];
    [4; 7; 9];
    [0; 3; 8];
    [0; 2; 7];
    [0; 1; 9];
    [1; 3; 5];
    [1; 2; 4];
    [2; 3; 6]
  |]

let nb_edges g =
  Array.fold_left (fun acc u -> acc + List.length u) 0 g / 2

let cnf_of_graphe g k =
  let n = Array.length g in
  let var i j = i * k + j + 1 in
  let cnf = ref [] in
  let ajoute_contraintes i =
    let colorie = List.init k (fun c -> var i c) in
    cnf := colorie :: !cnf;
    let ajoute_aretes c =
      List.iter (fun j -> cnf := [- var i c; - var j c] :: !cnf) g.(i) in
    for c = 0 to k - 1 do
      ajoute_aretes c
    done in
  for i = 0 to n - 1 do
    ajoute_contraintes i
  done;
  let rec debut i =
    if i < n then
      match g.(i) with
      | [] -> cnf := [var i 0] :: !cnf; debut (i + 1);
      | j :: _ -> cnf := [var i 0] :: [var j 1] :: !cnf in
  debut 0;
  !cnf

let write_cnf g k oc =
  let n = Array.length g in
  let p = nb_edges g in
  let cnf = cnf_of_graphe g k in
  Printf.fprintf oc "c %d vertices %d edges\n" n p;
  let nb_variables = n * k in
  Printf.fprintf oc "p cnf %d %d\n" nb_variables (List.length cnf);
  let write_clause c =
    List.iter (Printf.fprintf oc "%d ") c;
    Printf.fprintf oc "0\n" in
  List.iter write_clause cnf

let main () =
  let argc = Array.length Sys.argv in
  let k = int_of_string Sys.argv.(1) in
  let ic = if argc > 2 then open_in Sys.argv.(2) else stdin in
  let oc = if argc > 3 then open_out Sys.argv.(3) else stdout in
  let g = lire_dimacs ic in
  write_cnf g k oc;
  close_out oc;
  close_in ic

let () = main ()
