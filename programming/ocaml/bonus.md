# Algorithmes bonus

## DM n°1 - Exercice 3

```ocaml
let dm n =
    let rec one n i =
        let rec two j =
            if j = 1. then 1.
            else two (j -. 1.) +. 1. /. j in
        if i = 0 then 0.
        else two (float n) *. float i +. one n (i - 1) in
    one n n
```
