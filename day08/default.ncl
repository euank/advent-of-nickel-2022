let lib = import "../lib.ncl" in
let array2 = lib.array2 in
let input = import "./input.ncl" in

# Parse into a 2d array
let grid = input |> string.split "\n" |> array.map (fun line => line |> string.chars |> (array.map string.to_num)) in
# Mark visible on a single row
let markVisibleOnRow = fun row => (array.foldl (fun state el => if el > state.max then {visible = state.visible @ [true], max = el} else {visible = state.visible @ [false], max = state.max}) {visible = [], max = -1} row).visible in
# Now, do this for each row. Then flip the array to do each row backwards.
# Rotate for each column. etc etc. Get em all, merge em all together.
let part1Answer = fun grid =>
  # left to right
  let visibleLTR = array.map markVisibleOnRow grid in
  # right to left
  let visibleRTL = array.map markVisibleOnRow (array.map array.reverse grid) |> array.map array.reverse in
  # top to bottom
  let visibleTTB = array.map markVisibleOnRow (array2.rotateLeft grid) |> array2.rotateRight in
  # bottom to top
  let visibleBTT = array.map markVisibleOnRow (array2.rotateRight grid) |> array2.rotateLeft in
  # merge them all together
  let merged = array.generate (fun x => (array.generate (fun y => array.any function.id [array2.get x y visibleLTR, array2.get x y visibleRTL, array2.get x y visibleTTB, array2.get x y visibleBTT]) (array.length (array.head grid)))) (array.length grid) in
  array.foldl (fun acc el => acc + (array.foldl (fun acc2 el2 => acc2 + (if el2 then 1 else 0)) 0 el)) 0 merged
in
  part1Answer grid
