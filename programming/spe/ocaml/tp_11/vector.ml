type 'a t = {
  mutable length : int;
  mutable capacity : int;
  mutable data : 'a array;
}

let create () = {
  length = 0;
  capacity = 0;
  data = [| |]
}

let get v i =
  v.data.(i)

let set v i x =
  v.data.(i) <- x

let pop v =
  let x = v.data.(v.length - 1) in
  v.length <- v.length - 1;
  x

let push v x =
  if v.capacity = 0 then (
    v.data <- [| x |]
  ) else if v.capacity = v.length then (
    let new_capacity = 2 * v.capacity in
    let new_data = Array.make new_capacity x in
    Array.blit v.data 0 new_data 0 v.length;
    v.data <- new_data
  ) else (
    v.data.(v.length) <- x
  );
  v.capacity <- Array.length v.data;
  v.length <- v.length + 1

let length v = v.length
