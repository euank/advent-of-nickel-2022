let lib = import "../lib.ncl" in
let input = import "./input.ncl" in

let gridChars = string.split "\n" input |> array.map string.chars in
let allGridCoords = array.generate (fun x' => array.generate (fun y' => { x = x', y = y' })  (lib.array2.height gridChars)) (lib.array2.width gridChars) |> array.flatten in
let start = lib.array.find (fun el => (lib.array2.get el.x el.y gridChars) == "S") allGridCoords in
let end = lib.array.find (fun el => (lib.array2.get el.x el.y gridChars) == "E") allGridCoords in
let gridNum' = gridChars |> array.map (array.map (fun c => (string.code c) - (string.code "a"))) in
# replace start/end with real elevation
let gridNum = lib.array2.set start.x start.y 0 (lib.array2.set end.x end.y 26 gridNum') in

let maxScore = (lib.array2.width gridNum) * (lib.array2.height gridNum) in

let fVal = fun p end grid =>
  # Distance between pt and end, forget the sqt since it's probably quicker to not bother, and relative fitness values are all that matter
  let dx = num.abs (end.x - p.x) in
  let dy = num.abs (end.y - p.y) in
  # z is height 26, so the higher we are the easier it is to get there, include that too as a less powerful heuristic
  let height = (lib.array2.get p.x p.y grid) in
  dx * dx + dy * dy + height
in

# time for an A*
let astar = fun start end grid =>
  let gridWidth = lib.array2.width grid in
  let gridHeight = lib.array2.height grid in
  let openSet = [ start ] in
  let gScores = let maxed = lib.array2.generate (lib.array2.width grid) (lib.array2.height grid) (fun x y => maxScore) in lib.array2.set start.x start.y 0 maxed in
  let rec astar' = fun state =>
    if array.length state.open == 0 then state & { err = "none left in open" }
    else
      let pt = array.head state.open in
      let ptScore = lib.array2.get pt.x pt.y state.g in
      let ptH = lib.array2.get pt.x pt.y grid in
      if pt == end then ptScore
      else
        # Otherwise, expand
        let neighbors = array.generate (fun i => if i == 0 then {x = pt.x - 1, y = pt.y} else if i == 1 then {x = pt.x + 1, y = pt.y} else if i == 2 then {x = pt.x, y = pt.y - 1} else {x = pt.x, y = pt.y + 1}) 4 in
        let neighbors' = array.filter (
          fun p =>
            let oldG = lib.array2.get p.x p.y state.g in
            let pH = lib.array2.get p.x p.y grid in
            # outside the grid
            p.x >= 0 && p.y >= 0 && p.x < gridWidth && p.y < gridHeight &&
            # And also verify it's at most 1 taller than us
            pH <= (ptH + 1) &&
            # And verify that this would be an improvement
            (ptScore + 1) < oldG
        ) neighbors in
        # Update g
        let state' = lib.array.foldl' (
          fun state p =>
            {
              open = state.open,
              g = lib.array2.set p.x p.y (ptScore + 1) state.g,
              f = lib.array2.set p.x p.y (ptScore + 1 + (fVal p end grid)) state.f,
            }
        ) state neighbors' in
        let open' = (array.tail state.open) @ neighbors' in
        let openSorted = array.sort (fun l r => lib.num.cmp (lib.array2.get l.x l.y state'.f) (lib.array2.get r.x r.y state'.f)) open' in
        let openSortedDeduped = lib.array.dedupeSorted openSorted in
        astar' {open = openSortedDeduped, g = state'.g, f = state'.f, steps = state.steps + 1}
  in astar' { open = openSet, g = gScores, f = gScores, steps = 0 }
in
{
  part1 = astar start end gridNum,
}
