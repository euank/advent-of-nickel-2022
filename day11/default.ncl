let lib = import "../lib.ncl" in
let input = import "./input.ncl" in

let parseOperation = fun opLine =>
  let parts = opLine |> %str_find% "^new = old (.) (.*)$" in
  let op = array.head parts.groups in
  let rhs' = lib.array.last parts.groups in
  {
    str = opLine,
    apply = fun old =>
      let rhs = if rhs' == "old" then old else string.to_num rhs' in
      if op == "+" then old + rhs else if op == "*" then old * rhs else "unreachable",
  }
in

let parseTests = fun lines =>
  let matches = %str_find% "Test: divisible by (\\d+) .*If true: throw to monkey (\\d+) .*If false: throw to monkey (\\d+)" (string.join " " lines) in
  let divBy = array.head matches.groups |> string.to_num in
  let ifMatch = array.elem_at 1 matches.groups |> string.to_num in
  let ifNotMatch = array.elem_at 2 matches.groups |> string.to_num in
  {
    str = string.join ". " lines,
    apply = fun num => if num % divBy == 0 then ifMatch else ifNotMatch
  }
in


let Monkey = {
  items | Array Num,
  operation | {
    str | Str,
    apply | Dyn,
  },
  tests | {
    str | Str,
    apply | Dyn,
  },
}
in


let parseMonkey = fun monkey =>
  let lines = lib.array.drop 1 (string.split "\n" monkey) |> array.map string.trim in
  let startingItems = array.head lines |> lib.string.splitn 3 " " |> lib.array.last |> string.split ", " |> array.map string.to_num in
  let operation' = array.elem_at 1 lines |> lib.string.splitn 2 ": " |> lib.array.last |> parseOperation in
  let tests' = lib.array.slice 2 4 lines |> parseTests in
  {
    items = startingItems,
    operation = operation',
    tests = tests',
  } | Monkey
in

let MonkeyState = {
  monkeys | Array Monkey,
  inspections | Array Num,
}
in

let doMonkey = fun state idx =>
  let state' = (state | MonkeyState) in
  let curMonkey = array.elem_at idx state'.monkeys in
  let inspections' = array.length curMonkey.items in
  let newMonkeys = lib.array.foldl' (fun monkeys item =>
    let monkey = (array.elem_at idx monkeys) | Monkey in
    let newItem = monkey.operation.apply item | Num in
    let newItem' = num.floor (newItem / 3) in
    let throwTarget = monkey.tests.apply newItem' | Num in
    let newMonkeys = lib.array.set throwTarget (let old = array.elem_at throwTarget monkeys in {items = old.items @ [newItem'], operation = old.operation, tests = old.tests}) monkeys | Array Monkey in
    newMonkeys
  ) state'.monkeys curMonkey.items in
  let newMonkeys' = lib.array.set idx ({items = [], operation = curMonkey.operation, tests = curMonkey.tests}) newMonkeys | Array Monkey in
  {
    monkeys = newMonkeys',
    inspections = lib.array.set idx ((array.elem_at idx state.inspections) + inspections') state.inspections,
  }
in

let playRound = fun state =>
  lib.array.foldl' doMonkey state (array.generate function.id (array.length state.monkeys))
in

let monkeys_ =
  input |>
  string.split "\n\n" |>
  array.map parseMonkey in
let initInspections = array.generate (fun i => 0) (array.length monkeys_) in
let endState = lib.array.foldl' (fun ms i => playRound ms) {monkeys = monkeys_, inspections = initInspections} (array.generate function.id 20) in
let monkeyBusiness = endState.inspections |> array.sort (lib.array.cmpRev lib.num.cmp) |> lib.array.take 2 |> lib.array.sum (*) in

{
  part1 = monkeyBusiness,
}
