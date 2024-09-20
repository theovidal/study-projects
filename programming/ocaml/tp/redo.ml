let liste_n_reines n =
  let rec aux candidat =
    if conflit_derniere candidat then []
    else if Array.length candidat = n then [candidat]
    else
      let s = ref [] in
      let rec loop i =
        if i = n then [] else
        let c = etend candidat i in
        aux c @ loop (i + 1)
      in loop 0
      for i = 0 to n - 1 do
        s := aux (etend candidat i) @ !s
      done;
      !s
  in aux [||]

type 'a response =
  | Refus
  | Accepte of 'a
  | Partiel of 'a

type 'a probleme = {
  accepte : 'a -> 'a response ;
  enfants : 'a -> 'a list ;
  initiale : 'a
}

type n_reines n = {
  accepte = (fun c ->
    if conflit_derniere c then Refus
    else if Array.length c = n then Accepte c
    else Partiel c
  ) ;
  enfants = (fun c -> List.init n (etend c)) ;
  initiale = [||]
}

let enumere_solutions pb =
  let rec construit candidat =
    match pb.accepte candidat with
    | Refus -> []
    | Accepte c -> [c]
    | Partiel c ->
      let rec enfants u =
        match u with
        | [] -> []
        | x :: xs -> construit x @ enfants xs
      in enfants (pb.enfants c)
  in
  construit pb.initiale

exception Trouve of 'a
let cherche_solution pb =
  let rec aux candidat =
    match pb.accepte candidat with
    | Refus -> ()
    | Accepte c -> raise (Trouve c)
    | Partiel c ->
      List.iter (fun x -> aux x) (pb.enfants c)
  in try
    aux pb.initiale ;
    None
  with
  | Trouve c -> Some c

type graphe = {nb_sommets : int; voisins : int -> int list}


let hamiltonien_depuis g x0 =
  let ordre = Array.make (g.nb_sommets) (-1) in

  let rec explore x i =
    if ordre.(x) != -1 then begin
      ordre.(x) = i;
      if i = g.nb_sommets - 1 then raise (Trouve ordre)
      List.iter (fun y -> explore y (i + 1)) (g.voisins x);
      ordre.(x) = -1
    end

  in try
    explore x0 0;
    None
  with
  | Trouve o -> Some o

let arbre_bfs g x0 =
  let n = Array.length g in
  let tree = Array.make n (-1) in
  tree.(x0) <- x0;

  let opened = Queue.create () in
  Queue.push x0 opened;

  while not (Queue.is_empty opened) do
    let x = Queue.pop opened in
    List.iter (fun y ->
      if tree.(y) = -1 then begin
        tree.(y) <- x;
        Queue.push y opened
      end
    ) g.(x)
  done

let chemin g x =
  let p = ref [x] in
  let i = ref x in
  while g.(!i) <> i && g.(!i) <> -1 do
    p := g.(!i) :: !p;
    i := g.(!i)
  done;
  match !p with
  | [x] -> None
  | _ -> Some !p
  
let sac_mem p v pmax =
  let n = Array.length v in
  let t = Array.make_matrix n (pmax + 1) (-1) in
  let rec aux k d =
    match k, d with
    | 0, _ -> 0
    | _, d when d < 0 -> max_int
    | _ ->
      if t.(k).(d) = (-1) then begin
        let avec_k = v.(k - 1) + aux (k - 1) (d - p.(k - 1)) in
        let sans_k = aux (k - 1) d in
        t.(k).(d) <- min avec_k sans_k
      end;
      t.(k).(d)
  in aux n pmax

let sac_dyn p v pmax =
  let n = Array.length v in
  let t = Array.make_matrix n (pmax + 1) (-1) in
  for d = 0 to n - 1 do
    t.(0).(d) <- 0
  done;
  let score k d = if d < 0 then max_int else t.(k).(d) in
  for k = 1 to n - 1 do
    for d = 0 to pmax - 1 do
      let avec_k = v.(k - 1) + score (k - 1) (d - p.(k - 1)) in
      let sans_k = score (k - 1) d in
      t.(k).(d) <- min avec_k sans_k
    done;
  done;
  t.(n).(pmax)

type formule =
  | C of bool
  | V of int
  | Et of formule * formule
  | Ou of formule * formule
  | Imp of formule * formule
  | Non of formule
  
type valuation = bool array
  

type graphe = int list array

let range k = List.init k (fun i -> i)

let rec binarise_et u =
  match u with
  | [] -> C true
  | x :: xs -> Et x (binarise_ou xs)
let rec binarise_ou u =
  match u with
  | [] -> C false
  | x :: xs -> Ou x (binarise_ou xs)

let encode g k =
  let n = Array.length g in
  let var i c = V (n * i + c) in
  let est_colorie i = binarise_ou (List.init k (fun c -> var i c)) in

  let contraintes i =
    let contraintes_couleurs c =
      let autres_couleurs = List.filter (fun x -> x <> c) (range k) in
      let voisins = List.map (fun x -> var x c) g.(i) in
      let unique = List.map (fun c' -> var i c' ) autres_couleurs in
      Imp (var i c, Non (binarise_ou (voisins @ unique)))
    in Et (est_colorie i, binarise_et (List.init k contraintes_couleurs))
  in
  binarise_et (List.init n (fun i -> contraites i))
