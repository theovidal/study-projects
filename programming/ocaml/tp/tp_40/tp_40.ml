let stream = open_out "blank.txt" in
Printf.fprintf stream "Première ligne\nDeuxième ligne";
close_out stream;

let file = open_in "blank.txt" in
  try
    while true do
      let next = input_line file in
      print_string next ; print_newline ()
    done
  with
  | End_of_file -> ();;

let squares = open_out "plot.txt" in
for i = 0 to 10000 do
  Printf.fprintf squares "%d %d\n" i (i * i)
done;
close_out squares
