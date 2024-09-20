type ('k, 'v) dict = {
  hash : 'k -> int;
  table : ('k * 'v) list array
}

let get_id l k = l.hash k mod (Array.length l.table)

let rec get_list l x =
  match l with
  | [] -> None
  | (k, v) :: _ when k = x -> Some v
  | _ :: ls -> get_list ls x

let rec set_list l x y =
  match l with
  | [] -> [(x, y)]
  | (k, v) :: ls when k = x -> (k, y) :: ls
  | c :: ls -> c :: (set_list ls x y)

let rec remove_list l x =
  match l with
  | [] -> []
  | (k, _) :: ls when x = k -> ls
  | c :: ls -> c :: (remove_list ls x)

let get l k =
  let i = get_id l k in
  get_list (l.table.(i)) k
let set l k v =
  let id = get_id l k in
  l.table.(id) <- set_list l.table.(id) k v
  
let remove l k =
  let id = get_id l k in
  l.table.(id) <- remove_list l.table.(id) k