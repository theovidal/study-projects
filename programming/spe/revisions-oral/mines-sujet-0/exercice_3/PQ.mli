(* 
   Ce module permet d'avoir des files a priorité. Ici, une 
   file a priorité est une structure de données qui permet
   de maintenir une liste de couple (x,p) avec x entier et
   p flottant. Le bénéfice d'une file à priorité par rapport
   à une simple liste c'est qu'elle permet de récupérer 
   rapidement la paire (x,p) dont la priorité p est minimale.

*)


type t

val recupere_min : t -> (int*float)
  (* 
     Prend en paramètre une file à priorité et retourne 
     une paire ayant la priorité minimale. Cette fonction
     ne modifie pas la file à priorité passée en paramètre !
     Cette fonction lève une exception si la file passée en 
     paramètre est vide.
   *)
  
val retire_min : t -> t
  (*
    Étant donnée une file a priorité F, cette fonction
    renvoie une file à priorité F' qui contient les mêmes
    éléments que F sauf l'élément renvoyé par recupere_min.
    Cette fonction lève une exception si la file passée en 
     paramètre est vide.
   *)
  
val ajoute : t -> int -> float -> t
  (*
    Étant donnée une file à priorité F, un entier x et une 
    priorité p, cette fonction renvoie la file a priorité F' 
    qui contient les mêmes éléments que F plus la paire (x,p)
   *)
  
val file_vide : t
  (*
    file_vide est une valeur qui correspond à la file à priorité 
    vide.
   *)
