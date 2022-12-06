let lib = import "../lib.ncl" in
let input = import "./input.ncl" in

let
  rec identifyRun = fun idx last4 next =>
    let sorted = (array.sort (fun l r => lib.num.cmp (string.code l) (string.code r)) last4) in
    let hasDupes = (array.foldl (fun acc v => {dupe=acc.dupe || acc.c == v, c=v}) ({dupe = false, c = array.head sorted}) (array.tail sorted)).dupe in
    if !hasDupes then idx else (identifyRun (idx + 1) ((lib.array.drop 1 last4) @ [(array.head next)]) (array.tail next)) in

let
  rec identifyRun2 = fun idx last14 next =>
    let sorted = (array.sort (fun l r => lib.num.cmp (string.code l) (string.code r)) last14) in
    let hasDupes = (array.foldl (fun acc v => {dupe=acc.dupe || acc.c == v, c=v}) ({dupe = false, c = array.head sorted}) (array.tail sorted)).dupe in
    if !hasDupes then idx else (identifyRun (idx + 1) ((lib.array.drop 1 last14) @ [(array.head next)]) (array.tail next)) in

let inputChars = string.chars input in
{
  part1 = identifyRun 4 (lib.array.take 4 inputChars) (lib.array.drop 4 inputChars),
  part2 = identifyRun2 14 (lib.array.take 14 inputChars) (lib.array.drop 14 inputChars),
}
