type ('key, 'prio) t = {
  priorities : 'prio Vector.t;
  keys : 'key Vector.t;
  mapping : ('key, int) Hashtbl.t
}

let length q = Vector.length q.priorities

let create () =
  {priorities = Vector.create ();
   keys = Vector.create ();
   mapping = Hashtbl.create 10}

let mem q x =
  Hashtbl.mem q.mapping x

let swap t i j =
  let tmp = Vector.get t i in
  Vector.set t i (Vector.get t j);
  Vector.set t j tmp

let full_swap q i j =
  swap q.keys i j;
  swap q.priorities i j;
  Hashtbl.replace q.mapping (Vector.get q.keys i) i;
  Hashtbl.replace q.mapping (Vector.get q.keys j) j

let get_min q =
  if length q = 0 then None
  else Some (Vector.get q.keys 0, Vector.get q.priorities 0)

let left i = 2 * i + 1

let right i = 2 * i + 2

let parent i = (i - 1) / 2

let rec sift_up q i =
  let j = parent i in
  if i > 0 && Vector.get q.priorities i < Vector.get q.priorities j then
    begin
      full_swap q i j;
      sift_up q j
    end

let insert q (x, prio) =
  Vector.push q.keys x;
  Vector.push q.priorities prio;
  Hashtbl.add q.mapping x (length q - 1);
  sift_up q (length q - 1)

let rec sift_down q i =
  let prio j = Vector.get q.priorities j in
  let smallest = ref i in
  if left i < length q && prio (left i) < prio i then
    smallest := left i;
  if right i < length q && prio (right i) < prio !smallest then
    smallest := right i;
  if !smallest <> i then
    begin
      full_swap q i !smallest;
      sift_down q !smallest
    end

let extract_min q =
  if length q = 0 then
    None
  else
    begin
      let key = Vector.get q.keys 0 in
      let prio = Vector.get q.priorities 0 in
      full_swap q 0 (length q - 1);
      Hashtbl.remove q.mapping key;
      ignore (Vector.pop q.priorities);
      ignore (Vector.pop q.keys);
      sift_down q 0;
      Some (key, prio)
    end

let decrease_priority q (x, prio) =
  let i = Hashtbl.find q.mapping x in
  assert (prio <= Vector.get q.priorities i);
  Vector.set q.priorities i prio;
  sift_up q i

let insert_or_decrease q (x, prio) =
  if mem q x then decrease_priority q (x, prio)
  else insert q (x, prio)
