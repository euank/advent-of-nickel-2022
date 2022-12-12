let lib = import "../lib.ncl" in
let input = import "./input.ncl" in

let summedParts = input |> string.split "\n\n" |> array.map (fun s => (string.split "\n" s |> array.map string.to_num |> array.fold (fun l r => l + r) 0))
in

let sorted = array.sort (lib.array.cmpRev lib.num.cmp) summedParts
in
{
  part1 = array.head sorted,
  part2 = array.map (fun i => array.elem_at i sorted) [0, 1, 2] |> (lib.array.foldl' (fun l r => l + r) 0)
}
