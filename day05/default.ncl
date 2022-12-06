let lib = import "../lib.ncl" in
let input = import "./input.ncl" in

let inputParts = input |>
  string.split "\n\n" |>
  array.map (string.split "\n") |>
  (fun arr => { stacks = array.head arr, moves = array.elem_at 1 arr })
in
let parseStacks = fun lines =>
  let lastLine = lib.array.last lines in
  # pad with the extra space on the right, and then for single-digit numbers
  # each col has a width of 4. We have no clue how 10 would be formatted since
  # the numbers only go up to 9. Hardcode that assumption.
  let numCols = ((string.length lastLine) + 1) / 4 in
  let height = (array.length lines) - 1 in
  let colStrings = array.generate (fun x => array.generate (fun y => array.elem_at y lines |> string.chars |> array.elem_at ((x + 1) * 4 - 3)) height) numCols in
  array.map (fun arr => array.filter (fun f => f != " ") arr) colStrings
in
let parseMoves = fun lines =>
    lines |>
    array.map (string.split " ") |>
    array.map (fun parts => { count = string.to_num (array.elem_at 1 parts), from = string.to_num (array.elem_at 3 parts), to = string.to_num (array.elem_at 5 parts) })
in
let stacks = parseStacks inputParts.stacks in
let moves = parseMoves inputParts.moves in

# Move 1 at a time, and recurse
let rec applyMove = fun stack move =>
  let
    updatedStack =
      let fromCol = array.elem_at (move.from - 1) stack in
      let toCol = array.elem_at (move.to - 1) stack in
      stack |>
        lib.array.set (move.to - 1) ((lib.array.take 1 fromCol) @ toCol) |>
        lib.array.set (move.from - 1) (lib.array.drop 1 fromCol)
      in
    if move.count == 0 then stack
    else applyMove updatedStack (record.update "count" (move.count - 1) move)
in
let stackTops = fun stacks => array.map array.head stacks |> string.join "" in
{
  part1 = (array.foldl applyMove stacks moves) |> stackTops
}
