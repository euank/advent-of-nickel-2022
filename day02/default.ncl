let input = import "./input.ncl"
in

let p1 = input|>
  string.split "\n" |>
  array.map (string.split " ") |>
  array.foldl (
    fun acc el =>
      let lVal = (string.code (array.head el)) - 65 in
      let rVal = (string.code (array.elem_at 1 el)) - 88 in
      acc + rVal + 1 + (
        if lVal == rVal then 3
        else if ((lVal + 1) % 3) == rVal then 6
        else 0
      )
    ) 0
in
{
  part1 = p1
}
