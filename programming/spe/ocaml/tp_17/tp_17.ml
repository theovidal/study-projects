type instance = int * int list

type box = {
  mutable volume : int;
  mutable content : int list;
}

let empty_box () = {
  volume = 0;
  content = []
}

let add_to_box b x =
  b.volume <- b.volume + x;
  b.content <- x :: b.content

let pop_from_box b =
  assert (b.volume > 0);
  let x = List.hd b.content in
  b.content <- List.tl b.content;
  b.volume <- b.volume - x

let reset_box b =
  b.volume <- 0;
  b.content <- []

let copy_box b = {
  volume = b.volume;
  content = b.content
}

let next_fit (c, a) =
  let box = empty_box () in
  let boxes = ref [] in
  List.iter (fun x ->
    if box.volume + x > c then (
      boxes := copy_box box :: !boxes;
      reset_box box
    );
    add_to_box box x
  ) a;
  box :: !boxes

let first_fit (c, a) =
  let rec aux inst boxes =
    match inst with
    | [] -> boxes
    | x :: xs ->
      let rec fit = function
      | [] ->
        let b = empty_box () in
        add_to_box b x;
        [empty_box (); b]
      | b :: bs when b.volume + x > c -> b :: (fit bs)
      | b :: bs -> add_to_box b x; b :: bs
    in
    aux xs (fit boxes)
  in aux a []

let first_fit_better (c, a) =
  List.fold_left (fun boxes x ->
    let rec fit = function
    | [] ->
      let b = empty_box () in
      add_to_box b x;
      [b]
      | b :: bs when b.volume + x > c ->
        b :: (fit bs)
      | b :: bs -> add_to_box b x; b :: bs
    in fit boxes
    ) [] a
  

let rec eclate = function
  | [] -> [], []
  | x :: [] -> [x], []
  | x :: y :: xs ->
		let xe, ye = eclate xs in
		x :: xe, y :: ye

let rec fusionne u v =
	match u, v with
  | l, [] | [], l -> l
  | x :: xs, y :: ys when x < y -> x :: fusionne xs (y :: ys)
  | x :: xs, y :: ys -> y :: fusionne (x :: xs) ys

let rec tri_fusion u =
  match u with
  | [] | [_] -> u
  | l ->
		let lx, ly = eclate l in
		fusionne (tri_fusion lx) (tri_fusion ly)

let first_fit_decreasing (c, a) =
  first_fit_better (c, (List.rev (tri_fusion a)))

let test_exact =
  (101,
    [27; 11; 41; 43; 42; 54; 34; 11; 2; 1; 17; 56;
    42; 24; 31; 17; 18; 19; 24; 35; 13; 17; 25])

let solve (c, a) =
  let opt_boxes = ref (first_fit_decreasing (c, a) |> Array.of_list) in
  let opt = ref (Array.length !opt_boxes) in

  let m = ref 0 in
  let boxes = Array.make !opt (empty_box ()) in
  let rec explore = function
  | [] ->
    print_string "yes";
    opt_boxes := Array.copy boxes;
    opt := !m
  | x :: xs ->
    for i = 0 to !m - 1 do
      if boxes.(i).volume + x <= c then
        let b = boxes.(i) in
        add_to_box boxes.(i) x;
        explore xs;
        boxes.(i) <- b
    done;
    if !m < !opt - 1 then begin
      incr m;
      add_to_box boxes.(!m) x;
      explore xs;
      boxes.(!m) <- empty_box ();
      decr m
    end

  in List.sort (fun x y -> y - x) a |> explore;
  Array.sub !opt_boxes 0 !opt
  |> Array.to_list


