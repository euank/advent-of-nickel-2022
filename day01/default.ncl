let lib = import "../lib.ncl" in
let input = import "./input.ncl" in
let array = std.array in
let string = std.string in

let summedParts = input |> std.string.split "\n\n" |> std.array.map (fun s => (std.string.split "\n" s |> std.array.map std.string.to_number |> std.array.fold_right (fun l r => l + r) 0))
in

let sorted = std.array.sort (lib.array.cmpRev lib.num.cmp) summedParts
in
{
  part1 = std.array.first sorted,
  part2 = std.array.map (fun i => std.array.at i sorted) [0, 1, 2] |> (lib.array.foldl' (fun l r => l + r) 0)
}
