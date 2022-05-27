let n = 3
let n2 = 9
let n4 = 81


let adj x y =
  let i, j = x / n2, x mod n2 in
  let i', j' = y / n2, y mod n2 in
  i = i' || j = j' || (i / n = i' / n && j / n = j' / n)

let vierge =
  let g = Array.make n4 [] in
  for x = 0 to n4 - 1 do
    for y = x + 1 to n4 - 1 do
      if adj x y then begin
        g.(x) <- y :: g.(x);
        g.(y) <- x :: g.(y)
      end
    done
  done;
  g

let lire_grille ic =
  let m = Array.make n4 (-1) in
  for i = 0 to n2 - 1 do
    let s = input_line ic in
    for j = 0 to n2 - 1 do
      m.(i * n2 + j) <- int_of_char s.[j] - int_of_char '0' - 1
    done
  done;
  m



let pos x c = x * n2 + c + 1
let neg x c = - pos x c

let cnf_vierge =
  let contraintes x =
    let remplie = List.init n2 (fun c -> pos x c) in
    let different c = List.map (fun y -> [neg x c; neg y c]) vierge.(x) in
    remplie :: List.concat (List.init n2 different ) in
  List.concat (List.init n4 contraintes)

let cnf_of_grille grille =
  let cnf = ref cnf_vierge in
  for x = 0 to n4 - 1 do
    if grille.(x) >= 0 then cnf := [pos x grille.(x)] :: !cnf
  done;
  !cnf

let write_cnf cnf oc =
  Printf.fprintf oc "p cnf %d %d\n" (n4 * n2) (List.length cnf);
  let write_clause c =
    List.iter (Printf.fprintf oc "%d ") c;
    Printf.fprintf oc "0\n" in
  List.iter write_clause cnf

let convertir_fichier f =
  let ic = open_in f in
  try
    while true do
      let s = input_line ic in
      let i = Scanf.sscanf s "Grid %d" (fun x -> x) in
      let grille = lire_grille ic in
      let cnf = cnf_of_grille grille in
      let output_path = Printf.sprintf "grilles/grille_%d.cnf" i in
      let oc = open_out output_path in
      write_cnf cnf oc;
      close_out oc
    done
  with
  | End_of_file -> ()
