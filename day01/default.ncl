let input = import "./input.ncl"
in

let summedParts = input |> string.split "\n\n" |> array.map (fun s => (string.split "\n" s |> array.map string.to_num |> array.fold (fun l r => l + r) 0))
in

let sorted = array.sort (fun a b => if a > b then `Lesser else `Greater) summedParts
in
{
  part1 = array.head sorted,
  part2 = array.map (fun i => array.elem_at i sorted) [0, 1, 2] |> (array.fold (fun l r => l + r) 0)
}
