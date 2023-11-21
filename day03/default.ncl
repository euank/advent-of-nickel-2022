let lib = import "../lib.ncl" in
let input = import "./input.ncl" in
let array = std.array in
let string = std.string in

let rec dedupeSorted = fun arr =>
  if (array.length arr) <= 1 then
    arr
  else
    let h = array.first arr in
    let t = array.drop_first arr in
    if h == (array.first t) then (dedupeSorted t) else [h] @ (dedupeSorted t)
in
let toPrio = fun c =>
  if ((lib.string.code c) >= (lib.string.code "A") && (lib.string.code c) <= (lib.string.code "Z")) then
    (lib.string.code c) - (lib.string.code "A") + 27
  else
    (lib.string.code c) - (lib.string.code "a") + 1
in
let rec countDupes = fun lhs rhs =>
  if (array.length lhs) == 0 then
    0
  else if (array.length rhs) == 0 then
    0
  else
    let lh = (array.first lhs) in
    let rh = (array.first rhs) in
    if lh == rh then
      lh + (countDupes (array.drop_first lhs) (array.drop_first rhs))
    else if lh < rh then
      countDupes (array.drop_first lhs) rhs
    else
      countDupes lhs (array.drop_first rhs)
in
let sortedLR =
  input
  |> string.split "\n"
  |> array.map (fun s => { L = (string.substring 0 ((string.length s) / 2) s), R = (string.substring ((string.length s) / 2) (string.length s) s) })
  |> array.map (fun el => { L = (string.characters el.L), R = (string.characters el.R) })
  |> array.map (fun el => { L = array.map toPrio el.L, R = array.map toPrio el.R })
  |> array.map (fun el => { L = array.sort lib.num.cmp el.L, R = array.sort lib.num.cmp el.R })
  |> array.map (fun el => { L = dedupeSorted el.L, R = dedupeSorted el.R })
in
let counts = array.map (fun el => countDupes el.L el.R) sortedLR
in
# part2
let rec commonEl = fun a b c =>
  let ah = array.first a in
  let bh = array.first b in
  let ch = array.first c in
  if ah == bh && bh == ch then
    ah
  else if ah <= bh && ah <= ch then
    (commonEl (array.drop_first a) b c)
  else if bh <= ah && bh <= ch then
    (commonEl a (array.drop_first b) c)
  else
    (commonEl a b (array.drop_first c))
in
let part2Count =
  input
  |> string.split "\n"
  |> array.map string.characters
  |> array.map (array.map toPrio)
  |> array.map (array.sort lib.num.cmp)
  |> array.map dedupeSorted
  |> lib.array.chunk 3
  |> array.map (fun a => commonEl (array.at 0 a) (array.at 1 a) (array.at 2 a))
  |> lib.array.sum (+)
in
{
  part1 = lib.array.sum (+) counts,
  part2 = part2Count
}
