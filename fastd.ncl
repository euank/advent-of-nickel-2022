# Nickel standrd library.
# Except with all contracts deleted because contracts are _incredibly slow_ in practice.
{
  array = {
    first
      | doc m%"
          Returns the first element of an array.

          # Examples

          ```nickel
          std.array.first [ "this is the head", "this is not" ] =>
            "this is the head"
          ```
        "%
      = fun array => %elem_at% array 0,

    last
      | doc m%"
          Returns the last element of an array.

          # Examples

          ```nickel
          std.array.last [ "this is the head", "this is not" ] =>
            "this is not"
          ```
        "%
      = fun array => %elem_at% array (%length% array - 1),

    drop_first
      | doc m%"
          Returns the given array without its first element.

          # Examples

          ```nickel
          std.array.drop_first [ 1, 2, 3 ] =>
            [ 2, 3 ]
          ```
        "%
      = fun array => %array_slice% 1 (%length% array) array,

    drop_last
      | doc m%"
          Returns the given array without its last element.

          # Examples

          ```nickel
          std.array.drop_last [ 1, 2, 3 ] =>
            [ 1, 2 ]
          ```
        "%
      = fun array => %array_slice% 0 (%length% array - 1) array,

    length
      | doc m%"
          Returns the length of an array.

          # Examples

          ```nickel
          std.array.length [ "Hello,", " World!" ] =>
            2
          ```
        "%
      = fun l => %length% l,

    map
      | doc m%"
          Applies a function to every element in the given array. That is,
          `map f [ x1, x2, ..., xn ]` is `[ f x1, f x2, ..., f xn ]`.

          # Examples

          ```nickel
          std.array.map (fun x => x + 1) [ 1, 2, 3 ] =>
            [ 2, 3, 4 ]
          ```
        "%
      = fun f l => %map% l f,

    at
      | doc m%"
          Retrieves the n-th element from an array, with indices starting at 0.

          # Examples

          ```nickel
          std.array.at 3 [ "zero", "one", "two", "three", "four" ] =>
            "three"
          ```
        "%
      = fun n l => %elem_at% l n,

    concat
      | doc m%"
          Appends the second array to the first one.

          # Examples

          ```nickel
            std.array.concat [ 1, 2, 3 ] [ 4, 5, 6 ] =>
              [ 1, 2, 3, 4, 5, 6 ]
          ```
        "%
      = fun l1 l2 => l1 @ l2,

    fold_left
      | doc m%"
          Folds a function over an array. In a functional language like Nickel,
          folds serve a similar purpose to loops or iterators. `fold_left`
          iterates over an array, by repeatedly applying a function to each
          element, threading an additional arbitrary state (the accumulator, of
          type `a` in the signature) through the chain of applications.

          `fold_left f init [x1, x2, ..., xn]` results in `f (... (f (f init x1) x2) ...) xn`.

          This function is strict in the intermediate accumulator.

          # Left vs right

          Folds come in two variants, left and right. How to decide which one to
          use?

          - If the folded function isn't associative (such as subtraction), then
            each variant will give a different result. The choice is dictacted by
            which one you need. For example:

            ```nickel
            std.array.fold_right (-) 0 [1, 2, 3, 4]
             => -2
            std.array.fold_left (-) 0 [1, 2, 3, 4]
             => -10
            ```
          - If the folded function is associative, both `fold_right` and
            `fold_left` return the same result. In that case, **`fold_left` is
            generally preferred**, because it forces the evaluation of the
            intermediate results resulting in less memory consumption and overall
            better performance (outside of pathological cases).
            `fold_left` also iterates from the start of the array, which
            correponds to the usual behavior of loops and iterators in most
            programming languages. There is one case where `fold_right` might be
            preferred, see the next point.
          - If the folded function is associative but _(left) short-circuiting_,
            meaning that it can sometimes determine the result without using the
            right argument, then `fold_right` provides early return. An example is
            the boolean AND operator `&&`: when evaluating `left && right`, if
            `left` is `false`, the whole expression will evaluate to `false`
            without even evaluating `right`. Consider the following expression:

            ```nickel
            std.array.replicate 1000 true
            # gives [false, .. true 1000 times]
            |> std.array.prepend false
            |> std.array.fold_right (&&) [false]
            ```

            Here, `fold_right` will stop at the first element, and the operation
            runs in constant time, given the definition of `fold_right` and the
            lazy evaluation of Nickel. If we had used `fold_left` instead, which
            is closer to a standard iterator, we would have iterated over all of
            the 1000 elements of the array.

          # Examples

          ```nickel
          fold_left (fun acc e => acc + e) 0 [ 1, 2, 3 ] =>
            (((0 + 1) + 2) 3) =>
            6
          ```
        "%
      = fun f acc array =>
        let length = %length% array in
        if length == 0 then
          acc
        else
          let rec go = fun acc n =>
            if n == length then
              acc
            else
              let next_acc =
                %elem_at% array n
                |> f acc
              in
              go next_acc (n + 1)
              |> %seq% next_acc
          in
          go acc 0,

    fold_right
      | doc m%"
          Folds a function over an array. Folds serve a similar purpose to loops or
          iterators in a functional language like Nickel. `fold_right` iterates
          over an array by repeatedly applying a function to each element and
          threading an additional arbitrary state (the accumulator of type `a` in
          the signature) through the chain of applications.

          `fold_right f init [x1, x2, ..., xn]` results in `f x1 (f x2 (... (f xn init) ...))`.

          # Left vs right

          Folds come in two variants, left and right. How to decide which one to
          use? Please refer to the documentation of `fold_left`.

          # Examples

          ```nickel
          std.array.fold_right (fun e acc => acc @ [e]) [] [ 1, 2, 3 ] =>
            ((([] @ [3]) @ [2]) @ [1]) =>
            [ 3, 2, 1 ]
          ```
        "%
      = fun f fst l =>
        let length = %length% l in
        let rec go = fun n =>
          if n == length then
            fst
          else
            go (n + 1)
            |> f (%elem_at% l n)
        in go 0,

    prepend
      | doc m%"
          Builds an array given the first element and the rest of the array.

          # Examples

          ```nickel
          std.array.prepend 1 [ 2, 3 ] =>
            [ 1, 2, 3 ]
          ```
        "%
      = fun x l => [x] @ l,

    append
      | doc m%"
          Builds an array given the last element and the rest of the array.

          # Examples

          ```nickel
          std.array.append 3 [ 1, 2 ] =>
            [ 1, 2, 3 ]
          ```
        "%
      = fun x l => l @ [x],

    reverse
      | doc m%"
          Reverses an array.

          # Examples

          ```nickel
          std.array.reverse [ 1, 2, 3 ] =>
            [ 3, 2, 1 ]
          ```
        "%
      = fun l => fold_left (fun acc e => [e] @ acc) [] l,

    filter
      | doc m%"
          `filter f xs` returns an array containing all elements from `xs` that satisfy `f`.

          # Examples

          ```nickel
          std.array.filter (fun x => x <= 3) [ 4, 3, 2, 5, 1 ] =>
            [ 3, 2, 1 ]
          ```
        "%
      = fun pred l => fold_left (fun acc x => if pred x then acc @ [x] else acc) [] l,

    flatten
      | doc m%"
          Concatenates all elements of an array of arrays.

          # Examples

          ```nickel
          std.array.flatten [[1, 2], [3, 4]] =>
            [1, 2, 3, 4]
          ```
        "%
      = fun l => fold_right (fun l acc => l @ acc) [] l,

    all
      | doc m%"
          Returns `true` if all elements in the given array satisfy the predicate,
          `false` otherwise.

          # Examples

          ```nickel
          std.array.all (fun x => x < 3) [ 1, 2 ] =>
            true
          std.array.all (fun x => x < 3) [ 1, 2, 3 ] =>
            false
          ```
        "%
      = fun pred l => fold_right (fun x acc => if pred x then acc else false) true l,

    any
      | doc m%"
          Returns `true` if at least one element in the given array satisfies
          the predicate, `false` otherwise.

          # Examples

          ```nickel
          std.array.any (fun x => x < 3) [ 1, 2, 3, 4 ] =>
            true
          std.array.any (fun x => x < 3) [ 5, 6, 7, 8 ] =>
            false
          ```
        "%
      = fun pred l => fold_right (fun x acc => if pred x then true else acc) false l,

    # **Warning**: unless you know what you're doing, please don't change the
    # type of `elem` to be polymorphic.
    #
    # `elem` must operate on elements of type `Dyn` only, because `elem` performs
    # equality tests, and those aren't allowed on generic variables (as it
    # breaks parametricity).
    #
    # However, as a current work-around to use equality easily in typed code,
    # `(==)` has type `forall a. a -> a -> Bool`. We could
    # be tempted to assign the type `elem : forall a. a -> Array a -> Bool`, but
    # that would be lying (as `==` is currently lying as well), and more
    # importantly, the contract will fail on any non-trivial call at run-time.
    elem
      | doc m%"
          Returns `true` if the given value appears in the array, `false` otherwise.

          # Examples

          ```nickel
          std.array.elem 3 [ 1, 2, 3, 4, 5 ] =>
            true
          ```
        "%
      = fun elt => any (fun x => x == elt),

    partition
      | doc m%"
          Partitions an array into two new arrays. `right` will contain all
          elements that satisfy the predicate, while `wrong` will contain those
          that do not.

          # Examples

          ```nickel
          std.array.partition (fun x => x < 5) [ 2, 4, 5, 3, 7, 8, 6 ] =>
            { right = [ 2, 4, 3 ], wrong = [ 5, 7, 8, 6 ] }
          ```
        "%
      = fun pred l =>
        let aux = fun acc x =>
          if (pred x) then
            { right = acc.right @ [x], wrong = acc.wrong }
          else
            { right = acc.right, wrong = acc.wrong @ [x] }
        in
        fold_left aux { right = [], wrong = [] } l,

    generate
      | doc m%"
          `generate f n` returns an array of length `n` by applying `f` to the
          integers from `0` to `n-1`. That is, `generate f n` is
          `[ f 0, f 1, ..., f (n - 1)]`

          # Examples

          ```nickel
          std.array.generate (fun x => x * x) 4 =>
            [ 0, 1, 4, 9 ]
          ```
        "%
      = fun f n => %generate% n f,

    sort
      | doc m%"
          Sorts an array based on the provided comparison operator.

          # Examples

          ```nickel
          std.array.sort (fun x y =>
            if x < y then
              'Lesser
            else if (x == y) then
              'Equal
            else
              'Greater)
            [ 4, 5, 1, 2 ]
          => [ 1, 2, 4, 5 ]
          ```
        "%
      #TODO: maybe inline partition to avoid contract checks?
      = fun cmp array =>
        let length = %length% array in
        let first = %elem_at% array 0 in
        let rest = %array_slice% 1 length array in
        let parts = partition (fun x => (cmp x first == 'Lesser)) rest in
        if length <= 1 then
          array
        else
          (sort cmp (parts.right)) @ [first] @ (sort cmp (parts.wrong)),

    flat_map
      | doc m%"
          First `map` the given function over the array and then `flatten` the
          result.

          # Examples

          ```nickel
          std.array.flat_map (fun x => [x, x]) [1, 2, 3]
            => [1, 1, 2, 2, 3, 3]
          ```
        "%
      = fun f xs => map f xs |> flatten,

    intersperse
      | doc m%"
          Intersperses a value between the elements of an array.

          # Examples

          ```nickel
          std.array.intersperse ", " [ "Hello", "wonderful", "world!" ]
            => [ "Hello", ", ", "wonderful", ", ", "world!" ]
          std.array.intersperse ", " [ "Hello" ]
            => [ "Hello" ]
          std.array.intersperse ", " []
            => []
          ```
        "%
      = fun v array =>
        let length = %length% array in
        if length <= 1 then
          array
        else
          let first = %elem_at% array 0 in
          let rest = %array_slice% 1 length array in
          [first] @ (flat_map (fun a => [v, a]) rest),

    slice
      | doc m%"
          `slice start end array` returns the slice of `array` between `start` (included) and
          `end` (excluded).

          # Preconditions

          In `slice start end value`, `start` and `end` must be positive
          integers such that `0 <= start <= end <= std.array.length value`.

          # Examples

          ```nickel
          std.array.slice 1 3 [ 0, 1, 2, 3, 4, 5]
            => [ 1, 2 ]
          std.array.slice 0 3 [ "Hello", "world", "!" ]
            => [ "Hello", "world", "!" ]
          std.array.slice 2 3 [ "Hello", "world", "!" ]
            => [ "!" ]
           ```
        "%
      = fun start end value => %array_slice% start end value,

    split_at
      | doc m%"
          Splits an array in two at a given index and puts all the elements
          to the left of the element at the given index (excluded) in the
          `left` field, and the rest of the array in the `right` field.

          # Preconditions

          In `split_at inded value`, `index` must be a positive integer such
          that `0 <= index <= std.array.length value`.

          # Examples

          ```nickel
          std.array.split_at 2 [ 0, 1, 2, 3, 4, 5]
            => { left = [ 0, 1 ], right = [ 2, 3, 4, 5 ] }
          std.array.split_at 0 [ "Hello", "world", "!" ]
            => { left = [  ], right = [ "Hello", "world", "!" ] }
          std.array.split_at 3 [ "Hello", "world", "!" ]
            => { left = [ "Hello", "world", "!" ], right = [  ] }
          ```
        "%
      = fun index value =>
        {
          left = %array_slice% 0 index value,
          right = %array_slice% index (%length% value) value
        },

    replicate
      | doc m%"
          `replicate n x` creates an array containing `x` exactly `n` times.

          # Preconditions

          `n` must be an integer greater or equal to `0`.

          # Examples

          ```nickel
          std.array.replicate 0 false
            => [ ]
          std.array.replicate 5 "x"
            => [ "x", "x", "x", "x", "x" ]
          ```
        "%
      = fun n x => %generate% n (fun _i => x),

    range_step
      | doc m%"
          `range_step start end step` generates the array of numbers
          `[start, start + step, start + 2*step, ..]` up to the first element
          (excluded) larger than or equal to `end`

          # Preconditions

          In `range_step start end step`, `start` and `end` must satisfy `start
          <= end`. `step` must be strictly greater than `0`.

          # Examples

          ```nickel
          std.array.range_step (-1.5) 2 0.5
           => [ -1.5, -1, -0.5, 0, 0.5, 1, 1.5 ]
          ```
        "%
      = fun start end step =>
        %generate%
          ((end - start) / step |> std.number.floor)
          (fun i => start + i * step),

    range
      | doc m%"
          `range start end` generates the array of numbers
          `[start, start + 1, start + 2, ..]` up to the first element
          (excluded) larger than or equal to `end`.

          `range start end` is equivalent to `range_step start end 1`.

          # Preconditions

          In `range_step start end`, `start` and `end` must satisfy
          `start <= end`.

          # Examples

          ```nickel
          std.array.range 0 5
           => [ 0, 1, 2, 3, 4 ]
          ```
        "%
      = fun start end => range_step start end 1,

    reduce_left
      | doc m%"
          Reduces the elements to a single one, by repeatedly applying a
          reducing operation.

          `reduce_left` associates to the left, that is
          `reduce_left op [x1, x2, ..., xn]` results in `op (... (op (op x1 x2) x3) ...) xn`.

          `reduce_left` is the same as `fold_left`, but uses the first element as
          the initial accumulator.

          # Preconditions

          The provided array must be non-empty.

          # Left vs right

          The rationale to decide between `fold_left` and `fold_right` applies to
          `reduce_left` and `reduce_right` as well. See the documentation of
          `fold_left`.

          # Examples

          ```nickel
          std.array.reduce_left (@) [ [1, 2], [3], [4,5] ]
            => (([1, 2] @ [3]) @ [4,5])
            => [ 1, 2, 4, 5 ]
          std.array.reduce_left (-) [ 1, 2, 3, 4]
            => ((1 - 2) - 3) - 4
            => -8
          ```
        "%
      = fun f array =>
        let first = %elem_at% array 0 in
        let rest = %array_slice% 1 (%length% array) array in
        fold_left f first rest,

    reduce_right
      | doc m%"
          Reduces the elements to a single one, by repeatedly applying a reducing
          operation.

          `reduce_right` associates to the right, that is
          `reduce_right op [x1, x2, ..., xn]` results in
          `op x1 (op x2 (... (op xn-1 xn) ...))`.

          `reduce_right` is the same as `fold_right`, but uses the last element as
          the initial element.

          # Preconditions

          The provided array must be non-empty.

          # Left vs right

          The rationale to decide between `fold_left` and `fold_right` applies to
          `reduce_left` and `reduce_right` as well. See the documentation of
          `fold_left`.

          # Examples

          ```nickel
          std.array.reduce_right (@) [ [1, 2], [3], [4,5] ]
            => [1, 2] @ ([3] @ [4,5])
            => [ 1, 2, 4, 5 ]
          std.array.reduce_right (-) [ 1, 2, 3, 4]
            => 1 - (2 - (3 - 4))
            => -2
          ```
        "%
      = fun f array =>
        let last_index = %length% array - 1 in
        let last = %elem_at% array last_index in
        let rest = %array_slice% 0 last_index array in
        fold_right f last rest,
  },

  function = {
    id
      | doc m%"
        The identity function, that is, `id x` is `x` for any value `x`.

        # Examples

        ```nickel
        std.function.id null
          => null
        (std.function.id (fun x => x + 1)) 0
          => 1
        ```
      "%
      = fun x => x,

    compose
      | doc m%"
        Function composition, from right to left. That is, `compose f g x` is
        `f (g x)`.

        # Examples

        ```nickel
        let f = std.function.compose (fun x => x + 1) (fun x => x / 2)
        in
        f 10
          => (10 / 2) + 1
          => 6
        ```
      "%
      = fun g f x => x |> f |> g,

    flip
      | doc m%%"
        Flips the argument order for a two-argument function.

        # Examples

        ```nickel
        std.function.flip (fun x y => "%{x} %{y}") "world!" "Hello,"
          => "Hello, world!"
        ```
      "%%
      = fun f x y => f y x,

    const
      | doc m%"
        Takes a value and returns the constant function which always returns
        this value. Same as `std.function.first`.

        # Examples

        ```nickel
        let f = std.function.const 5 in
        f 7
          => 5
        ```
      "%
      = fun x y => x,

    first
      | doc m%"
        Always returns the first argument, ignoring the second. Same as
        `std.function.const`.

        # Examples

        ```nickel
        std.function.first 5 7
          => 5
        ```
      "%
      = fun x y => x,

    second
      | doc m%"
        Always returns the second argument, ignoring the first.

        # Examples

        ```nickel
        std.function.second 5 7
          => 7
        ```
      "%
      = fun x y => y,

    pipe
      | doc m%%"
        Applies an array of functions to a value, in order.

        # Examples

        ```nickel
        pipe 2 [ (+) 2, (+) 3 ]
          => 7
        pipe 'World [ std.string.from, fun s => "Hello, %{s}!" ]
          => "Hello, World!"
        ```
      "%%
      = fun x fs => std.array.fold_left (|>) x fs,
  },

  number = {
    is_integer
      | doc m%"
        Checks if the given number is an integer.

        # Examples

        ```nickel
        std.number.is_integer 42 =>
          true
        std.number.is_integer 1.5 =>
          false
        ```
      "%
      = fun x => x % 1 == 0,

    min
      | doc m%"
        Returns the lower of two numbers.

        # Examples

        ```nickel
        std.number.min (-1337) 42 =>
          -1337
        ```
      "%
      = fun x y => if x <= y then x else y,

    max
      | doc m%"
        Returns the higher of two numbers.

        # Examples

        ```nickel
        std.number.max (-1337) 42 =>
          42
        ```
      "%
      = fun x y => if x >= y then x else y,

    floor
      | doc m%"
        Rounds a number down to the next integer.

        # Examples

        ```nickel
        std.number.floor 42.5 =>
          42
        std.number.floor (-42.5) =>
          -43
        ```
      "%
      = fun x =>
        if x >= 0 then
          x - (x % 1)
        else
          x - 1 - (x % 1),

    abs
      | doc m%"
        Returns the absolute value of a number.

        # Examples

        ```nickel
        std.number.abs (-5) =>
          5
        std.number.abs 42 =>
          42
        ```
      "%
      = fun x => if x < 0 then -x else x,

    fract
      | doc m%"
        Returns the fractional part of a number.

        # Examples

        ```nickel
        std.number.fract 13.37 =>
          0.37
        std.number.fract 42 =>
          0
        ```
      "%
      = fun x => x % 1,

    truncate
      | doc m%"
        Truncates a number, rounding it towards 0.

        # Examples

        ```nickel
        std.number.truncate (-13.37) =>
          -13
        std.number.truncate 42.5 =>
          42
        ```
      "%
      = fun x => x - (x % 1),

    pow
      | doc m%"
        `pow x y` returns `x` to the power of `y`.

        # Examples

        ```nickel
        std.number.pow 2 8 =>
          256
        ```

        # Precision

        Nickel numbers are arbitrary precision rationals. If the exponent `y` is
        an integer which fits into a 64-bit signed or unsigned integer (that is, if
        `y` is an integer between `−2^63` and `2^64-1`), the result is computed
        exactly.

        Otherwise, both operands `x` and `y` are converted to the nearest 64 bit
        float (excluding `NaN` and infinity) and the result is computed as a 64 bit
        float. This result is then converted back to a rational. In this case,
        **be aware that both the conversion from rationals to floats, and the
        power operation, might incur rounding errors**.
      "%
      = fun x n => %pow% x n,
  },

  record = {
    map
      | doc m%"
        Maps a function over every field of a record. The function is passed the
        name and value of each field.

        # Examples

        ```nickel
        std.record.map (fun s x => s) { hi = 2 } =>
          { hi = "hi" }
        std.record.map (fun s x => x + 1) { hello = 1, world = 2 } =>
          { hello = 2, world = 3 }
        ```
      "%
      = fun f r => %record_map% r f,

    fields
      | doc m%"
        Returns an array containing the names of all the fields of a record.

        # Examples

        ```nickel
        std.record.fields { one = 1, two = 2 } =>
          [ "one", "two" ]
        ```
      "%
      = fun r => %fields% r,

    values
      | doc m%"
        Returns an array containing the values of all the fields of a record.

        # Examples

        ```nickel
        std.record.values { one = 1, world = "world" }
          [ 1, "world" ]
        ```
      "%
      = fun r => %values% r,

    has_field
      | doc m%"
        Given a string, checks if a record contains a field of that name.

        # Examples

        ```nickel
        std.record.has_field "hello" { one = 1, two = 2 } =>
          false
        std.record.has_field "one" { one = 1, two = 2 } =>
          true
        ```
      "%
      = fun field r => %has_field% field r,

    insert
      | doc m%%"
          Inserts a new field into a record. `insert` doesn't mutate the original
          record but returns a new one instead.

          # Preconditions

          The field must not exist in the initial record, otherwise `insert`
          will fail. If the field might already exist, use `std.record.update`
          instead.

          # Examples

          ```nickel
          std.record.insert "foo" 5 { bar = "bar" }
            => { foo = 5, bar = "bar }
          {}
          |> std.record.insert "file.txt" "data/text"
          |> std.record.insert "length" (10*1000)
            => {"file.txt" = "data/text", "length" = 10000}
          std.record.insert "already_there" 0 {already_there = 1}
            => error
          ```
        "%%
      = fun field content r => %record_insert% field r content,

    remove
      | doc m%"
          Removes a field from a record. `remove` doesn't mutate the original
          record but returns a new one instead.

          # Preconditions

          The field to remove must be present in the record, or `remove` will
          fail.

          # Examples

          ```nickel
          std.record.remove "foo" { foo = "foo", bar = "bar" } =>
            { bar = "bar }
          ```
        "%
      = fun field r => %record_remove% field r,

    update
      | doc m%"
          Updates a field of a record with a new value. `update` doesn't mutate the
          original record but returns a new one instead. If the field to update is absent
          from the given record, `update` adds it.

          # Examples

          ```nickel
          std.record.update "foo" 5 { foo = "foo", bar = "bar" } =>
            { foo = 5, bar = "bar" }
          std.record.update "foo" 5 { bar = "bar" } =>
            { foo = 5, bar = "bar" }
          ```

          # Overriding

          As opposed to overriding a value with the merge operator `&`, `update`
          will only change the specified field and won't automatically update the other
          fields which depend on it:

          ```nickel
          { foo = bar + 1, bar | default = 0 } & { bar = 1 } =>
            { foo = 2, bar = 1 }
          std.record.update "bar" 1 {foo = bar + 1, bar | default = 0 } =>
            { foo = 1, bar = 1 }
          ```
        "%
      = fun field content r =>
        let r =
          if %has_field% field r then
            %record_remove% field r
          else
            r
        in
        %record_insert% field r content,

    map_values
      | doc m%"
        Maps a function over the values of all the fields of a record.
        `map_values f` is the same as `std.record.map (fun _field => f)`.

        # Examples

        ```nickel
        std.record.map_values (fun x => x + 1) { hi = 2 }
          => { hi = 3 }
        std.record.map_values (fun x => x + 1) { hello = 1, world = 2 }
          => { hello = 2, world = 3 }
        ```
      "%
      = fun f => map (fun _field => f),

    to_array
      | doc m%"
        Converts a record to an array of key-value pairs.

        # Examples

        ```nickel
        std.record.to_array { hello = "world", foo = "bar" }
          => [
            { field = "hello", value = "world" },
            { field = "foo", value = "bar" },
          ]
        ```
      "%
      = fun record =>
        record
        |> fields
        |> std.array.map (fun field' => { field = field', value = record."%{field'}" }),

    from_array
      | doc m%"
        Converts an array of key-value pairs into a record. The field names in
        the input array must be distinct.

        # Examples

        ```nickel
        std.record.from_array [
          { field = "hello", value = "world" },
          { field = "foo", value = "bar" }
        ]
          => { hello = "world", foo = "bar" }
        ```
      "%
      = fun bindings =>
        bindings
        |> std.array.fold_left (fun accum { field, value } => %record_insert% "%{field}" accum value) {},

    is_empty
      | doc m%"
        Checks whether a record is empty.

        # Examples

        ```nickel
        std.record.is_empty {}
          => true
        std.record.is_empty { foo = 1 }
          => false
        ```
      "%
      = (==) {},

    merge_all
      | doc m%"
        Merges an array of records.

        # Examples

        ```nickel
        std.record.merge_all [ { foo = 1 }, { bar = 2 } ]
          => { foo = 1, bar = 2 }
        ```
      "%
      = fun rs => (std.array.fold_left (&) {} (rs | Array Dyn)) | { _ : Dyn },

    filter
      | doc m%"
        `filter f r` returns a record containing all fields from `r` for which
        `f` returns true. The function `f` is passed the name and value of each field
        to make a decision.

        # Examples

        ```nickel
        std.record.filter (fun _name x => x % 2 == 0) { even = 2, odd = 3 }
          => { even = 2 }
        ```
      "%
      = fun f record =>
        record
        |> to_array
        |> std.array.filter (fun { field, value } => f field value)
        |> from_array,

    length
      | doc m%"
          Returns the number of fields in a record. This count doesn't include
          fields both marked as optional and without a definition.

          Because of the need to filter empty optional fields, the cost of
          `length` is linear in the size of the record.
        "%
      = fun record =>
        record
        |> fields
        |> std.array.length,
  },

  string = {
    join
      | doc m%"
        Joins an array of strings with a given separator.

        # Examples

        ```nickel
        std.string.join ", " [ "Hello", "World!" ]
          => "Hello, World!"
        std.string.join ";" ["I'm alone"]
          => "I'm alone"
        std.string.join ", " []
          => ""
        ```
      "%
      = fun sep fragments =>
        let length = %length% fragments in
        if length == 0 then
          ""
        else
          let first = %elem_at% fragments 0 in
          let rest =
            %array_slice% 1 length fragments
            |> std.array.fold_left (fun acc s => acc ++ sep ++ s) ""
          in
          first ++ rest,

    split
      | doc m%"
        Splits a string based on a separator string.

        Note that this function never splits up Unicode extended grapheme
        clusters, even in cases where the sought value exists within one.

        # Examples

        ```nickel
        std.string.split "," "1,2,3"
          => [ "1", "2", "3" ]
        std.string.split "." "1,2,3"
          => [ "1,2,3" ]
        ```
      "%
      = fun sep s => %str_split% s sep,

    trim
      | doc m%"
        Trims whitespace from the start and end of a string.

        # Examples

        ```nickel
        std.string.trim " hi  "
          => "hi"
        std.string.trim "1   2   3   "
          => "1   2   3"
        ```
      "%
      = fun s => %str_trim% s,

    characters
      | doc m%"
        Separates a string into its individual Unicode extended grapheme clusters.

        # Examples

        ```nickel
        std.string.characters "Hello"
          => [ "H", "e", "l", "l", "o" ]
        ```
      "%
      = fun s => %str_chars% s,

    uppercase
      | doc m%"
        Returns the uppercase version of a string. Unicode extended grapheme
        clusters without an uppercase version are left untouched.

        # Examples

        ```nickel
        std.string.uppercase "a"
          => "A"
        std.string.uppercase "æ"
          => "Æ"
        std.string.uppercase "hello.world"
          => "HELLO.WORLD"
        ```
      "%
      = fun s => %str_uppercase% s,

    lowercase
      | doc m%"
        Returns the lowercase version of a string. Unicode extended grapheme
        clusters without a lowercase version are left untouched.


        # Examples

        ```nickel
        std.string.lowercase "A"
          => "a"
        std.string.lowercase "Æ"
          => "æ"
        std.string.lowercase "HELLO.WORLD"
          => "hello.world"
        ```
      "%
      = fun s => %str_lowercase% s,

    contains
      | doc m%"
        Checks if the first string is part of the second string.

        Note that this function returns false if the sought string exists entirely inside
        or straddles Unicode extended grapheme clusters.

        # Examples

        ```nickel
        std.string.contains "cde" "abcdef"
          => true
        std.string.contains "" "abcdef"
          => true
        std.string.contains "ghj" "abcdef"
          => false
        ```
      "%
      = fun subs s => %str_contains% s subs,

    replace
      | doc m%"
        `replace sub repl str` replaces every occurrence of `sub` in `str` with `repl`.

        Note that this function will not replace `sub` if it exists within a
        larger unicode extended grapheme cluster.

        # Examples

        ```nickel
        std.string.replace "cd" "   " "abcdef"
          => "ab   ef"
        std.string.replace "" "A" "abcdef"
          => "AaAbAcAdAeAfA"
        ```
      "%
      = fun pattern replace s =>
        %str_replace% s pattern replace,

    replace_regex
      | doc m%"
        `replace_regex regex repl string` replaces every match of `regex` in `string` with `repl`.

        **Note**: this function will only replace matches which start & end
        on the boundary of Unicode extended grapheme clusters. For example,
        `replace_regex "❤️" "_" "👨‍❤️‍💋‍👨"` will return `"👨‍❤️‍💋‍👨"`, since the
        heart codepoint occurs within the larger emoji grapheme cluster.

        # Examples

        ```nickel
        std.string.replace_regex "l+." "j" "Hello!"
          => "Hej!"
        std.string.replace_regex "\\d+" "\"a\" is not" "This 37 is a number."
          "This \"a\" is not a number."
      ```
      "%
      = fun pattern replace s =>
        %str_replace_regex% s pattern replace,

    is_match
      | doc m%"
        `is_match regex string` checks if `string` matches `regex`.

        **Note**: this function only returns `true` when the regex match does
        not begin or end in the middle of a Unicode extended grapheme cluster.
        For example, searching for `"❤️"` within the string `"👨‍❤️‍💋‍👨"` will
        return `false`, as the heart codepoint is contained in the larger
        extended grapheme cluster.

        # Examples

        ```nickel
        std.string.is_match "^\\d+$" "123"
          => true
        std.string.is_match "\\d{4}" "123"
          => false
        ```

        # Performance

        When checking multiple strings against a common regular expression, it
        is advantageous to store a partially applied version of this function. This
        partial evaluation will store a compiled version of the regular expression and
        prevent recompilation at each call site.

        For example, in the following program, the whole call to
        `std.string.is_match "[0-9]*\\.?[0-9]+ x"` is re-evaluated at each invocation of
        `is_number`. The regexp will be compiled 3 times in total:

        ```nickel
        let is_number = fun x =>
          std.string.is_match "[0-9]*\\.?[0-9]+" x
        in
        ["0", "42", "0.5"]
        |> std.array.all is_number
          => true
        ```

        On the other hand, in the version below, the partial application of
        `std.string.is_match "[0-9]*\\.?[0-9]+"` is evaluated once, returning a
        function capturing the compiled regexp. The regexp will only be compiled
        once and for all:

        ```nickel
        let is_number' = std.string.is_match "[0-9]*\\.?[0-9]+" in
        ["0", "42", "0.5"]
        |> std.array.all is_number'
          => true
        ```
      "%
      = fun regex => %str_is_match% regex,

    find
      | doc m%"
        `find regex string` looks for matches of `regexp` in `string`. Returns
        the part of `string` that matched, the index of the first character that
        was part of the match in `string`, and an array of all capture groups if
        there were any.

        If there is no match, `find` returns
        `{matched = "", index = -1, groups = []}`.

        **Note**: this function ignores any match where either the match itself,
        or one of its capture groups, begin or end in the middle of a Unicode
        extended grapheme cluster.

        # Examples

        ```nickel
        std.string.find "^(\\d).*(\\d).*(\\d).*$" "5 apples, 6 pears and 0 grapes"
          => { matched = "5 apples, 6 pears and 0 grapes", index = 0, groups = [ "5", "6", "0" ] }
        std.string.find "3" "01234"
          => { matched = "3", index = 3, groups = [ ] }
        ```

        # Performance

        Note that this function may perform better by sharing its partial
        application between multiple calls, because in this case the underlying
        regular expression will only be compiled once (see the documentation of
        `std.string.is_match` for more details).
      "%
      = fun regex => %str_find% regex,

    length
      | doc m%"
        Returns the length of the string, as measured by the number of Unicode
        [extended grapheme clusters](https://unicode.org/glossary/#extended_grapheme_cluster).

        Generally speaking, this gives the number of "visible" glyphs in the string.

        **Warning**: because `length` works on Unicode grapheme clusters, some
        seemingly intuitive invariants might not hold. In particular, it isn't
        always true that `length (s1 ++ s2)` is equal to
        `length s1 + length s2`.

        # Examples

        ```nickel
        std.string.length "" =>
          => 0
        std.string.length "hi" =>
          => 2
        std.string.length "四字熟語" =>
          => 4
        std.string.length "👨🏾‍❤️‍💋‍👨🏻" =>
          => 1
        ```
      "%
      = fun s => %str_length% s,

    substring
      | doc m%"
        `substring start end str` takes the slice of `str` from `start` (included) to `end` (excluded).

        The index arguments are the indices of Unicode extended grapheme clusters
        rather than codepoints.

        # Preconditions

        In `substring start end str`, `start` and `end` must be positive integers
        such that `0 <= start <= end <= std.array.length value`.

        # Examples

        ```nickel
        std.string.substring 3 5 "abcdef" =>
          "de"
        std.string.substring 3 10 "abcdef" =>
          error
        std.string.substring (-3) 4 "abcdef" =>
          error
        ```
      "%
      = fun start end s => %str_substr% s start end,

    from
      | doc m%"
        Converts a stringable value to its string representation. Same as
        `std.to_string`.

        # Examples

        ```nickel
        std.string.from 42
          => "42"
        std.string.from 'Foo
          => "Foo"
        std.string.from null
          => "null"
        std.string.from {value = 0}
          => error
        ```
      "%
      = fun x => %to_str% x,

    from_number
      | doc m%"
        Converts a number to its string representation.

        # Examples

        ```nickel
        std.string.from_number 42
          => "42"
        ```
      "%
      = from,

    from_enum
      | doc m%"
        Converts an enum variant to its string representation.

        # Examples

        ```nickel
        std.string.from_enum 'MyEnum
          => "MyEnum"
        ```
      "%
      = from,

    from_bool
      | doc m%"
        Converts a boolean value to its string representation.

        # Examples

        ```nickel
        std.string.from_bool true
          => "true"
        ```
      "%
      = from,

    to_number
      | doc m%"
        Converts a string that represents a number to that number.

        # Examples

        ```nickel
        std.string.to_number "123"
          => 123
        ```
      "%
      = fun s => %num_from_str% s,

    to_bool
      | doc m%"
        Converts a representation of a boolean (either `true` or `false`) to that boolean.

        # Examples

        ```nickel
        std.string.to_bool "true"
          => true
        std.string.to_bool "false"
          => false
        ```
      "%
      # because of the contract on the argument, `s` can only be `"true"` or
      # `"false"`
      = fun s => s == "true",

    to_enum
      | doc m%"
        Converts a string to an enum tag.

        # Examples

        ```nickel
        std.string.to_enum "Hello"
          => 'Hello
        std.string.to_enum "hey,there!"
          => '"hey,there!"
        ```
      "%
      = fun s => %enum_from_str% s,
  },

  is_number
    | doc m%"
      Checks if a value is a number.

      # Examples

      ```nickel
      std.is_number 1
        => true
      std.is_number "Hello, World!"
        => false
      ```
    "%
    = fun x => %typeof% x == 'Number,

  is_bool
    | doc m%"
      Checks if a value is a bool.

      # Examples

      ```nickel
      std.is_bool false
        => true
      std.is_bool 42
        => false
      ```
    "%
    = fun x => %typeof% x == 'Bool,

  is_string
    | doc m%"
      Checks if a value is a string.

      # Examples

      ```nickel
      std.is_string true
        => false
      std.is_string "Hello, World!"
        => true
      ```
    "%
    = fun x => %typeof% x == 'String,

  is_enum
    | doc m%"
      Checks if a value is an enum tag.

      # Examples

      ```nickel
      std.is_enum true
        => false
      std.is_enum `false
        => true
      ```
    "%
    = fun x => %typeof% x == 'Enum,

  is_function
    | doc m%"
      Checks if a value is a function.

      # Examples

      ```nickel
      std.is_function (fun x => x)
        => true
      std.is_function 42
        => false
      ```
    "%
    = fun x => %typeof% x == 'Function,

  is_array
    | doc m%"
      Checks if a value is an array.

      # Examples

      ```nickel
      std.is_array [ 1, 2 ]
        => true
      std.is_array 42
        => false
      ```
    "%
    = fun x => %typeof% x == 'Array,

  is_record
    | doc m%"
      Checks if a value is a record.

      # Examples

      ```nickel
      std.is_record [ 1, 2 ]
        => false
      std.is_record { hello = "Hello", world = "World" }
        => true
      ```
    "%
    = fun x => %typeof% x == 'Record,

  typeof
    | doc m%"
      Returns the type of a value.

      # Examples

      ```nickel
      std.typeof [ 1, 2 ]
        => 'Array
      std.typeof (fun x => x)
        => 'Function
      ```
    "%
    = fun x => %typeof% x,

  seq
    | doc m%"
      `seq x y` forces the evaluation of `x`, before returning `y`.

      The evaluation of `x` stops as soon as a so-called weak head normal form
      is reached, which is either:

       - an array
       - a record
       - a function (or a match statement, which is function in disguise)
       - a constant (a number, a boolean, a string literal or an enum tag)
       - a contract label

      Note that `seq` won't evaluate _the content_ of arrays and records
      further. Please see `std.deep_seq` to recursively force the
      evaluation of an expression.

      # Examples

      ```nickel
      std.seq (42 / 0) 37
        => error
      std.seq (42 / 2) 37
        => 37
      std.seq { too_far = 42 / 0 } 37
        => 37
      ```
    "%
    = fun x y => %seq% x y,

  deep_seq
    | doc m%"
      `deep_seq x y` forces a deep evaluation `x`, before returning `y`. Deep
       evaluation means `deep_seq` recursively forces the evaluation of
       the content of records and arrays, as opposed to `std.seq`.

      # Examples

      ```nickel
      std.deep_seq (42 / 0) 37
        => error
      std.deep_seq (42 / 2) 37
        => 37
      std.deep_seq [1+1, { not_too_far = [42 / 0] }] 37
        => error
      ```
    "%
    = fun x y => %deep_seq% x y,

  hash
    | doc m%"
      Hashes the given string with the desired hashing algorithm.

      # Examples

      ```nickel
      std.hash 'Md5 "hunter2"
        => "2ab96390c7dbe3439de74d0c9b0b1767"
      ```
    "%
    = fun type s => %hash% type s,

  serialize
    | doc m%"
      Serializes a value into the desired representation.

      # Examples

      ```nickel
      serialize 'Json { hello = "Hello", world = "World" } =>
        "{
          \"hello\": \"Hello\",
          \"world\": \"World\"
        }"
      ```
    "%
    = fun format x => %serialize% format (%force% x),

  deserialize
    | doc m%"
      Deserializes a string into a Nickel value from the given representation.

      # Examples

      ```nickel
      deserialize 'Json "{ \"hello\": \"Hello\", \"world\": \"World\" }"
        { hello = "Hello", world = "World" }
      ```
    "%
    = fun format x => %deserialize% format x,

  to_string
    | doc m%"
      Converts a stringable value to a string representation. Same as
      `std.string.from`.

      # Examples

      ```nickel
      std.to_string 42 =>
        "42"
      std.to_string 'Foo =>
        "Foo"
      std.to_string null =>
        "null"
      ```
    "%
    = fun x => %to_str% x,

  trace
    | doc m%"
      `std.trace msg x` prints `msg` to standard error, then proceeds with
      the evaluation of `x`.

      # Examples

      ```nickel
      std.trace "Hello, world!" true
        std.trace: Hello, world!
        => true
      ```
    "%
    = fun msg x => %trace% msg x,
}
