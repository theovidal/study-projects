type partition = {
  parents : int array ;
  ranks : int array
}

let create_partition n = {
  parents = Array.init n (fun i -> i) ;
  height = Array.create n 0
}

let rec find part x =
  let i = part.parents[x] in
  if i = x then x
  else find part i

(* En utilisant cette fonction, les "hauteurs" ne sont pas *)
(* modifiées et donc elles ne deviennent que des majorants *)
(* -> Union par rang : le rang est supérieur à la hauteur *)
let rec find_compress part x =
  let i = part.parents[x] in
  if i = x then x
  else
    let root = find_compress part i in
    part.parents[x] <- root

let merge part x y =
    let rx, ry = find part x, find part y in
    if ranks[rx] > ranks[ry] then
      parents[ry] <- rx
    else if ranks[rx] < ranks[ry]
      parents[rx] <- ry
    else
      ranks[rx] <- ranks[rx] + 1;
      parents[ry] <- rx
