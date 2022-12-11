let lib = import "../lib.ncl" in
let input = import "./input.ncl" in

let instructions =
  input |>
  string.split "\n" |>
  array.map (fun line =>
    if line == "noop" then { instr = `Noop }
    else { instr = `Add, val = string.to_num (array.elem_at 1 (string.split " " line))}
  ) in

let compute = fun state instr =>
  if instr.instr == `Noop then
    {
      x = state.x,
      cycles = state.cycles + 1,
      valHistory = state.valHistory @ [cycles * state.x],
    }
  else
    {
      x = state.x + instr.val,
      cycles = state.cycles + 2,
      # x for two cycles
      valHistory = state.valHistory @ [(cycles - 1) * state.x, cycles * state.x],
    }
in

let part1Answer = fun instr =>
  let out = (lib.array.foldl' compute ({
    x = 1,
    cycles = 0,
    valHistory = [1],
  }) instructions) in
  let cyclesToSum = [20, 60, 100, 140, 180, 220] in
  let vals = array.map (fun idx => array.elem_at idx out.valHistory) cyclesToSum in
  lib.array.sum (+) vals
in
{
  part1 = part1Answer instructions,
}
