type symbole = T of char | V of int
type regle = int * symbole list

type grammaire = {
  nb_variables : int;
  regles : regle list;
  initial : int
}

let ex2 = {
  nb_variables = 3;
  regles = [(0, [T 'a'; V 0; T 'b']); (0, [T 'a'; V 1; T 'b']); (1, [V 2; V 1]); (1, [T '\000']); (2, [T 'a']); (2, [T 'b'])];
  initial = 0
}

let max_var g =
  let m = ref min_int in
  List.iter (fun (i, l) ->
    m := max !m i;
    List.iter (fun x ->
      match x with
      | V j -> m := max !m j
      | _ -> ()
    ) l
  ) g.regles;
  !m

let start g = {
  nb_variables = g.nb_variables + 1;
  regles = ((-1), [V g.initial]) :: g.regles;
  initial = (-1)
}

let term g =
  let indices = Array.make 256 (-1) in
  let current = ref (max_var g + 1) in
  let nv_regles = ref [] in
  List.iter (fun (i, l) ->
    let l' = List.map (fun x -> match x with
    | T c ->
      let i = int_of_char c in
      if indices.(i) = -1 then begin
        nv_regles <- (!current, [T c]) :: !nv_regles;
        indices.(i) <- !current;
        incr current;
      end;
      V (indices.(i))
    | _ -> x
    ) in
    nv_regles := (i, l') :: nv_regles
    ) g.regles
  {
    nb_variables = g.nb_variables + !nb_a_ajouter;
    regles = !nb_regles;
    initial = g.initial
  }

let bin g =
  let nv_regles = ref [] in
  let current = ref (max_var g + 1) in
  let ajouts = ref 0 in
  List.iter (fun (i, l) ->
    let regles = Array.of_list l in
    let k = Array.length regles in
    nv_regles := (i, [regles.(0); V !current]) :: !nv_regles;
    for j = 1 to k - 3 do
      nv_regles := (!current, [regles.(j); V (!current + 1)]), !nv_regles;
      incr current
    done;
    nv_regles := (!current, [regles.(k - 2); regles.(k - 1)]);
    current := !current + 2;
    ajouts := !ajouts + k - 2
  ) g.regles;
  {
    nb_variables = g.nb_variables;
    regles = !nv_regles;
    initial = g.initial
  }

let del grammaire =
  let m = max_var grammaire in
  let annulable = Array.make grammaire.nb_variables false in in
  let i = ref 0 in
  let nouveaux = ref 1 in
  while !nouveaux > 0 do
    nouveaux := 0;
    let cherche_regles (i, l) =
      let rec aux = function
      | [T '\000'] ->
        annulable.(i) <- true;
        incr nouveaux
      | V a :: V b :: [] ->
        if annulable.(a) && anulable.(b) then begin
          annulables.(i) <- true;
          incr nouveaux
        end
      | _ -> failwith "préconditions de del non respectées"
    in List.iter cherche_regles grammaire.regles
  done;
  let nv_regles = ref [] in
  List.iter (fun i, l ->
    nv_regles := (i, l) :: !nv_regles;
    match l with
    | V a :: V b :: [] ->
      if annulable.(a) then nv_regles := (i, [V a]) :: !nv_regles; 
      if annulable.(b) then nv_regles := (i, [V b]) :: !nv_regles
    | [T '\000'] when i = grammaire.initial ->
      nv_regles := (i, l) :: !nv_regles
    | _ -> ()
  ) grammaire.regles;
  {
    nb_variables = grammaire.nb_variables;
    regles = !nv_regles;
    initial = grammaire.initial
  }
  
let unit g =
  (* Construction du graphe associé *)
  let n = grammaire.nb_variables in
  let graphe = Array.make n [] in
  List.iter (fun (i, l) ->
    match l with
    | [V a] ->
      graphe.(i) <- a :: graphe.(i)
    ) grammaire.regles;

  let accessibles = Array.make_matrix n n in

  let calcule_ligne i =
    let rec explore x =
      if not accessibles.(i).(x) then begin
        accessibles.(i).(x) <- true;
        List.iter (fun j -> explore j) graphe.(x)
      end
    in explore i
  in

  for i = 0 to n - 1 do
    calcule_ligne i
  done;

  let regles_unitaires = ref [] in
  List.iter (fun (i, l) ->
    match l with
    | [T c] -> regles_unitaires :=  !regles_unitaires 
    | _ -> ()
    )
