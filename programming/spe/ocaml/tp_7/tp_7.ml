type 'a prop =
  | Top
  | Bot
  | V of 'a
  | Not of 'a prop
  | And of 'a prop * 'a prop
  | Or of 'a prop * 'a prop
  | Impl of 'a prop * 'a prop

type 'a sequent = {
  gamma : 'a prop list;
  delta : 'a prop list;
  gamma_var : 'a prop list;
  delta_var : 'a prop list
}

let create_sequent gamma delta =
  { gamma = gamma; delta = delta; gamma_var = []; delta_var = [] }

let rec member x t =
  match t with
  | [] -> false
  | u :: _ when u = x -> true
  | _ :: xs -> member x xs

(* Si forme "introduction du bottom" alors Bot est à gauche *)
let bot s = member Bot s.gamma_var || member Bot s.gamma

(* Si forme "introduction du top" alors Top est à droite *)
let top s = member Top s.delta_var || member Top s.gamma

let axiom s =
  let rec aux = function
    | [] -> false
    | x :: xs -> member x s.delta_var || member x s.delta || aux xs
  in aux s.gamma_var || aux s.gamma

exception Wrong_rule of string

let and_gamma s =
  match s.gamma with
  | And (f, g) :: q -> {
    gamma = f :: g :: q;
    gamma_var = s.gamma_var ;
    delta = s.delta ;
    delta_var = s.delta_var
  }
  | _ -> raise (Wrong_rule "And Gamma")

let or_gamma s =
  match s.gamma with
  | Or (f, g) :: q -> {
    gamma = f :: q;
    gamma_var = s.gamma_var ;
    delta = s.delta ;
    delta_var = s.delta_var
  }, {
    gamma = g :: q;
    gamma_var = s.gamma_var ;
    delta = s.delta ;
    delta_var = s.delta_var
  }
  | _ -> raise (Wrong_rule "Or Gamma")

let impl_gamma s =
  match s.gamma with
  | Impl (f, g) :: q -> {
    gamma = q;
    gamma_var = s.gamma_var ;
    delta = f :: s.delta ;
    delta_var = s.delta_var
  }, {
    gamma = g :: q;
    gamma_var = s.gamma_var ;
    delta = s.delta ;
    delta_var = s.delta_var
  }
  | _ -> raise (Wrong_rule "Impl Gamma")

let not_gamma s =
  match s.gamma with
  | Not f :: q -> {
    gamma = q;
    gamma_var = s.gamma_var ;
    delta = f :: s.delta ;
    delta_var = s.delta_var
  }
  | _ -> raise (Wrong_rule "Impl Gamma")
  
let and_delta s =
  match s.delta with
  | And (f, g) :: q -> {
    gamma = s.gamma;
    gamma_var = s.gamma_var ;
    delta = f :: q;
    delta_var = s.delta_var
  }, {
    gamma = s.gamma;
    gamma_var = s.gamma_var ;
    delta = g :: q;
    delta_var = s.delta_var
  }
  | _ -> raise (Wrong_rule "And Delta")
  
let or_delta s =
  match s.delta with
  | Or (f, g) :: q -> {
    gamma = s.gamma ;
    gamma_var = s.gamma_var ;
    delta = f :: g :: q;
    delta_var = s.delta_var
  }
  | _ -> raise (Wrong_rule "Or Delta")

let impl_delta s =
  match s.delta with
  | Impl (f, g) :: q -> {
    gamma = f :: s.gamma ;
    gamma_var = s.gamma_var ;
    delta = g :: q ;
    delta_var = s.delta_var
  }
  | _ -> raise (Wrong_rule "Impl Delta")

let not_delta s =
  match s.delta with
  | Not f :: q -> {
    gamma = f :: s.delta;
    gamma_var = s.gamma_var ;
    delta = q ;
    delta_var = s.delta_var
  }
  | _ -> raise (Wrong_rule "Not Delta")  

let rec proof_search seq =
  bot seq
  || top seq
  || axiom seq
  ||
    match seq.gamma with
    | f :: q -> begin
      match f with
      | Top | Bot | V _ ->
        proof_search { seq with
          gamma = q;
          gamma_var = f :: seq.gamma_var ;
        }
      | And _ -> proof_search (and_gamma seq)
      | Or _ ->
        let seq1, seq2 = or_gamma seq in
        proof_search seq1 && proof_search seq2
      | Impl _ ->
        let seq1, seq2 = impl_gamma seq in
        proof_search seq1 && proof_search seq2
      | Not _ -> proof_search (not_gamma seq)
      end
  | [] -> begin
    match seq.delta with
    | [] -> false
    | f :: q -> begin
      match f with
      | Top | Bot | V _ ->
        proof_search { seq with
          delta = q ;
          delta_var = f :: seq.delta_var
        }
      | And _ ->
        let seq1, seq2 = and_delta seq in
        proof_search seq1 && proof_search seq2
      | Or _ -> proof_search (or_delta seq)
      | Impl _ -> proof_search (impl_delta seq)
      | Not _ -> proof_search (not_delta seq)
    end
  end

let print_proof_result gamma delta =
  let result = proof_search (create_sequent gamma delta) in
  if result then Printf.printf "Séquent valide.\n%!"
  else Printf.printf "Séquent non valide.\n%!"


let test () =
  (* Exemples invalides *)
  print_proof_result [] [Or(V 1, V 1)];
  print_proof_result [] [Impl(Impl(Impl(V 1, V 2),V 1),V 2)];

  (* Exemples valides *)
  print_proof_result [] [Or(V 1, Not(V 1))];
  print_proof_result [] [Impl(Impl(Impl(V 1, V 2),V 1),V 1)];
  print_proof_result [And(And(V 1, V 2), V 3)] [And(V 1, And(V 2, V 3))];
  print_proof_result [Or(Or(V 1, V 2), V 3)] [Or(V 1, Or(V 2, V 3))];
  print_proof_result [Impl(V 1, V 2)] [Impl(Not(V 2), Not(V 1))];
  print_proof_result [Impl(Not(V 2), Not(V 1))] [Impl(V 1, V 2)];
  print_proof_result [V 1; V 2] [Impl(V 3, And(V 1, V 3))];

