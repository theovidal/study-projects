type future =
  | Undefined
  | One
  | NinetyNine
  
let rec sum_square i =
  if i = 0 then 0
  else (i mod 10) * (i mod 10) + sum_square (i / 10)

let project_89 () =
  let t = Hashtbl.create 10000000 in
  Hashtbl.add t 1 One;
  Hashtbl.add t 89 NinetyNine;
  let count = ref 0 in
  for i = 1 to 10000000 do
    let rec loop seen n =
      try
        let f = Hashtbl.find t n in
        begin
          match f with
          | One | Undefined -> ()
          | NinetyNine -> incr count
        end;
        (* If we came to that line, the future of the number has been calculated,
           so we register the rest that isn't present in the hash table *)
        List.iter (fun x -> Hashtbl.add t x f) seen
      with
      | Not_found -> loop (n :: seen) (sum_square n)
    in loop [] i
  done; 
  !count

(* Expected answer : 8581146 *)
