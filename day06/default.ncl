let lib = import "../lib.ncl" in
let input = import "./input.ncl" in

let
  # Identify a run of no dupes of a given length in the input string
  identifyRunOfLen = fun n str =>
    let rec identifyRun = fun idx start next =>
      let sorted = (array.sort (fun l r => lib.num.cmp (string.code l) (string.code r)) start) in
      let hasDupes = (array.foldl (fun acc v => {dupe=acc.dupe || acc.c == v, c=v}) ({dupe = false, c = array.head sorted}) (array.tail sorted)).dupe in
      if !hasDupes then idx else (identifyRun (idx + 1) ((lib.array.drop 1 start) @ [(array.head next)]) (array.tail next)) in
    let chars = string.chars str in
    identifyRun n (lib.array.take n chars) (lib.array.drop n chars)
in
{
  part1 = identifyRunOfLen 4 input,
  part2 = identifyRunOfLen 14 input,
}
