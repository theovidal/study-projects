let () =
  if Array.length Sys.argv > 2 then begin
    print_string "❌ Il faut passer en argument le fichier d'entrée et celui de sortie";
    exit (-1)
  end;
  let file_in = Sys.argv.(1) in
  let file_out = Sys.argv.(2) in
  let cnf = open_in file_in in
  let sudoku = open_out file_out in

  let _ = input_line cnf in (* Sauter la ligne "SAT" *)
  let line = input_line cnf in
  let vars_l = String.split_on_char ' ' line in
  let vars_s = Array.of_list vars_l in
  let vars = Array.map (fun i -> int_of_string i) vars_s in

  (* On fait varier c de 0 à 8, et non de 1 à 9, pour bien commencer à la case 0 du tableau *)
  for i = 0 to 8 do
    for j = 0 to 8 do
      for c = 0 to 8 do
        if vars.(i*81 + j*9 + c) > 0 then Printf.fprintf sudoku "%d " (c + 1) (* donc ici faut redécaler pour avoir les bons numéros du sudoku *)
      done;
    done;
    Printf.fprintf sudoku "\n"
  done;
  close_in cnf;
  close_out sudoku;

  print_string "✅ Grille générée."
