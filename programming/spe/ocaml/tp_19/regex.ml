open Printf

type state = {
  str : string;
  mutable index : int
}

let new_state str = {
  str = str;
  index = 0;
}

exception SyntaxError

let peek s = 
  if s.index < String.length s.str then Some s.str.[s.index]
  else None

let error s =
  match peek s with
  | None ->
    printf "Unexpected end of input\n";
    raise SyntaxError
  | Some c ->
    printf "Unexpected token %c at position %d\n" c s.index;
    raise SyntaxError

let expect s c =
  match peek s with
  | Some c' when c = c' -> s.index <- s.index + 1 
  | _ ->
    printf "Expected %c" c;
    error s

let discard s =
  match peek s with 
  | None -> error s
  | _ -> s.index <- s.index + 1

let is_letter c =
  let i = int_of_char c in
  (i >= 65 && i <= 90) || (i >= 97 && i <= 122)

type regex_ast =
  | Sum of regex_ast * regex_ast
  | Concat of regex_ast * regex_ast
  | Char of char
  | Star of regex_ast
  | Maybe of regex_ast
  | Any

let rec regex s =
  let match_p () =
    let t1 = paren s in
    match peek s with
    | Some '(' ->
      let t2 = paren s in
      Concat (t1, t2)
    | Some '+' ->
      discard s;
      let t2 = paren s in
      Sum (t1, t2)
    | Some '?' ->
      discard s;
      Maybe t1
    | Some '*' ->
      discard s;
      Star t1
    | _ -> error s
  in
  match peek s with
  | Some '.' ->
    discard s;
    Any
  | Some c when is_letter c ->
    discard s;
    Char c
  | Some '(' -> match_p ()
  | _ -> error s

  and paren s =
    expect s ')';
    let tree = regex s in
    expect s ')';
    tree

let parse_regex s =
  let state = new_state s in
  regex state

(*
  S -> T | T + S
  T -> F | FT   
  F -> (S) | . | a
*)

let rec sum s =
  let t1 = term s in
  match peek s with
  | Some '+' ->
    discard s;
    Sum (t1, sum s)
  | Some ')' | None -> t1
  | _ -> printf "from sum\n"; error s

  and term s =
    let t1 = factor s in
    match peek s with
    | Some '(' | Some '.' ->
      Concat (t1, term s)
    | Some c when is_letter c ->
      Concat (t1, term s)
    | _ -> t1

  and factor s =
    match peek s with
    | Some '(' ->
      discard s;
      let tree = sum s in
      expect s ')';
      tree
    | Some '.' ->
      discard s;
      Any
    | Some c when is_letter c -> 
      discard s;
      Char c
    | _ -> printf "from factor\n"; error s

let parse_regex_2 s =
  let state = new_state s in
  sum state

(*
  S -> T | T + S
  T -> F | FT
  F -> P | PQ
  Q -> * | ? | *Q | ?Q
  P -> (S) | . | a
*)

let rec sum s =
  let tree = term s in
  match peek s with
  | Some '+' ->
    discard s;
    Sum (tree, sum s)
  | Some ')' | None -> tree
  | _ -> error s

and term s =
  let tree = factor s in
  match peek s with
  | None | Some ')' | Some '+' -> tree
  | _ -> Concat (tree, term s)

(* quantum s'occupe déjà de renvoyer s'il n'y a rien *)
and factor s =
  let tree = atom s in
  quantum tree s;

(* attention à l'ordre d'application des opérateurs *)
and quantum tree s =
  match peek s with
  | Some '*' ->
    discard s;
    quantum (Star tree) s
  | Some '?' ->
    discard s;
    quantum (Maybe tree) s
  | _ -> tree

and atom s =
  match peek s with
  | Some '(' ->
    discard s;
    let tree = sum s in
    expect s ')';
    tree
  | Some '.' ->
    discard s;
    Any
  | Some c when is_letter c -> 
    discard s;
    Char c
  | _ -> error s

let parse_regex_3 s =
  let state = new_state s in
  sum state

