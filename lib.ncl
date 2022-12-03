# nickel functions that seemed generic enough to be useful outside of a single day
# Some may only be used in a single day, but each one felt at least generic
{
  array = {
    cmpRev : (forall a. (a -> a -> [| `Lesser, `Equal, `Greater |]) -> (a -> a -> [| `Lesser, `Equal, `Greater |]))
      = fun f => fun l r => let orig = f l r in if orig == `Lesser then `Greater else if orig == `Greater then `Lesser else `Equal,
  },
  num = {
    cmp : Num -> Num -> [| `Lesser, `Equal, `Greater |] | doc "comparison function for numbers, useful with array.sort"
      = fun l r => if l < r then `Lesser else `Greater
  }
}
