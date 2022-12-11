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
