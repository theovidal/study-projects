open Printf

let get_lines file =
  let n = ref 0 in
  try
    (* autre manière : while true do ... *)
    let rec loop () =
      let _ = input_line file in
      incr n;
      loop () in
    loop ()
  with
  | End_of_file -> close_in file;
  !n

let _ =
  try
    let n = Array.length Sys.argv in
    let total = ref 0 in
    for i = 1 to n - 1 do
      let filename = Sys.argv.(i) in
      let file = open_in filename in
      let lines = get_lines file in
      total := !total + lines;
      printf "%d %s\n" lines filename
    done;
    printf "%d total\n" !total
  with
  | Sys_error _ -> print_string "Erreur > un des noms de fichier est incorrect"
