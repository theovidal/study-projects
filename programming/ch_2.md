# Exercices supplémentaires du chapitre 8

## Exercice 5

```ocaml
let rec harmonique n =
    if n < 1 then 0.
    else h (n - 1) +. 1. /. float n
```

```ocaml
let premier_n x =
    let rec aux k s =
        if s >= x then k
        else aux (k + 1) (s +. 1. /. float (k + 1)) in
    aux 1 1.
```
