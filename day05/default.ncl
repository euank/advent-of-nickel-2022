let lib = import "../lib.ncl" in
let input = import "./input.ncl" in
let array = std.array in
let string = std.string in
let record = std.record in

let inputParts =
  input
  |> string.split "\n\n"
  |> array.map (string.split "\n")
  |> (fun arr => { stacks = array.first arr, moves = array.at 1 arr })
in
let parseStacks = fun lines =>
  let lastLine = lib.array.last lines in
  # pad with the extra space on the right, and then for single-digit numbers
  # each col has a width of 4. We have no clue how 10 would be formatted since
  # the numbers only go up to 9. Hardcode that assumption.
  let numCols = ((string.length lastLine) + 1) / 4 in
  let height = (array.length lines) - 1 in
  let colStrings = array.generate (fun x => array.generate (fun y => array.at y lines |> string.characters |> array.at ((x + 1) * 4 - 3)) height) numCols in
  array.map (fun arr => array.filter (fun f => f != " ") arr) colStrings
in
let parseMoves = fun lines =>
  lines
  |> array.map (string.split " ")
  |> array.map (fun parts => { count = string.to_number (array.at 1 parts), from = string.to_number (array.at 3 parts), to = string.to_number (array.at 5 parts) })
in
let stacks = parseStacks inputParts.stacks in
let moves = parseMoves inputParts.moves in

# Move 1 at a time, and recurse
let rec applyMove = fun stack move =>
  let updatedStack =
    let fromCol = array.at (move.from - 1) stack in
    let toCol = array.at (move.to - 1) stack in
    stack
    |> lib.array.set (move.to - 1) ((lib.array.take 1 fromCol) @ toCol)
    |> lib.array.set (move.from - 1) (lib.array.drop 1 fromCol)
  in
  if move.count == 0 then
    stack
  else
    applyMove updatedStack (record.update "count" (move.count - 1) move)
in
let stackTops = fun stacks => array.map array.first stacks |> string.join "" in

# part2
let rec applyMove2 = fun stack move =>
  let fromCol = array.at (move.from - 1) stack in
  let toCol = array.at (move.to - 1) stack in
  stack
  |> lib.array.set (move.to - 1) ((lib.array.take move.count fromCol) @ toCol)
  |> lib.array.set (move.from - 1) (lib.array.drop move.count fromCol)
in
{
  part1 = (lib.array.foldl' applyMove stacks moves) |> stackTops,
  part2 = (lib.array.foldl' applyMove2 stacks moves) |> stackTops
}
