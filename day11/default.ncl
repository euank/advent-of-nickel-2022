let lib = import "../lib.ncl" in
let input = import "./input.ncl" in
let std = import "../fastd.ncl" in
let array = std.array in
let string = std.string in
let function = std.function in
let number = std.number in

let parseOperation = fun opLine =>
  let parts = opLine |> %str_find% "^new = old (.) (.*)$" in
  let op = array.first parts.groups in
  let rhs' = lib.array.last parts.groups in
  {
    apply = fun old =>
      let rhs = if rhs' == "old" then old else string.to_number rhs' in
      if op == "+" then old + rhs else if op == "*" then old * rhs else "unreachable",
  }
in

let parseTests = fun lines =>
  let matches = %str_find% "Test: divisible by (\\d+) .*If true: throw to monkey (\\d+) .*If false: throw to monkey (\\d+)" (string.join " " lines) in
  let divBy = array.first matches.groups |> string.to_number in
  let ifMatch = array.at 1 matches.groups |> string.to_number in
  let ifNotMatch = array.at 2 matches.groups |> string.to_number in
  {
    num = divBy,
    apply = fun num => if num % divBy == 0 then ifMatch else ifNotMatch,
  }
in

let parseMonkey = fun monkey =>
  let lines = lib.array.drop 1 (string.split "\n" monkey) |> array.map string.trim in
  {
    items = array.first lines |> lib.string.splitn 3 " " |> lib.array.last |> string.split ", " |> array.map string.to_number,
    operation = array.at 1 lines |> lib.string.splitn 2 ": " |> lib.array.last |> parseOperation,
    tests = lib.array.slice 2 4 lines |> parseTests,
  }
in

let monkeys_ =
  input
  |> string.split "\n\n"
  |> array.map parseMonkey
in

let worryLCM = lib.array.sum (*) (array.map (fun i => i.tests.num) monkeys_) in

let doMonkey = fun p2 state idx =>
  let curMonkey = array.at idx state.monkeys in
  let inspections' = array.length curMonkey.items in
  let newMonkeys =
    std.array.fold_left
      (
        fun monkeys item =>
          let monkey = (array.at idx monkeys) in
          let newItem = monkey.operation.apply item in
          let newItem' = if p2 then (newItem % worryLCM) else number.floor (newItem / 3) in
          let throwTarget = monkey.tests.apply newItem' in
          let newMonkeys = lib.array.set throwTarget (let old = array.at throwTarget monkeys in { items = old.items @ [newItem'], operation = old.operation, tests = old.tests }) monkeys in
          newMonkeys
      )
      state.monkeys
      curMonkey.items
  in
  let newMonkeys' = lib.array.set idx ({ items = [], operation = curMonkey.operation, tests = curMonkey.tests }) newMonkeys in
  {
    monkeys = newMonkeys',
    inspections = lib.array.set idx ((array.at idx state.inspections) + inspections') state.inspections,
  }
in

let playRound = fun p2 state =>
  std.array.fold_left (doMonkey p2) state (array.generate function.id (array.length state.monkeys))
in
let initInspections = array.generate (fun i => 0) (array.length monkeys_) in
let endState = std.array.fold_left (fun ms i => playRound false ms) { monkeys = monkeys_, inspections = initInspections } (array.generate function.id 20) in
let monkeyBusiness = endState.inspections |> array.sort (lib.array.cmpRev lib.num.cmp) |> lib.array.take 2 |> lib.array.sum (*) in

let endState2 = std.array.fold_left (fun ms i => playRound true ms) { monkeys = monkeys_, inspections = initInspections } (array.generate function.id 10000) in
let monkeyBusiness2 = endState2.inspections |> array.sort (lib.array.cmpRev lib.num.cmp) |> lib.array.take 2 |> lib.array.sum (*) in

{
  part1 = monkeyBusiness,
  part2 = monkeyBusiness2,
}
