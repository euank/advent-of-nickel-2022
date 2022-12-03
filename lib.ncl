# nickel functions that seemed generic enough to be useful outside of a single day
# Some may only be used in a single day, but each one felt at least generic
let
  stdarr = array
in
{
  array = {
    cmpRev : (forall a. (a -> a -> [| `Lesser, `Equal, `Greater |]) -> (a -> a -> [| `Lesser, `Equal, `Greater |]))
      = fun f => fun l r => let orig = f l r in if orig == `Lesser then `Greater else if orig == `Greater then `Lesser else `Equal,

    take : forall a. Num -> Array a -> Array a | doc "take n elements from an array"
       = fun n arr => if n == 0 then [] else [ (stdarr.head arr) ] @ (take (n - 1) (stdarr.tail arr)),

    drop : forall a. Num -> Array a -> Array a | doc "drop n elements from an array"
      = fun n arr => if n == 0 then arr else drop (n - 1) (stdarr.tail arr),

    chunk : forall a. Num -> Array a -> Array (Array a) | doc "chunk an array into arrays of size n"
      = fun n arr => if (stdarr.length arr) <= n then [ arr ] else [(take n arr)] @ (chunk n (drop n arr)),

    sum : forall a. (a -> a -> a) -> Array a -> a | doc "apply a binary operation to an array"
      = fun f arr => stdarr.foldl f (stdarr.head arr) (stdarr.tail arr)
  },
  num = {
    cmp : Num -> Num -> [| `Lesser, `Equal, `Greater |] | doc "comparison function for numbers, useful with array.sort"
      = fun l r => if l < r then `Lesser else `Greater
  }
}
