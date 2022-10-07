let sum t =
  for i = 1 to Array.length t - 1 do
    t.(i) <- t.(i) + t.(i - 1)
  done;
  for i = Array.length t - 1 downto 1 do
    t.(i) <- t.(i - 1);
  done;
  t.(0) <- 0