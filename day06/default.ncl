let lib = import "../lib.ncl" in
let input = import "./input.ncl" in

let
  # Identify a run of no dupes of a given length in the input string
  identifyRunOfLen = fun n str =>
    let rec identifyRun = fun idx start next =>
      let hasDupes = (array.foldl (fun acc v => if acc.dupe then {dupe = true} else if record.has_field v acc.r then {dupe = true} else {dupe = false, r = acc.r & {"%{v}"=1}}) ({dupe = false, r = {}}) start).dupe in
      if !hasDupes then idx else (identifyRun (idx + 1) ((lib.array.drop 1 start) @ [(array.head next)]) (array.tail next)) in
    let chars = string.chars str in
    identifyRun n (lib.array.take n chars) (lib.array.drop n chars)
in
{
  part1 = identifyRunOfLen 4 input,
  part2 = identifyRunOfLen 14 input,
}
