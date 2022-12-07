let lib = import "../lib.ncl" in
let input = import "./input.ncl" in

let rec parseLS = fun lines =>
  let line = array.head lines in
  if (array.length lines) == 0 then { entries = [], rem = [] }
  else if (lib.string.starts_with "$ " line) then { entries = [], rem = lines}
  else if lib.string.starts_with "dir " line then let sub = parseLS (array.tail lines) in {entries = [{typ = `Dir, name = string.substring 4 (string.length line) line}] @ sub.entries, rem = sub.rem}
  else let parts = string.split " " line in let sub = parseLS (array.tail lines) in {entries = [{typ = `File, size = string.to_num (array.head parts), name = (lib.array.last parts)}] @ sub.entries, rem = sub.rem} in

let rec parseInput = fun lines =>
  if (array.length lines) == 0 then [] else
  let line = array.head lines in
  if (lib.string.starts_with "$ cd " line) then [{typ = `Cd, dest = string.substring 5 (string.length line) line}] @ (parseInput (array.tail lines))
  else if line == "$ ls" then let ls = parseLS (lib.array.drop 1 lines) in [{typ = `Ls, entries = ls.entries}] @ (parseInput ls.rem)
  else []
in
let parsed = parseInput (string.split "\n" input) in
# Now fold it all together into state
let updateState = fun state el =>
  # All cd cases
  if el.typ == `Cd && el.dest == "/" then record.update "dir" [] state
  else if el.typ == `Cd && el.dest == ".." then record.update "dir" (lib.array.take ((array.length state.dir) - 1) state.dir) state
  else if el.typ == `Cd then record.update "dir" (state.dir @ [el.dest]) state
  else if el.typ == `Ls then record.update "fs" (record.update ("/" ++ (string.join "/" state.dir)) el.entries state.fs) state
  else "unrechable"

in
let fs = (array.foldl updateState {dir = [], fs = {}} parsed).fs in

let rec dirSize = fun fs dir =>
  if !(record.has_field dir fs) then 0
  else array.foldl (fun acc entry => acc + (if entry.typ == `File then entry.size else (dirSize fs ((if dir == "/" then "/" else (dir ++ "/")) ++ entry.name)))) 0 fs."%{dir}"
in
let part1Answer = fun fs =>
  let dirSizes = record.map (fun k v => dirSize fs k) fs
  in array.foldl (fun acc val => if val <= 100000 then acc + val else acc) 0 (record.values dirSizes)

in
{
  part1 = part1Answer fs,
}
