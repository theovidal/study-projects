type regle_unitaire = int * char
type regle_binaire = int * int * int

type cnf = {
  initial : int;
  nb_variables : int;
  unitaires : regle_unitaire list;
  binaires : regle_binaire list;
  mot_vide : bool
}

let exemple = {
  initial = 0;
  nb_variables = 5;
  unitaires = [(0, 'b'); (1, 'a'); (2, 'b'); (4, 'a')];
  binaires = [(0, 1, 2); (0, 2, 1); (0, 3, 1); (1, 1, 4); (3, 1, 2)];
  mot_vide = false
}

let cyk_analyse grammaire word =
  let arbre = ref [] in
  (*if word = "" then grammaire.mot_vide
  else*)
  let n = String.length word in
  let k = grammaire.nb_variables in
  let t = Array.init (n+1) (fun l ->
    Array.init n (fun d ->
      Array.make k (-1))) in
  List.iter (fun (i, c) -> 
    for d = 0 to n - 1 do
      Printf.printf "%d %d\n" i d;
        t.(1).(d).(i) <- if word.[d] = c then 1 else 0
    done
    ) grammaire.unitaires;
  let rec aux l d i =
    Printf.printf "%d %d %d\n" l d i;
    if t.(l).(d).(i) = -1 then begin
      for l' = 1 to l - 1 do
        let rec find = function
        | [] ->
          if t.(l).(d).(i) <> 1 then
            t.(l).(d).(i) <- 0
        | (i', a, b) :: _ when i = i' ->
          (* Pour toute dérivation X_i -> X_a X_b, examiner si l'on peut dériver ainsi pour retrouver le mot*)
          if aux l' d a + aux (l - l') (d + l') b = 2 then
            t.(l).(d).(i) <- 1;
            arbre := (i, a, b) :: !arbre
        | _ :: xs -> find xs
          in find grammaire.binaires
      done;
    end;
    t.(l).(d).(i)
  in
    aux n 0 grammaire.initial = 1, t

let cyk_analyse_bis grammaire word =
  let n = String.length word in
  if n = 0 then grammaire.mot_vide, [] else
  let arbre = ref [] in
  let k = grammaire.nb_variables in
  let t = Array.init n (fun l ->
    Array.init n (fun d ->
      Array.make k false)) in
  List.iter (fun (i, c) -> 
    for d = 0 to n - 1 do
      t.(0).(d).(i) <- word.[d] = c
    done
    ) grammaire.unitaires;
  for l = 2 to n do
    for d = 0 to n - l do
      for l' = 1 to l - 1 do
        List.iter (fun (i, a, b) ->
          if not t.(l).(d).(i) && t.(l').(d).(a) && t.(l - l').(d + l').(b) then begin
            t.(l).(d).(i) <- true;
            arbre := (i, a, b) :: !arbre
          end
        ) grammaire.binaires
      done
    done
  done;
  t.(n).(0).(grammaire.initial), !arbre