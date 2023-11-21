let lib = import "../lib.ncl" in
let input = import "./input.ncl" in

let p1 =
  input
  |> std.string.split "\n"
  |> std.array.map (std.string.split " ")
  |> lib.array.foldl'
    (
      fun acc el =>
        let lVal = (lib.string.code (std.array.first el)) - 65 in
        let rVal = (lib.string.code (std.array.at 1 el)) - 88 in
        acc
        + rVal
        + 1
        + (
          if lVal == rVal then
            3
          else if ((lVal + 1) % 3) == rVal then
            6
          else
            0
        )
    )
    0
in

let p2 =
  input
  |> std.string.split "\n"
  |> std.array.map (std.string.split " ")
  |> std.array.map
    (
      fun el =>
        let lVal = (lib.string.code (std.array.first el)) - 65 in
        let rVal = (lib.string.code (std.array.at 1 el)) - 88 in
        [lVal, rVal]
    )
  |> lib.array.foldl'
    (
      let goalScore = fun l r =>
        # lose
        if r == 0 then
          (l + 2) % 3 + 1
          # draw
        else if r == 1 then
          3 + l + 1
          # win
        else
          (l + 1) % 3 + 1 + 6
      in
      fun acc el => acc + (goalScore (std.array.first el) (std.array.at 1 el))
    )
    0
in
{
  part1 = p1,
  part2 = p2
}
