# nickel functions that seemed generic enough to be useful outside of a single day
# Some may only be used in a single day, but each one felt at least generic
let stdarr = array in
let stdstr = string in
let stdrec = record in
let stdnum = num in
{
  force' : forall a. a -> a = fun a => builtin.deep_seq (a | Dyn) a,
  array = {
    cmpRev : (forall a. (a -> a -> [| `Lesser, `Equal, `Greater |]) -> (a -> a -> [| `Lesser, `Equal, `Greater |]))
      = fun f => fun l r => let orig = f l r in if orig == `Lesser then `Greater else if orig == `Greater then `Lesser else `Equal,

    slice : forall a. Num -> Num -> Array a -> Array a | doc "slice the array from index i to j"
      = fun i j arr => stdarr.generate (fun idx => stdarr.elem_at (idx + i) arr) (1 + j - i),

    take : forall a. Num -> Array a -> Array a | doc "take n elements from an array"
       = fun n arr => if n == 0 then [] else [ (stdarr.head arr) ] @ (take (n - 1) (stdarr.tail arr)),

    drop : forall a. Num -> Array a -> Array a | doc "drop n elements from an array"
      = fun n arr => if (stdarr.length arr) == 0 || n == 0 then arr else drop (n - 1) (stdarr.tail arr),

    chunk : forall a. Num -> Array a -> Array (Array a) | doc "chunk an array into arrays of size n"
      = fun n arr => if (stdarr.length arr) <= n then [ arr ] else [(take n arr)] @ (chunk n (drop n arr)),

    sum : forall a. (a -> a -> a) -> Array a -> a | doc "apply a binary operation to an array"
      = fun f arr => stdarr.foldl f (stdarr.head arr) (stdarr.tail arr),

    last : forall a. Array a -> a | doc "last element of an array"
      = fun arr => stdarr.elem_at ((stdarr.length arr) - 1) arr,

    set : forall a. Num -> a -> Array a -> Array a | doc "return a new array with the nth element replaced with the given value"
      = fun n val arr => (take n arr) @ [ val ] @ (drop (n + 1) arr),

    singleton : forall a. a -> Array a | doc "create an array with a single element"
      = fun a => [a],

    maxNum : Array Num -> Num
      = fun arr =>
        let len = stdarr.length arr in
        if len == 1 then (stdarr.head arr)
        else if len == 2 then stdnum.max (stdarr.head arr) (stdarr.elem_at 1 arr)
        else maxNum ((stdarr.generate (fun i => stdnum.max (stdarr.elem_at (i * 2) arr) (stdarr.elem_at (i * 2 + 1) arr)) (stdnum.floor (len / 2))) @ (if (len % 2) == 1 then [(stdarr.elem_at (len - 1) arr)] else [])),

    foldl' : forall a. forall a b. (a -> b -> a) -> a -> Array b -> a
      | doc "Identical to the stdlib array.foldl except fast."
      = fun f acc l =>
          if stdarr.length l == 0 then acc else
          let rec out = stdarr.generate (fun i => let v = f (if i == 0 then acc else (stdarr.elem_at (i - 1) out)) (stdarr.elem_at i l) in v) (stdarr.length l) in
          last out,

    flatten' : forall a. Array (Array a) -> Array a
      | doc "array.flatten, but faster."
        = fun l => foldl' (fun acc l => acc @ l) [] l,
  },
  num = {
    cmp : Num -> Num -> [| `Lesser, `Equal, `Greater |] | doc "comparison function for numbers, useful with array.sort"
      = fun l r => if l < r then `Lesser else `Greater
  },
  string = {
    starts_with : Str -> Str -> Bool
      = fun prefix str =>
          if (stdstr.length prefix) > (stdstr.length str) then false
          else (stdstr.substring 0 (stdstr.length prefix) str) == prefix,

    # splitn : Num -> Str -> Str -> Array Str
    splitn
      = fun n sep str => let s1 = stdstr.split sep str in if stdarr.length s1 > n then (array.take (n - 1) s1) @ [(stdstr.join sep (array.drop (n - 1) s1))] else s1,
  },

  record = {
    # Adding the below type causes a type error, even though it seems like it should be right :(
    # filter : forall a. (Str -> a -> Bool) -> {_: a} -> {_: a}
    filter = fun f r =>
      stdarr.foldl (fun out k => let v = r."%{k}" in if f k v then stdrec.insert k v out else out) {} (stdrec.fields r),
  },

  array2 = {
    # Get gets an element in a 2d arr, for example:
    # [ [ 1, 2, 3],
    #   [ 4, 5, 6],
    #   [ 7, 8, 9] ]
    # get 1 2 = 8
    # get 0 0 = 1
    get : forall a. Num -> Num -> Array (Array a) -> a
      = fun x y arr2 => arr2 |> stdarr.elem_at y |> stdarr.elem_at x,

    getDefault = fun x y def arr2 => if x < (width arr2) && y < (height arr2) then get x y arr2 else def,

    width = fun arr2 => stdarr.length (stdarr.head arr2),
    height = fun arr2 => stdarr.length arr2,

    set = fun x y v arr2 => stdarr.generate (fun y' => stdarr.generate (fun x' => if x == x' && y == y' then v else get x' y' arr2) (width arr2)) (height arr2),

    resize = fun w h zero arr2 => stdarr.generate (fun y => stdarr.generate (fun x => getDefault x y zero arr2) w) h,


    # Rotate a 2d arr right. For example:
    # rotateRight [ [1, 2],
    #               [3, 4],
    #               [5, 6] ] =
    #             [ [5, 3, 1],
    #               [6, 4, 2] ]
    # rotateRight : forall a. Array (Array a) -> Array (Array a)
    rotateRight = fun arr2 =>
        let h = stdarr.length arr2 in
        let w = stdarr.length (stdarr.head arr2) in
        stdarr.generate (fun x => stdarr.generate (fun y => array2.get x (h - y - 1) arr2) h) w,

    # Rotate a 2d arr left. For example:
    # rotateLeft  [ [1, 2],
    #               [3, 4],
    #               [5, 6] ] =
    #             [ [2, 4, 6],
    #               [1, 3, 5] ]
    # rotateLeft : forall a. Array (Array a) -> Array (Array a)
    rotateLeft = fun arr2 =>
        let h = stdarr.length arr2 in
        let w = stdarr.length (stdarr.head arr2) in
        stdarr.generate (fun x => stdarr.generate (fun y => array2.get (w - x - 1) y arr2) h) w,
  },

}
