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
  let head = array.head state.rope in
  let newHead = if instr.move == "U" || instr.move == "D" then
  let dir = if instr.move == "U" then 1 else -1 in
    { x = head.x, y = head.y + dir}
  else if instr.move == "L" || instr.move == "R" then
  let dir = if instr.move == "R" then 1 else -1 in
    { x = head.x + dir, y = head.y}
  else "unreachable"
  in
  let rec newRope = array.generate (
    fun i => if i == 0 then newHead
      else
        let prev = (array.elem_at (i - 1) newRope) in
        let cur = (array.elem_at i state.rope) in
        if (num.abs (cur.x - prev.x) > 1) || (num.abs (cur.y - prev.y) > 1) then
          if cur.x == prev.x then {x = cur.x, y = cur.y + (if cur.y < prev.y then 1 else -1)}
          else if cur.y == prev.y then {y = cur.y, x = cur.x + (if cur.x < prev.x then 1 else -1)}
          else {
            y = cur.y + (if cur.y < prev.y then 1 else -1),
            x = cur.x + (if cur.x < prev.x then 1 else -1),
          }
        else cur
  ) (array.length state.rope) in
    let tail = lib.array.last newRope in
    {
      rope = newRope,
      out = let key = "%{string.from_num tail.x}_%{string.from_num tail.y}" in if record.has_field key state.out.m then state.out else {m = state.out.m & {"%{key}" = true}, len = state.out.len + 1},
    }
in

let part1Answer = fun instr =>
  let out = (lib.array.foldl' applyInstruction ({
    rope = array.generate (fun i => {x = 0, y = 0}) 2,
    out = {m = {"0_0" = true}, len = 1},
  }) instr).out in
  out.len in
let part2Answer = fun instr =>
  let out = (lib.array.foldl' applyInstruction ({
    rope = array.generate (fun i => {x = 0, y = 0}) 10,
    out = {m = {"0_0" = true}, len = 1},
  }) instr).out in
  out.len
in
{
  part1 = part1Answer flatInstructions,
  part2 = part2Answer flatInstructions,
}
