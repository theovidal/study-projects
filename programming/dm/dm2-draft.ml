(* Première tentative de la Q15, utilisant le is_compatible *)
(* donc ça fait beaucoup trop de comparaisons *)

let get_possible_goals hist start =
  let rec aux goals candidate =
    if candidate = start-1 then goals
    else aux
      ((if is_compatible hist candidate then [candidate] else []) @ goals)
      (candidate - 1) 
  in aux [] (nb_combinations - 1)

let play_greedy goal =
  let rec aux hist code =
    if code = nb_combinations then hist
    else match hist with
    | (_, s) :: _ when s = (nb_pegs, 0) -> hist
    | _ ->
      let move = get_greedy_move (get_possible_goals hist code) in
      aux ((move, (similarity move goal)) :: hist) (move + 1)
  in List.rev (aux [] 0)
