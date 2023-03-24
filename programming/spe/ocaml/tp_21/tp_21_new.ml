type multigraph = {
  matrix : int array array;
  classes : int array;
  sum_lines : int array;
  sum : int;
  mutable nb_classes : int;
}

let create_multigraph matrix =
  let n = Array.length matrix in
  let classes = Array.init n (fun i -> (-1)) in
  let sum_lines = Array.init n (fun i ->
    Array.fold_left (fun acc c -> c + acc) 0 matrix.(i)
    ) in
  let sum = Array.fold_left (fun acc n -> acc + n) 0 sum_lines in 
  {
    matrix = matrix;
    classes = classes;
    sum_lines = sum_lines;
    sum = sum;
    nb_classes = n
  }

let rec get_class classes i =
  let parent_or_card = classes.(i) in
  if parent_or_card < 0 then (i, parent_or_card)
  else 
    let (ci, ni) = get_class classes parent_or_card in
    classes.(i) <- ci;
    ci, ni

let merge classes i j =
  let (ci, ni) = get_class classes i in
  let (cj, nj) = get_class classes j in
  classes.(cj) <- classes.(ci) + classes.(cj);
  if ni > nj then classes.(cj) <- ci
  else classes.(ci) <- cj

let pickup_value t sum =
  let choice = Random.int sum in
  let rec aux i step =
    if i >= Array.length t - 1 then i
    else if choice < step + t.(i) then i
    else aux (i + 1) (step + t.(i))
  in aux 0 0

let pickup_edge m =
  let line = pickup_value m.sum_lines m.sum in
  line, pickup_value m.matrix.(line) m.sum_lines.(line)

let karger matrix =
  let graph = create_multigraph matrix in
  while graph.nb_classes > 2 do
    let i, j = pickup_edge graph in
    merge graph.classes i j;
    graph.nb_classes <- graph.nb_classes - 1;
  done;
  graph.classes

let read_graph input =
  let read_newline () = Scanf.bscanf input "%c" ignore in
  Scanf.bscanf input "%d" (fun n ->
    let matrix = Array.make_matrix n n 0 in
    for i = 0 to n - 1 do
      read_newline ();
      for j = 0 to n - 1 do
        Scanf.bscanf input " %d" (fun v -> matrix.(i).(j) <- v)
      done
    done;
    matrix
  )

let () =
  Random.self_init ();

  let input = if Array.length Sys.argv > 1 then open_in Sys.argv.(1) else stdin in
  let matrix = read_graph (Scanf.Scanning.from_channel input) in
  let classes = karger matrix in

  let n = Array.length classes in
  let sets = Array.make n [] in
  for i = 0 to n - 1 do
    let (ci, _) = get_class classes i in
    sets.(ci) <- i :: sets.(ci)
  done;
  for i = 0 to n - 1 do
    if sets.(i) <> [] then begin
      print_string "Set: ";
      List.iter (fun i -> Printf.printf "%d " i) sets.(i);
      print_newline ()
    end
  done;

  if Array.length Sys.argv > 1 then close_in input
