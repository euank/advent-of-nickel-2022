let lib = import "../lib.ncl" in
let input = import "./input.ncl" in

let p1 = input |>
  string.split "\n" |>
  array.map (string.split " ") |>
  lib.array.foldl' (
    fun acc el =>
      let lVal = (string.code (array.head el)) - 65 in
      let rVal = (string.code (array.elem_at 1 el)) - 88 in
      acc + rVal + 1 + (
        if lVal == rVal then 3
        else if ((lVal + 1) % 3) == rVal then 6
        else 0
      )
    ) 0
in

let p2 = input |>
  string.split "\n" |>
  array.map (string.split " ") |>
  array.map (
    fun el =>
      let lVal = (string.code (array.head el)) - 65 in
      let rVal = (string.code (array.elem_at 1 el)) - 88 in
      [ lVal, rVal ]
  ) |>
  lib.array.foldl' (
    let
      goalScore = fun l r =>
        # lose
        if r == 0 then (l + 2) % 3 + 1
        # draw
        else if r == 1 then 3 + l + 1
        # win
        else (l + 1) % 3 + 1 + 6
    in
    fun acc el => acc + (goalScore (array.head el) (array.elem_at 1 el))
  ) 0
in
{
  part1 = p1,
  part2 = p2
}
