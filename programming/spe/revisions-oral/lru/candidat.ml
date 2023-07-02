type maillon = {
    mutable donnee : int;
    mutable prec : maillon option;
    mutable suiv : maillon option;
  }

type liste_chainee = {
    mutable debut : maillon option;
    mutable fin : maillon option
  }

let liste_vide () = {
  debut = None;
  fin = None;
}

let ajoute_debut liste i =
  match liste.debut with
  | None ->
    let nouveau = {
      donnee = i;
      prec = None;
      suiv = None
    } in
    liste.debut <- Some nouveau;
    liste.fin <- Some nouveau

  | Some d ->
    let nouveau = {
      donnee = i;
      prec = None;
      suiv = Some d
    } in
    d.prec <- Some nouveau;
    liste.debut <- Some nouveau

let suppression_maillon liste maillon =
  let rec explore u =
    match u with
    | None -> ()
    | Some d when d.donnee = maillon.donnee -> begin
        match d.prec with
        | None -> ()
        | Some prec -> prec.suiv <- d.suiv 
        end;
      begin
        match d.suiv with
        | None -> ()
        | Some suiv -> suiv.prec <- d.prec
      end;
      (* si le précédent est None, on est en train de supprimer le début de la liste *)
      if d.prec = None then liste.debut <- d.suiv;
      (* pareil pour le suivant *)
      if d.suiv = None then liste.fin <- d.prec;
    | Some d -> explore d.suiv
  in explore liste.debut

let teste_chainee () =
  let liste = liste_vide () in
  for i = 0 to 6 do
    ajoute_debut liste i
  done;

  for i = 0 to 6 do
    match liste.fin with
    | None -> failwith "impossible"
    | Some d ->
      assert (d.donnee = i);
      suppression_maillon liste d;
  done;
  assert (liste.debut = None && liste.fin = None)

type lru = {
    liste : liste_chainee;
    hachage : (int, string * maillon option) Hashtbl.t;
    mmu : int -> string;
    mutable longueur : int;
    capacite : int;
  }

let chiffre = function
  | 0 -> "zero"
  | 1 -> "un"
  | 2 -> "deux"
  | 3 -> "trois"
  | 4 -> "quatre"
  | 5 -> "cinq"
  | 6 -> "six"
  | 7 -> "sept"
  | 8 -> "huit"
  | 9 -> "neuf"
  | _ -> failwith "pas un chiffre"

let initialiser_lru capacite mmu = {
  liste = liste_vide ();
  hachage = Hashtbl.create capacite;
  mmu = mmu;
  longueur = 0;
  capacite = capacite
}

let charger lru k =
  match Hashtbl.find_opt lru.hachage k with
  | Some (valeur, maillon) ->
    suppression_maillon lru.liste (Option.get maillon);
    ajoute_debut lru.liste k;
    valeur
  | None -> 
    if lru.longueur = lru.capacite then begin
      let ancien = Option.get lru.liste.fin in
      suppression_maillon lru.liste ancien;
      Hashtbl.remove lru.hachage ancien.donnee;
      lru.longueur <- lru.longueur - 1
    end;
    ajoute_debut lru.liste k;
    let valeur = lru.mmu k in
    Hashtbl.add lru.hachage k (valeur, lru.liste.debut);
    lru.longueur <- lru.longueur + 1;
    valeur

let teste_lru () =
  let lru = initialiser_lru 3 chiffre in
  assert (charger lru 7 = "sept");
  assert (charger lru 4 = "quatre");
  assert (charger lru 9 = "neuf");
  assert (charger lru 4 = "quatre");
  assert (charger lru 2 = "deux");
  assert ((Option.get lru.liste.fin).donnee = 9);
  assert ((Option.get lru.liste.debut).donnee = 2)

let () =
  teste_lru ()
