let () =
  if Array.length Sys.argv < 3 then print_string "Il faut passer deux noms de fichier"
  else
    let n1 = open_in Sys.argv.(1) in
    let n2 = open_out Sys.argv.(2) in

    try
      while true do
        let next = input_line n1 in
        Printf.fprintf n2 "%s\n" next
      done
    with
    | End_of_file -> print_string "Copie terminée."
