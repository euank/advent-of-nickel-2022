let lib = import "../lib.ncl" in
let input = import "./input.ncl" in

let ranges = input |>
  string.split "\n" |>
  array.map (string.split ",") |>
  array.map (array.map (fun l => array.map string.to_num (string.split "-" l)))
in
let
  rangesIntersect = fun l r => let ll = array.head l in let lr = array.elem_at 1 l in let rl = array.head r in let rr = array.elem_at 1 r in
    if (ll <= rl && lr >= rr) || (rl <= ll && rr >= lr) then true else false
in
let
  containedRanges = ranges |>
  array.foldl (fun acc arr => let lhs = array.head arr in let rhs = array.elem_at 1 arr in
    acc + (if (rangesIntersect lhs rhs) then 1 else 0)
  ) 0
in
{
  part1 = containedRanges
}
