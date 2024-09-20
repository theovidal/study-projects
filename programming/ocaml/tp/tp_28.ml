type 'a rn =
  | V
  | N of 'a rn * 'a * 'a rn
  | R of 'a rn * 'a * 'a rn

(* cons arbre g x d renvoie un nœud :
 * - de la même couleur que la racine de arbre ;
 * - ayant g comme fils gauche, x comme clé et d comme fils droit.contents
 *
 * Noter que la seule chose que l'on utilise dans arbre, c'est la
 * couleur de la racine.
 *
 * Cette fonction ne doit pas être appelée avec arbre = V.
 *
 * Utilisée à bon escient, elle permet d'alléger considérablement
 * le code de insere_aux, supprime_min et supprime_aux en
 * uniformisant le traitement des cas R (g, x, d) et N (g, x, d)
 * (quand ces cas se traitent identiquement). *)
let cons arbre g x d =
  match arbre with
  | N _ -> N (g, x, d)
  | R _ -> R (g, x, d)
  | V -> failwith "erreur cons"

(* Je fournis la fonction appartient. Notez le regroupement des
 * cas R _ et N _ : on n'hésitera pas à le faire (quand c'est
 * possible, bien sûr) pour alléger le code. *)
let rec appartient t x =
  match t with
  | V -> false
  | R (g, y, d) | N (g, y, d) ->
    (x = y) || (x < y && appartient g x) || (x > y && appartient d x)


let corrige_rouge = function
  | N(R(a, x, R(b, y, c)), z, d)
  | N(R(R(a, x, b), y, c), z, d)
  | N(a, x, R(b, y, R(c, z, d)))
  | N(a, x, R(R(b, y, c), z, d))
    -> R(N(a, x, b), y, N(c, z, d))
  | n -> n

let rec insere_aux t x =
  match t with
  | V -> R (V, x, V)
  | N(g, n, d) | R(g, n, d) ->
    if x < n then corrige_rouge (cons t (insere_aux g x) n d)
    else if x > n then corrige_rouge (cons t g n (insere_aux d x))
    else t

let insere t x =
  match insere_aux t x with
  | R (g, n, d) -> N (g, n, d)
  | t -> t

(**********************************)
(* Fonctions utilitaires fournies *)
(**********************************)

(* La fonction la plus utile est teste_insere ! *)

let construit = List.fold_left insere V

let elements t =
  let rec aux arbre acc =
    match arbre with
    | V -> acc
    | N (g, x, d) | R (g, x, d) ->
      let avec_d = aux d acc in
      aux g (x :: avec_d) in
  aux t []

let rec verifie_rouge = function
  | V -> true
  | R (R _, _, _) | R (_, _, R _) -> false
  | N (l, _, r) | R (l, _, r) -> verifie_rouge l && verifie_rouge r

let rec profondeurs_noires = function
  | V -> 0, 0
  | R (g, _, d) ->
    let ming, maxg = profondeurs_noires g in
    let mind, maxd = profondeurs_noires d in
    (min ming mind, max maxg maxd)
  | N (g, _, d) ->
    let ming, maxg = profondeurs_noires g in
    let mind, maxd = profondeurs_noires d in
    (1 + min ming mind, 1 + max maxg maxd)

let verifie_structure t =
  let mini, maxi = profondeurs_noires t in
  mini = maxi && verifie_rouge t

let verifie_ordre t =
  let rec croissant = function
    | x :: y :: xs -> (x < y) && croissant (y :: xs)
    | _ -> true in
  croissant (elements t)

let verifie_rn t =
  verifie_ordre t && verifie_structure t

let teste_insere () =
  for _ = 1 to 100 do
    let u = List.init 100 (fun _ -> Random.int 100) in
    let t = construit u in
    assert (verifie_rn t);
    assert (elements t = List.sort_uniq compare u)
  done;
  Printf.printf "Insere OK\n"


let corrige_noir_gauche arbre a_faire =
  if not a_faire then (arbre, a_faire)
  else match arbre with
  | R (a, x, N (b, y, c)) ->
    corrige_rouge (N (R (a, x, b), y, c)), false
  | N (R (a, x, b), y, c) ->
    N (N (a, x, b), y, c), false
  | N (a, x, N (b, y, c)) ->
    corrige_rouge (N (R (a, x, b), y, c)), true
  | N (a, x, R (N (b, y, c), z, N(d, t, e))) ->
    N (corrige_rouge (N(a, x, R(b, y, c))), z, N(d, t, e)), false
  | _ -> failwith "impossible"


let rec supprime_min arbre =
  match arbre with
  | V -> failwith "vide"
  | R (V, x, d) -> d, false
  | N (V, x, d) -> d, true
  | R (g, x, d) | N (g, x, d) ->
    let g', a_diminue = supprime_min g in
    corrige_noir_gauche (cons arbre g' x d) a_diminue

let corrige_noir_droite arbre a_faire =
  failwith "à faire"

let rec minimum = function
  | V -> failwith "vide"
  | N (V, x, _) | R (V, x, _) -> x
  | N (g, x, _) | R (g, x, _) -> minimum g

let rec supprime_aux t x =
  failwith "à faire"

let supprime t x =
  failwith "à faire"

let teste_supprime () =
  let rand_int () = Random.int 100 in
  let rand () = (Random.int 2 = 0) in
  let t = ref V in
  let h = Hashtbl.create 50 in
  for _ = 0 to 1_000 do
    let x = rand_int () in
    if rand () then
      begin
        t := supprime !t x;
        Hashtbl.remove h x;
      end
    else
      begin
        t := insere !t x;
        Hashtbl.replace h x ();
      end;
    assert (verifie_rn !t);
    let u = elements !t in
    let v = Hashtbl.to_seq_keys h |> List.of_seq in
    assert (u = List.sort compare v)
  done;
  Printf.printf "Supprime OK\n"

