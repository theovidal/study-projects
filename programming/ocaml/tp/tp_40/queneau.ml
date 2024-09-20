let get_line typ n v =
  let line = Random.int 10 in
  let filename = Printf.sprintf "%c%dv%d.txt" typ n v in
  let file = open_in filename in
    
  let i = ref 0 in
  while !i != line do
    input_line file;
    incr i
  done;
  let res = input_line file in
  close_in file;
  res

let compose_poeme () =
  let poeme = ref "" in
  Random.self_init ();
  for q = 1 to 2 do
    for v = 1 to 4 do
      poeme := String.concat "" [!poeme; get_line 'q' q v; "\n"]
    done;
    poeme := !poeme ^ "\n"
  done;

  for t = 1 to 2 do
    for v = 1 to 3 do
      poeme := String.concat "" [!poeme; get_line 't' t v; "\n"]
    done;
    poeme := !poeme ^ "\n"
  done;
  !poeme

let sauvegarde_poemes () =
  for i = 0 to 99 do
    let filename = Printf.sprintf "poeme%d.txt" i in
    let file = open_out filename in
    Printf.fprintf file "%s" (compose_poeme ());
    close_out file
  done;
