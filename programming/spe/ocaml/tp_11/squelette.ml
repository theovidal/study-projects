let n = 4

type state = {
  grid : int array array;
  mutable i : int;
  mutable j : int;
  mutable h : int;
}

let print_state state =
  for i = 0 to n - 1 do
    for j = 0 to n - 1 do
      if i = state.i && j = state.j then print_string "   "
      else Printf.printf "%2d " state.grid.(i).(j)
    done;
    print_newline ()
  done

type direction = U | D | L | R | No_move

let delta = function
  | U -> (-1, 0)
  | D -> (1, 0)
  | L -> (0, -1)
  | R -> (0, 1)
  | No_move -> assert false

let string_of_direction = function
  | U -> "Up"
  | D -> "Down"
  | L -> "Left"
  | R -> "Right"
  | No_move -> "No move"


(* Part 1 *)

(*let possible_moves s =
  let combinations = [(s.i > 0, U); (s.i < n - 1, D); (s.j > 0, L); (s.j < n - 1, R)] in
    let rec aux = function
    | [] -> []
    | (false, _) :: xs -> aux xs
    | (true, d) :: xs -> d :: aux xs
  in aux combinations*)

(* IL n'y a que 4 mouvements possibles : tester manuellement, en fait ça évitera les erreurs *)

let possible_moves state =
  let possible = ref [] in
  if state.i > 0 then possible := U :: !possible;
  if state.i < n - 1 then possible := D :: !possible; if state.j > 0 then possible := L :: !possible;
  if state.j < n - 1 then possible := R :: !possible; !possible

let distance i j value =
  let i_target = value / n in
  let j_target = value mod n in
  abs (i - i_target) + abs (j - j_target)

let compute_h s =
  s.h <- 0;
  for i = 0 to n - 1 do
    for j = 0 to n - 1 do
      if s.i <> i && s.j <> j then
        s.h <- s.h + distance i j s.grid.(i).(j)
    done; 
  done

let delta_h s move =
  let delta_i, delta_j = delta move in
  Printf.printf " (%d, %d) -> " delta_i delta_j;
  let v = s.grid.(s.i + delta_i).(s.j + delta_j) in
  distance s.i s.j v - distance (s.i + delta_i) (s.j + delta_j) v


let apply s move =
  s.h <- s.h + delta_h s move;
  let delta_i, delta_j = delta move in
  s.grid.(s.i).(s.j) <- s.grid.(s.i + delta_i).(s.j + delta_j);
  s.i <- s.i + delta_i;
  s.j <- s.j + delta_j

let copy state =
  let arr = Array.init n (fun i -> Array.copy state.grid.(i)) in
  {
    grid = arr;
    i = state.i;
    j = state.j;
    h = state.h
  }


(* A few examples *)

(* the goal state *)
let final =
  let m = Array.make_matrix n n 0 in
  for i = 0 to n - 1 do
    for j = 0 to n - 1 do
      m.(i).(j) <- i * n + j
    done
  done;
  {grid = m; i = n - 1; j = n - 1; h = 0}

(* Generates a state by making nb_moves random moves from *)
(* the final state. Returns a state s such that *)
(*  d(initial, s) <= nb_moves (obviously). *)
let random_state nb_moves =
  let state = copy final in
  for i = 0 to nb_moves - 1 do
    let moves = possible_moves state in
    let n = List.length moves in
    apply state (List.nth moves (Random.int n))
  done;
  state

(* distance 10 *)
let ten =
  let moves = [U; U; L; L; U; R; D; D; L; L] in
  let state = copy final in
  List.iter (apply state) moves;
  state

(* distance 20 *)
let twenty =
  {grid =
    [| [|0; 1; 2; 3|];
      [|12; 4; 5; 6|];
      [|8; 4; 10; 11|];
      [|13; 14; 7; 9|] |];
   i = 1; j = 1; h = 14}

(* distance 30 *)
let thirty =
  {grid =
     [| [|8; 0; 3; 1|];
       [|8; 5; 2; 13|];
       [|6; 4; 11; 7|];
       [|12; 10; 9; 14|] |];
   i = 0; j = 0; h = 22}

(* distance 40 *)
let forty =
  {grid =
     [| [|7; 6; 0; 10|];
       [|1; 12; 11; 3|];
       [|8; 4; 2; 5|];
       [|8; 9; 13; 14|] |];
   i = 2; j = 0; h = 30}

(* distance 50 *)
let fifty =
  let s =
    {grid =
       [| [| 2; 3; 1; 6 |];
          [| 14; 5; 8; 4 |];
          [| 15; 12; 7; 9 |];
          [| 10; 13; 11; 0|] |];
     i = 2;
     j = 3;
     h = 0} in
  compute_h s;
  s

(* distance 64 *)
let sixty_four =
  let s =
    {grid =
       [| [| 15; 14; 11; 7|];
          [| 5; 9; 12; 4|];
          [| 3; 10; 13; 8|];
          [| 2; 6; 0; 1|] |];
     i = 0;
     j = 0;
     h = 0} in
  compute_h s;
  s


(* Part 2 *)


let successors state =
  let p = possible_moves state in
  List.map (fun m ->
    let s = copy state in
    apply s m;
    s
    ) p


let rec reconstruct parents x =
  let i = Hashtbl.find parents x in
  if i = x then [x]
  else i :: reconstruct parents i

exception No_path

exception Path of state list

let astar initial =
  let dist = Hashtbl.create (n * n) in
  Hashtbl.add dist initial 0;
  let parents = Hashtbl.create (n * n) in
  Hashtbl.add parents initial initial;
  let opened = Heap.create () in
  Heap.insert opened (initial, initial.h);
  let rec loop () =
    match Heap.extract_min opened with
    | None -> ()
    | Some (v, _) ->
      print_state v; print_newline ();
      print_int v.h; print_newline ();
      if v.h = 0 then
        raise (Path (v :: reconstruct parents v))
      else begin
        List.iter (fun v' ->
          print_string "list ";
          let d = Hashtbl.find dist v + 1 in
          if not (Hashtbl.mem dist v') || d < Hashtbl.find dist v' then begin
            Hashtbl.add parents v' v;
            Hashtbl.add dist v' d;
            Heap.insert_or_decrease opened (v', d + v'.h);
          end
        ) (successors v);
        loop ()
      end
  in try
    loop ();
    raise No_path
  with
  | Path p -> p


(* Part 3 *)

exception Found of int

let idastar_length initial =
  compute_h initial;
  let m = ref initial.h in
  let minimum = ref max_int in
  let e = ref initial in

  let rec dfs m p =
    let c = p + !e.h in
    if c > m then (
      minimum := min c !minimum;
      false
    )
    else if !e.h = 0 then true
    else begin
      let res = ref false in
      print_string "début";
      List.iter (fun move ->
        let old = !e in
        print_string "apply:";
        apply !e move;
        print_state !e; print_newline ();
        res := !res || dfs m (p + 1);
        e := old
        ) (possible_moves !e);
        print_string "fin";
      !res
    end in
  
  try
    while !m <> max_int do
      minimum := max_int;
      if dfs !m 0 then raise (Found !m);
      m := !minimum;
      e := initial;
    done;
    None
  with
  | Found i -> Some i



let idastar initial =


let print_direction_vector t =
  for i = 0 to Vector.length t - 1 do
    Printf.printf "%s " (string_of_direction (Vector.get t i))
  done;
  print_newline ()

let print_idastar state =
  match idastar state with
  | None -> print_endline "No path"
  | Some t ->
    Printf.printf "Length %d\n" (Vector.length t);
    print_direction_vector t


let main () =
  Printexc.record_backtrace true;
  List.iter (fun s -> print_state s) (astar ten)

let () = main ()
