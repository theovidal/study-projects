type kdnode =
  | Leaf of int * int
  | CutNode of int * int * kdnode * kdnode

type kdtree = {
  points : float float array;
  root : kdnode;
}

let swap arr i j =
  let temp = arr.(i) in
  arr.(i) <- arr.(j);
  arr.(j) <- temp

(* Sur papier, faire le schéma pour montrer qu'on a compris comment ça marche *)
let partition arr lo hi d =
  Random.self_init ();
  let ipiv = Random.int (hi - lo) + lo in
  swap arr lo ipiv;
  let j = ref (lo + 1) in
  for i = lo + 1 to hi - 1 do
    if arr.(i).(d) <= arr.(lo).(d) then begin
      swap arr i !j;
      incr j
    end
  done;
  swap (!j - 1) lo;
  !j - 1
    
let quickselect arr lo hi d k =
  let ipiv = partition arr lo hi d in
  if k = ipiv then ()
  else if k < ipiv then quickselect arr lo (ipiv) d k
  else quickselect arr (ipiv + 1) hi d k

let build arr nmax =
  (* On ne sait pas si l'utilisateur veut garder son tableau en place ou non *)
  let pts = Array.copy arr in
  (* Pas besoin de copie en profondeur (donc copier les tableaux de coordonnées de chaque point) :*)
  (* on ne modifie pas ces coordonnées *)

  assert (Array.length pts > 0);
  let nb_dim = Array.length pts.(0) in
  (* Construire l'arbre d-dimensionnel du tableau pts[lo:hi[ avec composante d à la racine *)
  let rec aux lo hi d =
    if hi - lo < nmax then Leaf (lo, hi)
    else (
      let med = (lo + hi)/2 in
      quickselect lo hi d med in
      let d' = (d + 1) mod nb_dim in
      let left = aux lo med d' in
      let right = aux (med + 1) hi d' in
      CutNode (d', med, left, right)
  ) in 
  {
    points = pts;
    root = aux 0 (Array.length pts) 0
  }

let update queue x d =
  if PrioQ.length queue < PrioQ.capacity queue then PrioQ.insert queue x d
  else if PrioQ.get_max queue > d then (
    let _ = PrioQ.extract_max queue in (* ou : ignore (); *)
    PrioQ.insert queue x d
  )

let distance2 x y =
  let s = ref 0. in
  for dim = 0 to Array.length x - 1 do
    s := !s +. (x.(dim) -. y.(dim)) ** 2.
  done;
  !s

let knn_search tree k x =
  let neighbours = PrioQ.make k in
  let rec aux = function
    | Leaf (lo, hi) -> 
      for i = lo to hi - 1 do
        update neighbours i (distance2 tree.points.(i) x)
      done
    | CutNode (d, i, lt, gt) ->
      let x_cut = tree.points.(i) in
      let before, after =
        if xcut.(d) < x.(d) then gt, lt
        else lt, gt in
      update neighbours i (distance2 xcut x);
      aux before;
      (* On suppose que get_max renvoie infinity si la queue est vide *)
      (* On explore l'autre si la boule de rayon maximal intersecte l'hyperplan de séparation *)
      if (xcut.(d) -. x.(d)) ** 2. < PrioQ.get_max neighbours then
        aux after
  in aux tree.root;
  neighbours
