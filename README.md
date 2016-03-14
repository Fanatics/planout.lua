# PlanOut.lua

PlanOut.lua is a Lua-based implementation of [PlanOut](http://facebook.github.io/planout/). It is a complete port of the PlanOut API and language interpreter.

## Installation

PlanOut.lua requires Lua 5.1 and Luarocks.

To install, pull down the repo and run `make install`. This will install PlanOut.lua dependencies via Luarocks.

## Examples

TODO

## Testing

PlanOut.lua tests can be run via the command `make test`, which runs every test.

If you want to run individual test files or tests, you can call them from the tests directory. Use `lua test.lua -v <testfile>` to run tests from a specific test file and `lua test.lua -v <testfile>.<specifictest>` to call a specific test from within that testfile.
