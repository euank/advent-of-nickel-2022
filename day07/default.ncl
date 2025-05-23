let lib = import "../lib.ncl" in
let input = import "./input.ncl" in
let array = std.array in
let string = std.string in
let record = std.record in

let rec parseLS = fun lines =>
  let line = std.array.first lines in
  if (std.array.length lines) == 0 then
    { entries = [], rem = [] }
  else if (lib.string.starts_with "$ " line) then
    { entries = [], rem = lines }
  else if lib.string.starts_with "dir " line then
    let sub = parseLS (std.array.drop_first lines) in { entries = [{ typ = 'Dir, name = string.substring 4 (string.length line) line }] @ sub.entries, rem = sub.rem }
  else
    let parts = string.split " " line in let sub = parseLS (std.array.drop_first lines) in { entries = [{ typ = 'File, size = string.to_number (std.array.first parts), name = (lib.array.last parts) }] @ sub.entries, rem = sub.rem }
in

let rec parseInput = fun lines =>
  if (std.array.length lines) == 0 then
    []
  else
    let line = std.array.first lines in
    if (lib.string.starts_with "$ cd " line) then
      [{ typ = 'Cd, dest = string.substring 5 (string.length line) line }] @ (parseInput (std.array.drop_first lines))
    else if line == "$ ls" then
      let ls = parseLS (lib.array.drop 1 lines) in [{ typ = 'Ls, entries = ls.entries }] @ (parseInput ls.rem)
    else
      []
in
let parsed = parseInput (string.split "\n" input) in
# Now fold it all together into state
let updateState = fun state el =>
  # All cd cases
  if el.typ == 'Cd && el.dest == "/" then
    record.update "dir" [] state
  else if el.typ == 'Cd && el.dest == ".." then
    record.update "dir" (lib.array.take ((std.array.length state.dir) - 1) state.dir) state
  else if el.typ == 'Cd then
    record.update "dir" (state.dir @ [el.dest]) state
  else if el.typ == 'Ls then
    record.update "fs" (record.update ("/" ++ (string.join "/" state.dir)) el.entries state.fs) state
  else
    "unrechable"
in
let fs = (lib.array.foldl' updateState { dir = [], fs = {} } parsed).fs in

let rec dirSize = fun fs dir =>
  if !(record.has_field dir fs) then
    0
  else
    lib.array.foldl' (fun acc entry => acc + (if entry.typ == 'File then entry.size else (dirSize fs ((if dir == "/" then "/" else (dir ++ "/")) ++ entry.name)))) 0 fs."%{dir}"
in
let dirSizes = record.map (fun k v => dirSize fs k) fs in
let part1Answer = fun dirSizes =>
  lib.array.foldl' (fun acc val => if val <= 100000 then acc + val else acc) 0 (record.values dirSizes)
in
let part2Answer = fun dirSizes =>
  let curSize = dirSize fs "/" in
  let unusedSpace = 70000000 - curSize in
  let neededSpace = 30000000 - unusedSpace in
  let validSizes = std.array.filter (fun v => v >= neededSpace) (record.values dirSizes) in
  std.array.first (std.array.sort lib.num.cmp validSizes)
in
{
  part1 = part1Answer dirSizes,
  part2 = part2Answer dirSizes,
}
