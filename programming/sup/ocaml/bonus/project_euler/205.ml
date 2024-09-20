let proba t =
  let sum = Array.fold_left (fun acc i -> i +. acc) 0. t in
  Array.map (fun i -> i /. sum) t

(* To simplify, array indices start from 1 to correspond exactly to the value of the throw *)
let tirages nb value =
  let t = Array.make (nb * value + 1) 0. in
  let rec aux tirage i =
    if i = nb then begin
      let sum = List.fold_left (fun acc i -> acc + i) 0 tirage in
      t.(sum) <- t.(sum) +. 1.
    end
    else
      for k = 1 to value do
        aux (k :: tirage) (i + 1)
      done
  in aux [] 0;
  proba t


let problem_205 () =
  let p = ref 0. in
  let proba_py = tirages 9 4 in
  let proba_cub = tirages 6 6 in
  for i = 1 to 30 do
    (* Unvariant : j - x = i to correspond to the wanted difference value *)
    let j = ref (i + 6) in
    let x = ref 6 in
    while !j <= 36 do
      p := !p +. proba_py.(!j) *. proba_cub.(!x);
      incr j; incr x
    done;
  done;
  !p
