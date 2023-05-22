let lib = import "../lib.ncl" in
let array2 = lib.array2 in
let input = import "./input.ncl" in
let array = std.array in
let string = std.string in
let function = std.function in

# Parse into a 2d array
let grid = input |> string.split "\n" |> array.map (fun line => line |> string.characters |> (array.map string.to_number)) in
# Mark visible on a single row
let markVisibleOnRow = fun row => (lib.array.foldl' (fun state el => if el > state.max then {visible = state.visible @ [true], max = el} else {visible = state.visible @ [false], max = state.max}) {visible = [], max = -1} row).visible in
# Now, do this for each row. Then flip the array to do each row backwards.
# Rotate for each column. etc etc. Get em all, merge em all together.
let part1Answer = fun grid =>
  let visibleDirections = [
    # left to right
    grid |> array.map markVisibleOnRow,
    # right to left
    grid |> array.map array.reverse |> array.map markVisibleOnRow |> array.map array.reverse,
    # top to bottom
    grid |> array2.rotateLeft |> array.map markVisibleOnRow |> array2.rotateRight,
    # bottom to top
    grid |> array2.rotateRight |> array.map markVisibleOnRow |> array2.rotateLeft,
  ] in
  # merge them all together, just see if anything is visible
  let merged = array.generate (fun x => (array.generate (fun y => array.any function.id (array.map (fun a => array2.get x y a) visibleDirections)) (array.length (array.first grid)))) (array.length grid) in
  lib.array.foldl' (fun acc el => acc + (lib.array.foldl' (fun acc2 el2 => acc2 + (if el2 then 1 else 0)) 0 el)) 0 merged
in
# part2
# So, one observation we can make is that we can determine viewing distance in
# each direction with a relatively efficient method by doing 4 scans (again
# each of an RTL, LTR, TTB, BTT)
# For each scan, we just need a hashmap of the distance to a tree of height at least N, and then update it as we go.
# Doing that, and then doing the multiplication, seems like it should naively be fast enough, so let's go with that.
# Except, instead of a hashmap, since we know the keys are 0..9, we can use an array.
let viewDistanceOnRow =
  # We have something like [1, 1, 3, ... 3], which means that a height 0 tree
  # right now can see 1, a height 1 tree can see 1, a height 2 tree can see 3, up
  # to height 9 can see 9.
  # If we get a new tree of height 3, that means anything <= height 3 can now see 0, and everything > height 3 can see +1 distance.
  # Update it as such
  let updateDists = fun dists el => array.generate (fun i => if i <= el then 0 else (array.at i dists) + 1) (array.length dists) in
  let processRow = fun row =>
    lib.array.foldl'
      (fun state el => { out = state.out @ [(array.at el state.dists) + 1], dists = updateDists state.dists el })
      # start with 0, you can see nothing on the far edges iiuc
      ({ out = [0], dists = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] })
      (array.drop_first row) in
  fun row => (processRow row).out
in
let part2Answer = fun grid =>
  let dirs = [
    array.map viewDistanceOnRow grid,
    array.map viewDistanceOnRow (array.map array.reverse grid) |> array.map array.reverse,
    array.map viewDistanceOnRow (array2.rotateLeft grid) |> array2.rotateRight,
    array.map viewDistanceOnRow (array2.rotateRight grid) |> array2.rotateLeft,
  ] in
  # Multiply em all together, as it says to
  let merged = array.generate (fun y => (array.generate (fun x => lib.array.foldl' (fun acc el => acc * el) 1 (array.map (fun arr => array2.get x y arr) dirs)) (array.length (array.first grid)))) (array.length grid) in
  lib.array.maxNumber (array.flatten merged)
in
{
  part1 = part1Answer grid,
  part2 = part2Answer grid
}
