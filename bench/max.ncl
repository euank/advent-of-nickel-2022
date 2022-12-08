let arr = import "./testdata/arr.ncl" in

# time on my machine: 23s
let maxFold = array.foldl (fun max el => if el > max then el else max) 0 in

# time on my machine: 25s
let maxFoldNumMax = array.foldl num.max 0 in

# time on my machine: 44s
let rec maxRec = fun arr =>
  let next = array.head arr in
  if (array.length arr) == 1 then next
  else let maxRest = maxRec (array.tail arr) in
    if next > maxRest then next else maxRest
in

# time on my machine: 0.07
let rec chunkGenMax = fun arr =>
  let len = array.length arr in
  if len == 1 then (array.head arr)
  else if len == 2 then num.max (array.head arr) (array.elem_at 1 arr)
  else chunkGenMax ((array.generate (fun i => num.max (array.elem_at (i * 2) arr) (array.elem_at (i * 2 + 1) arr)) (num.floor (len / 2))) @ (if (len % 2) == 1 then [(array.elem_at (len - 1) arr)] else []))
in
  chunkGenMax arr
