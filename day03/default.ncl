let lib = import "../lib.ncl" in
let input = import "./input.ncl" in

let rec
  dedupeSorted = fun arr => if (array.length arr) <= 1 then arr
  else let h = array.head arr in let t = array.tail arr in
  if h == (array.head t) then (dedupeSorted t) else [ h ] @ (dedupeSorted t)
in
let
  toPrio = fun c =>
    if ((string.code c) >= (string.code "A") && (string.code c) <= (string.code "Z")) then (string.code c) - (string.code "A") + 27
    else (string.code c) - (string.code "a") + 1
in
let rec
  countDupes = fun lhs rhs =>
    if (array.length lhs) == 0 then 0
    else if (array.length rhs) == 0 then 0
    else let lh = (array.head lhs) in let rh = (array.head rhs) in
    if lh == rh then lh + (countDupes (array.tail lhs) (array.tail rhs))
    else if lh < rh then countDupes (array.tail lhs) rhs
    else countDupes lhs (array.tail rhs)
in
let
  sortedLR = input |>
  string.split "\n" |>
  array.map (fun s => { L = (string.substring 0 ((string.length s) / 2) s), R = (string.substring ((string.length s) / 2) (string.length s) s) }) |>
  array.map (fun el => { L = (string.chars el.L), R = (string.chars el.R) }) |>
  array.map (fun el => { L = array.map toPrio el.L, R = array.map toPrio el.R }) |>
  array.map (fun el => { L = array.sort lib.num.cmp el.L, R = array.sort lib.num.cmp el.R }) |>
  array.map (fun el => { L = dedupeSorted el.L, R = dedupeSorted el.R })
in
let
  counts = array.map (fun el => countDupes el.L el.R) sortedLR
in
# part2
let
rec commonEl = fun a b c =>
  let ah = array.head a in
  let bh = array.head b in
  let ch = array.head c in
  if ah == bh && bh == ch then ah
  else if ah <= bh && ah <= ch then (commonEl (array.tail a) b c)
  else if bh <= ah && bh <= ch then (commonEl a (array.tail b) c)
  else (commonEl a b (array.tail c))
in
let
part2Count = input |>
  string.split "\n" |>
  array.map string.chars |>
  array.map (array.map toPrio) |>
  array.map (array.sort lib.num.cmp) |>
  array.map dedupeSorted |>
  lib.array.chunk 3 |>
  array.map (fun a => commonEl (array.elem_at 0 a) (array.elem_at 1 a) (array.elem_at 2 a)) |>
  lib.array.sum (+)
in
{
  part1 = lib.array.sum (+) counts,
  part2 = part2Count
}
