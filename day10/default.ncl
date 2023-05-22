let lib = import "../lib.ncl" in
let input = import "./input.ncl" in
let array = std.array in
let string = std.string in
let function = std.function in
let number = std.number in

let instructions =
  input |>
  string.split "\n" |>
  array.map (fun line =>
    if line == "noop" then { instr = 'Noop }
    else { instr = 'Add, val = string.to_number (array.at 1 (string.split " " line))}
  ) in

let compute = fun state instr =>
  if instr.instr == 'Noop then
    {
      x = state.x,
      cycles = state.cycles + 1,
      xs = state.xs @ [state.x],
      valHistory = state.valHistory @ [cycles * state.x],
    }
  else
    {
      x = state.x + instr.val,
      cycles = state.cycles + 2,
      # x for two cycles
      xs = state.xs @ [state.x, state.x],
      valHistory = state.valHistory @ [(cycles - 1) * state.x, cycles * state.x],
    }
in

let part1Answer = fun instr =>
  let out = (lib.array.foldl' compute ({
    x = 1,
    cycles = 0,
    valHistory = [1],
    xs = [],
  }) instructions) in
  let cyclesToSum = [20, 60, 100, 140, 180, 220] in
  let vals = array.map (fun idx => array.at idx out.valHistory) cyclesToSum in
  lib.array.sum (+) vals in

let drawCRT = fun state cycle =>
  let x = cycle % 40 in
  let xVal = array.at cycle state.xs in
  let drawHash = if x == 0 then xVal == 0 || xVal == 1
    else if x == 39 then xVal == 38 || xVal == 39
    else (number.abs (x - xVal)) <= 1 in
  if x == 39 then {
    xs = state.xs,
    curOut = [],
    rows = state.rows @ [(state.curOut @ [(if drawHash then "#" else ".")])],
  } else {
    xs = state.xs,
    curOut = state.curOut @ [(if drawHash then "#" else ".")],
    rows = state.rows,
  }

in

let part2Answer = fun instr =>
  let c = (lib.array.foldl' compute ({
    x = 1,
    cycles = 0,
    valHistory = [1],
    xs = [],
  }) instructions)
  in
  let out = lib.array.foldl' drawCRT ({
    xs = c.xs,
    curOut = [],
    rows = [],
  }) (array.generate function.id (6 * 40))
  in out.rows |> array.map (string.join "") |> string.join "\n"
in
{
  part1 = part1Answer instructions,
  part2 = part2Answer instructions,
}
