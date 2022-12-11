let lib = import "../lib.ncl" in
let input = import "./input.ncl" in

let instructions =
  input |>
  string.split "\n" |>
  array.map (fun line =>
    line |>
    string.split " " |>
    (fun els => { move = array.head els, num = string.to_num (array.elem_at 1 els) })
  ) in

let flatInstructions = lib.array.flatten' (
  array.map (fun el => array.generate (fun i => {move = el.move}) el.num) instructions
) in

let applyInstruction = fun state instr =>
  let newLoc = if instr.move == "U" || instr.move == "D" then
  let dir = if instr.move == "U" then 1 else -1 in
    { x = state.head.x, y = state.head.y + dir}
  else if instr.move == "L" || instr.move == "R" then
  let dir = if instr.move == "R" then 1 else -1 in
    { x = state.head.x + dir, y = state.head.y}
  else "unreachable"
  in
  if (num.abs (newLoc.x - state.tail.x) > 1) || (num.abs (newLoc.y - state.tail.y) > 1) then
    # Tail moves to where we were last round
    {
      head = newLoc,
      tail = state.head,
      out = let key = "%{string.from_num state.head.x}_%{string.from_num state.head.y}" in if record.has_field key state.out.m then state.out else {m = state.out.m & {"%{key}" = true}, len = state.out.len + 1},
    }
  else
    {
      head = newLoc,
      tail = state.tail,
      out = state.out
    }
in

let part1Answer = fun instr =>
  let out = (lib.array.foldl' applyInstruction ({
    head = {x = 0, y = 0},
    tail = {x = 0, y = 0},
    out = {m = {"0_0" = true}, len = 1},
  }) instr).out in
  out.len
in
{
  part1 = part1Answer flatInstructions,
}
