# nickel functions that seemed generic enough to be useful outside of a single day
# Some may only be used in a single day, but each one felt at least generic
let ascii = import "./ascii.ncl" in
let std = import "./fastd.ncl" in
{
  # force' : forall a. a -> a = fun a => std.deep_seq (a | Dyn) a,
  array = {
    cmpRev
      = fun f => fun l r => let orig = f l r in if orig == 'Lesser then 'Greater else if orig == 'Greater then 'Lesser else 'Equal,

    slice
      = fun i j arr => std.array.generate (fun idx => std.array.at (idx + i) arr) (1 + j - i),

    take
       = fun n arr => if n == 0 then [] else [ (std.array.first arr) ] @ (take (n - 1) (std.array.drop_first arr)),

    drop
      = fun n arr => if (std.array.length arr) == 0 || n == 0 then arr else drop (n - 1) (std.array.drop_first arr),

    chunk
      = fun n arr => if (std.array.length arr) <= n then [ arr ] else [(take n arr)] @ (chunk n (drop n arr)),

    sum
      = fun f arr => std.array.fold_left f (std.array.first arr) (std.array.drop_first arr),

    last
      = fun arr => std.array.at ((std.array.length arr) - 1) arr,

    set
      = fun n val arr => (take n arr) @ [ val ] @ (drop (n + 1) arr),

    dedupeSorted = fun arr =>
      if std.array.length arr <= 1 then arr else
        let h = std.array.first arr in
        let t = std.array.drop_first arr in
        if h == (std.array.first t)
          then dedupeSorted ([h] @ (std.array.drop_first t))
          else [h] @ (dedupeSorted t),

    singleton | doc "create an array with a single element"
      = fun a => [a],

    maxNumber
      = fun arr =>
        let len = std.array.length arr in
        if len == 1 then (std.array.first arr)
        else if len == 2 then std.number.max (std.array.first arr) (std.array.at 1 arr)
        else maxNumber ((std.array.generate (fun i => std.number.max (std.array.at (i * 2) arr) (std.array.at (i * 2 + 1) arr)) (std.number.floor (len / 2))) @ (if (len % 2) == 1 then [(std.array.at (len - 1) arr)] else [])),

    foldl'
      | doc "Identical to the stdlib array.fold_left except fast."
      = fun f acc l =>
          if std.array.length l == 0 then acc else
          let rec out = std.array.generate (fun i => let v = f (if i == 0 then acc else (std.array.at (i - 1) out)) (std.array.at i l) in v) (std.array.length l) in
          last out,

    flatten'
      | doc "array.flatten, but faster."
        = fun l => foldl' (fun acc l => acc @ l) [] l,

    find = fun f arr =>
          foldl' (fun acc l => if (f l) then l else acc) null arr,
  },
  num = {
    cmp | doc "comparison function for numbers, useful with array.sort"
      = fun l r => if l < r then 'Lesser else 'Greater
  },
  string = {
    starts_with
      = fun prefix str =>
          if (std.string.length prefix) > (std.string.length str) then false
          else (std.string.substring 0 (std.string.length prefix) str) == prefix,

    # code returns the codepoint for an ascii character.
    code
      = fun s => ascii."%{s}",

    # splitn : Number -> String -> String -> Array String
    splitn
      = fun n sep str => let s1 = std.string.split sep str in if std.array.length s1 > n then (array.take (n - 1) s1) @ [(std.string.join sep (array.drop (n - 1) s1))] else s1,
  },

  record = {
    # Adding the below type causes a type error, even though it seems like it should be right :(
    # filter : forall a. (String -> a -> Bool) -> {_: a} -> {_: a}
    filter = fun f r =>
      std.array.fold_left (fun out k => let v = r."%{k}" in if f k v then std.record.insert k v out else out) {} (std.record.fields r),
  },

  array2 = {
    # Get gets an element in a 2d arr, for example:
    # [ [ 1, 2, 3],
    #   [ 4, 5, 6],
    #   [ 7, 8, 9] ]
    # get 1 2 = 8
    # get 0 0 = 1
    get
      = fun x y arr2 => arr2 |> std.array.at y |> std.array.at x,

    generate
      = fun w h f => std.array.generate (fun y => std.array.generate (fun x => f x y) w) h,

    getDefault = fun x y def arr2 => if x < (width arr2) && y < (height arr2) then get x y arr2 else def,

    width = fun arr2 => std.array.length (std.array.first arr2),
    height = fun arr2 => std.array.length arr2,

    set = fun x y v arr2 => std.array.generate (fun y' => std.array.generate (fun x' => if x == x' && y == y' then v else get x' y' arr2) (width arr2)) (height arr2),

    resize = fun w h zero arr2 => std.array.generate (fun y => std.array.generate (fun x => getDefault x y zero arr2) w) h,

    # Rotate a 2d arr right. For example:
    # rotateRight [ [1, 2],
    #               [3, 4],
    #               [5, 6] ] =
    #             [ [5, 3, 1],
    #               [6, 4, 2] ]
    # rotateRight : forall a. Array (Array a) -> Array (Array a)
    rotateRight = fun arr2 =>
        let h = std.array.length arr2 in
        let w = std.array.length (std.array.first arr2) in
        std.array.generate (fun x => std.array.generate (fun y => array2.get x (h - y - 1) arr2) h) w,

    # Rotate a 2d arr left. For example:
    # rotateLeft  [ [1, 2],
    #               [3, 4],
    #               [5, 6] ] =
    #             [ [2, 4, 6],
    #               [1, 3, 5] ]
    # rotateLeft : forall a. Array (Array a) -> Array (Array a)
    rotateLeft = fun arr2 =>
        let h = std.array.length arr2 in
        let w = std.array.length (std.array.first arr2) in
        std.array.generate (fun x => std.array.generate (fun y => array2.get (w - x - 1) y arr2) h) w,
  },

}
