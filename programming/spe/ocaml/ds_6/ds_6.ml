type instance = int array * int array * int

let relax (v, w, capacity) k =
  let n = Array.length v in
  let r = ref capacity in
  let value = ref 0. in
  for i = k to n - 1 do
    if !r = 0 then ()
    else if !r < w.(i) then (
      value := float_of_int v.(i) *. ((float_of_int !r)/.(float_of_int w.(i))) +. !value;
      r := 0
    )
    else (
      value := float_of_int v.(i) +. !value;
      r := !r - w.(i)
    )
  done;
  !value

let copy_in src dst =
  assert (Array.length a = Array.length b);
  for i = 0 to Array.length dst - 1 do
    dst.(i) <- src.(i)
  done

let solve (v, w, capacity) =
  let n = Array.length v in
  let opt_sol = Array.make n 0 in
  let opt_v = ref 0 in

  let sol = Array.make n 0 in

  let explore k current_v current_w =
    if current_w > capacity then ()
    else if k = n && current_v > !opt_v then (
      copy_in sol opt_sol;
      opt_v := current_v
    )
    else if k < n && int_of_float relax (v, w, capacity) k + current_v > !opt_sol then (
      sol.(k) <- true;
      explore (k + 1) (current_v + v.(k)) (current_w + w.(k));
      sol.(k) <- false;
      explore (k + 1) current_v current_w
    )

  in explore 0 0 0;
  !opt_sol, !opt_v
