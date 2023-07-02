let u0 = 1
let a = 1103515245
let c = 12345
let m = (1 lsl 15) - 1

let genere_u () =
  let n = 100000 in
  let u = Array.make n u0 in
  for i = 1 to n - 1 do
    u.(i) <- (a * u.(i - 1) + c) land m
  done;
  u

let u = genere_u ()

let x i j sigma = (271 * u.(i) + 293 * u.(j) + 283 * u.(sigma)) mod 10000

let has_transition t n m d i j sigma =
  u.(10 * t + x i j sigma) mod ((n * n * m) / (d * (n - i + 1)) + 1) = 0

let nb_transitions t n m d =
  let nb = ref 0 in
  for i = 0 to n - 1 do
    for j = 0 to n - 1 do
      for sigma = 0 to m - 1 do
        if has_transition t n m d i j sigma then
        incr nb
      done
    done
  done;
  !nb

let accessibles t n m d =
  let seen = Array.make n false in
  let nb = ref 0 in
  let rec explore i =
    if not seen.(i) then begin
      seen.(i) <- true;
      incr nb;
      for j = 0 to n - 1 do
        for sigma = 0 to m - 1 do
          if has_transition t n m d i j sigma then explore j
        done
      done
    end in

  explore 0; (* le seul état initial *)
  !nb

type afd = {
  delta : int array array;
  initial : int;
  finaux : bool array;
  nb_etats : int
}

type afnd = {
  delta : int list array array;
  initiaux : bool array;
  finaux : bool array;
  nb_etats : int
}

let m = 10

let build_term a b =
  let finaux = Array.make (a.nb_etats * b.nb_etats) false in
  for i = 0 to a.nb_etats - 1 do
    for j = 0 to b.nb_etats - 1 do
      finaux.(i + j * a.nb_etats) <- a.finaux.(i) && b.finaux.(j)
    done
  done;
  finaux

let build_delta a b =
  let delta = Array.init (a.nb_etats * b.nb_etats) (fun _ -> Array.make m (-1)) in
  for i = 0 to a.nb_etats - 1 do
    for j = 0 to b.nb_etats - 1 do
      for sigma = 0 to m - 1 do
        let q = a.delta.(i).(sigma) in
        let q' = b.delta.(j).(sigma) in
        delta.(i + a.nb_etats * j).(sigma) <-
          if q = -1 || q' = -1 then (-1)
          else q + a.nb_etats * q'
      done
    done
  done;
  delta

let build_term_nd-

let produit a b =
  {
    delta = build_delta a b;
    initial = a.initial + a.nb_etats * b.initial;
    finaux = build_term a b;
    nb_etats = a.nb_etats * b.nb_etats
  }

(* automate à un seul état, reconnaissant sigma* *)
let automate_universel () = {
  delta = [| Array.make m 0 |];
  initial = 0;
  finaux = [| true |];
  nb_etats = 1
}

let automate_numeros = {
  delta = [|
    [| 0; -1; 0; 0; 0; 0; 0; 0; 0; 0 |];
    [| |];
    [| |];
    [| |];
    [| |];
    [| |];
    [| |];
    [| |];
    [| |];
    [| |];
  |];
  initial = 0;
  finaux = [| false; false; true; false; false; false|];
  nb_etats = 6
}

let produit_multiple =
  let rec aux acc = function
  | [] -> acc
  | x :: xs -> aux (produit acc x) xs
in aux (automate_universel ())



let q4
