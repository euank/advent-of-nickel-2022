let lib = import "../lib.ncl" in
let input = import "./input.ncl" in
let array = std.array in
let string = std.string in

let ranges = input |>
  string.split "\n" |>
  array.map (string.split ",") |>
  array.map (array.map (fun l => array.map string.to_number (string.split "-" l)))
in
let
  rangesIntersect = fun l r => let ll = array.first l in let lr = array.at 1 l in let rl = array.first r in let rr = array.at 1 r in
    if (ll <= rl && lr >= rr) || (rl <= ll && rr >= lr) then true else false
in
let
  containedRanges = ranges |>
    lib.array.foldl' (fun acc arr => let lhs = array.first arr in let rhs = array.at 1 arr in
      acc + (if (rangesIntersect lhs rhs) then 1 else 0)
    ) 0
# part2
in
let
  rangesOverlap = fun l r => let ll = array.first l in let lr = array.at 1 l in let rl = array.first r in let rr = array.at 1 r in
    (ll >= rl && ll <= rr) || (lr >= rl && lr <= rr) || (rl >= ll && rl <= lr) || (rr >= ll && rr <= lr)
in
let
  overlappingRanges = ranges |>
    lib.array.foldl' (fun acc arr => let lhs = array.first arr in let rhs = array.at 1 arr in
      acc + (if (rangesOverlap lhs rhs) then 1 else 0)
    ) 0
in
{
  part1 = containedRanges,
  part2 = overlappingRanges
}
