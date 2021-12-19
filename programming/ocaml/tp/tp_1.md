# TP n°1 - 10/09/2021

## Quelques fonctions élémentaires

### Exercice 1

Question 1 :

```ocaml
let norme a b = sqrt(a ** 2. +. b ** 2)
```

Question 2 :

```ocaml
let moyenne a b = (a +. b) /. 2.
```

Question 3 :

```ocaml
let f a b = float_of_int (a + b) /. 2.
```

### Exercice 2

```ocaml
let abs a = sqrt (a ** 2.)
```

## Fonctions récursives

### Exercice 3

```ocaml
let rec u n = match n with
    | 0 -> 4
    | _ -> 3. *. u (n - 1) +. 2.
```

### Exercice 4

```ocaml
let rec fact n =
    if n = 0 then 1
    else if n < 0 then failwith "n doit être positif"
    else n * fact (n - 1)
```

### Exercice 5

```ocaml
let rec somme_carres n = match n with
    | 1 -> 1
    | _ -> n * n + somme_carres (n - 1)
```

### Exercice 6

Question 1 :

```ocaml
let rec puissance x n =
    if n = 0 then 1.
    else x *. puissance x (n - 1)
```

Question 2 :

```ocaml
(* Pas la forme la plus optimisée : on pourrait directement inverser x et en faire la puissance pour ne pas avoir de récurrence avec n < 0 *)

let rec puissance_bis x n =
    if n = 0 then 1.
    else if n < 0 then puissance x (n + 1) /. x
    else x *. puissance x (n - 1)
```

## Manipulation de listes

### Exercice 7

Question 1 :

```ocaml
let rec somme_liste l = match l with
    | [] -> 0.
    | head :: tail -> head +. somme_liste tail
```

Question 2 :

```ocaml
let rec longueur l = match l with
    | [] -> 0
    | head :: tail -> 1 + longueur tail
```

Question 3 :

```ocaml
let moyenne_liste = somme_liste l /. float_of_int (longueur l)
```

### Exercice 8

```ocaml
let rec croissant l = match l with
    | [] | [_] -> true   (* Liste vide ou un élément : toujours croissante*)
    | x :: y :: tail -> x <= y && croissant (y :: tail)
```

### Exercice 9

```ocaml
let rec concat u v = match u with
    | [] -> v
    | x :: tail -> x :: concat tail v
```

### Exercice 10

```ocaml
let rec miroir l = match l with
    | [] -> l
    | x :: tail -> miroir tail @ [x]
```

### Exercice 11

```ocaml
let rec uniques l = match l with
    | [] | [_] -> l
    | x :: y :: tail ->
        if x = y then uniques (y :: tail)
        else x :: uniques (y :: tail)

        (* autre version *)
        let u = uniques (y :: tail) in
            if x = y then u
            else x :: u
```

## Pour ceux qui ont fini

### Exercice 12

```ocaml
let rec indice x l =
    let rec indice_bis x l i = match l with
        | [] -> failwith "not found"
        | y :: ys when x = y -> i
        | _ :: ys -> indice_bis x ys (i + 1) in
    indice_bis x l 0
```

### Exercice 13

```ocaml
let rec sous_liste u x = match x with
    | [] -> x
    | n :: _ when n > longueur u -> []
    | n :: tail -> let rec get_el u n i = match u with
            | [] -> []
            | x :: _ when i = n -> [x]
            | x :: tail -> get_el tail n (i + 1) in
        get_el u n 0 @ sous_liste u tail
```

### Exercice 14

```ocaml
let rec comparer_longueur a b =
    let len_a, len_b = longueur a, longueur b in
        if len_a < len_b then -1
        else if len_a > len_b then 1
        else 0
```

```ocaml
let rec comparer_longueur_efficace a b = match a, b with
    | [], [] -> 0
    | [], _ -> -1
    | _, [] -> 1
    | _ :: x, _ :: y -> comparer_longueur_efficace x y
```
