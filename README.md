# Advent of Nickel (2022)

This is my attempt to solve each of the advent of code challenges in nickel for the 2022 advent of code.

## General notes

nickel doesn't have file IO, so each input is checked in as a string const

nickel also is _very slow_, so most of these execute slowly.

nickel's interpreter uses a large amount of memory too.

Every solution checked in completed, on my machine, in under 64GiB of memory, but several of them used quite a bit of that.

Solutions are in `default.ncl` files in their given day. It's often wise to
comment out part1 / part2 and only compute 1 part at a time since sometimes
both parts together take significantly longer or more memory, and I only verified one part at a time completed for me.

## Specific days

Some days have specific notes, see below

### day 10

Part 2 of day 10 requires specific output formatting.

You can achieve this with jq
```
$ nickel export -f day10/default.ncl | jq '.part2' -cr
```

## Closing notes

This was my attempt to solve the advent of code in nickel, and it was a failed attempt.

I did 2021's in nix, and that was already difficult at times due to nix's quite poor performance... But nickel is exponentially worse.

For day 11, part 2, I wrote nickel code to solve it, and based on some
back-of-the-envelope math, it will require more memory than exists on the
planet, and multiple decades, to actually complete. It certainly doesn't complete in 64GiB of ram and 4 hours.

The same solution, when ported to nix line-by-line (surprisingly easy to do! They really are similar languages), executes in 7 seconds and a mere 900MiB of memory.

At this point, I think the only way to make any of the later days execute will
be to start improving the nickel interpreter's performance rather than to
improve my nickel code or stumble upon new algorithmic insights.

I spent some time trying to do just that, but it's not happening anytime too soon.

So, in closing, I'm throwing in the towel early on this one. I'll do the
reamining days [in nix instead](https://github.com/euank/advent-of-nix-2022)
(though those will also be done a bit late, I've got some life-stuff to deal
with first!), and call that good enough.

I _might_ come back to this, either to try and improve nickel's performance
myself and make progress, or when the upstream nickel development progresses
such that these become tractable.

That's all for now. Merry Christmas :)
