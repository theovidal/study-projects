type t = {
  mat : int array array;
  deg : int array;
  mutable sum : int
}

type partition = {
  parents : int array ;
  ranks : int array
}

type multigraph = {
  edges : t;
  vertices : partition;
  mutable nb_vertices : int
}

let create_partition n = {
  parents = Array.init n (fun i -> i) ;
  ranks = Array.make n 0
}

let rec find_compress part x =
  let i = part.parents.(x) in
  if i = x then x
  else begin
    let root = find_compress part i in
    part.parents.(x) <- root;
		root
	end

let merge p x y =
    let rx, ry = find_compress p x, find_compress p y in
    if p.ranks.(rx) > p.ranks.(ry) then
      p.parents.(ry) <- rx
    else if p.ranks.(rx) < p.ranks.(ry) then
      p.parents.(rx) <- ry
    else
      p.ranks.(rx) <- p.ranks.(rx) + 1;
      p.parents.(ry) <- rx

let select_edge edges =
  let n = Array.length edges.deg in
  Unix.time ()
  |> int_of_float
  |> Random.init;
  let k = Random.int edges.sum in

  let sum = ref 0 in
  let i = ref 0 in
  while !i < n - 1 && !sum < k do
    sum := !sum + edges.deg.(!i);
    incr i
  done;
  let j = ref 0 in
  while !j < n && !sum < k do
    sum := !sum + edges.mat.(!i).(!j);
    incr j
  done;
  (!i, !j)

let contract g i j =
  let n = Array.length g.edges.mat in
  g.edges.deg.(i) <- g.edges.deg.(i) + g.edges.deg.(j) - 2 * g.edges.mat.(i).(j);
  g.edges.sum <- g.edges.sum - 2 * g.edges.mat.(i).(j);
  g.edges.deg.(j) <- 0;
  for k = 0 to n - 1 do
    g.edges.mat.(i).(k) <- g.edges.mat.(i).(k) + g.edges.mat.(j).(k);
    g.edges.mat.(k).(j) <- 0;

    g.edges.mat.(k).(i) <- g.edges.mat.(k).(i) + g.edges.mat.(k).(j);
    g.edges.mat.(k).(j) <- 0
  done;
  merge g.vertices i j;
  g.nb_vertices <- g.nb_vertices - 1


let create_multigraph mat =
  let n = Array.length mat in
  let deg = Array.make n 0 in
  let sum = ref 0 in
  for i = 0 to n - 1 do
    for j = 0 to n - 1 do
      deg.(i) <- deg.(i) + mat.(i).(j);
      sum := !sum + mat.(i).(j)
    done;
  done;
  let part = create_partition n in
  let edges = {
    mat = mat;
    deg = deg;
    sum = !sum
  } in
  {
    edges = edges;
    vertices = part;
    nb_vertices = n
  }


let karger mat =
  let multig = create_multigraph mat in
  while multig.nb_vertices > 2 do
    let i, j = select_edge multig.edges in
    contract multig i j
  done;
  let nb_vertex = ref 0 in
  for i = 0 to Array.length mat - 1 do
    nb_vertex := !nb_vertex + multig.edges.deg.(i)
  done;
  multig.vertices, !nb_vertex

let example = [|
  [| 0; 1; 1; 2; 0 |];
  [| 1; 0; 1; 1; 0 |];
  [| 1; 1; 0; 1; 1 |];
  [| 2; 1; 1; 0; 4 |];
  [| 0; 0; 1; 4; 0 |]
|]

let () =
  Printexc.record_backtrace true;
  let _, nb = karger example in
  Printf.printf "Taille de la coupe %d\n" nb

