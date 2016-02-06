# All About IEx

I'm an Elixir enthusiast and use the language daily.
However, I knew I wasn't quite using IEx to its true potential, so I wanted to dive in a bit futher and log my findings.
We will assume you have Elixir 1.2 installed and are fluent in the basics of the language, but no more than that.

```elixir
$ iex
iex(1)>
```

Now, when we fire up the shell there is nothing immediately mind-boggling or crazy.
But, lets try something:

```elixir
iex(1) h
```

When we type this in and hit enter, along with a LOT of other things, we see:

```
Welcome to Interactive Elixir. You are currently seeing the documentation for
the module IEx.Helpers which provides many helpers to make Elixir's shell more
joyful to work with.
```

Well shoot, that sounds conventient.
Here are some greatest hits of shortcuts we might help ourselves a bit with going on:


```
c     - Compile a given file, or list of files
clear - clear the screen
h     - pass in any module or function, get docs
ls/cd - work as expected
r     - recompile
```

These 5 can take us a long ways.
Let's start off by realizing one REALLY awesome thing about Elixir that I see a surprising amount of people not realize:
If you have a module you are using, there is a 90% chance you can read the docs in your shell.
Let's check out the `IO` module.

```
iex(2) h IO
IO

Functions handling IO.

Many functions in this module expect an IO device as an argument. An IO device
must be a pid or an atom representing a process. For convenience, Elixir
provides :stdio and :stderr as shortcuts to Erlang's :standard_io and
:standard_error.

The majority of the functions expect char data, i.e. strings or lists of
characters and strings. In case another type is given, functions will convert
to string via the String.Chars protocol (as shown in typespecs).

The functions starting with bin* expect iodata as an argument, i.e. binaries or
lists of bytes and binaries.

IO devices

An IO device may be an atom or a pid. In case it is an atom, the atom must be
the name of a registered process. In addition, Elixir provides two shorcuts:

• :stdio - a shortcut for :standard_io, which maps to the current
Process.group_leader/0 in Erlang
• :stderr - a shortcut for the named process :standard_error provided in
Erlang

IO devices maintain their position, that means subsequent calls to any reading
or writing functions will start from the place when the device was last
accessed. Position of files can be changed using the :file.position/2 function.
```

Wow, that gives us quite a bit for such a simple setup.
What about individual functions?

```
iex(3) h IO.puts
                def puts(device \\ group_leader(), item)

Writes the argument to the device, similar to write/2, but adds a newline at
the end. The argument is expected to be a chardata.
```

Boom, with this, we can effectively not ever really need to leave our shell if things are written well under the hood with whatever dependencies we use.

We even have autocomplete if were not totally sure what we want to use.
If we type this, and then hit tab, you will see the output

```
iex(4)> Enum.

EmptyError           OutOfBoundsError     all?/2
any?/2               at/3                 chunk/2
chunk/4              chunk_by/2           concat/1
concat/2             count/1              count/2
dedup/1              dedup_by/2           drop/2
drop_while/2         each/2               empty?/1
fetch!/2             fetch/2              filter/2
filter_map/3         find/3               find_index/2
find_value/3         flat_map/2           flat_map_reduce/3
group_by/3           intersperse/2        into/2
into/3               join/2               map/2
map_join/3           map_reduce/3         max/1
max_by/2             member?/2            min/1
min_by/2             min_max/1            min_max_by/2
partition/2          random/1             reduce/2
reduce/3             reduce_while/3       reject/2
reverse/1            reverse/2            reverse_slice/3
scan/2               scan/3               shuffle/1
slice/2              slice/3              sort/1
sort/2               sort_by/3            split/2
split_while/2        sum/1                take/2
take_every/2         take_random/2        take_while/2
to_list/1            uniq/1               uniq_by/2
unzip/1              with_index/2         zip/2
```

Wow, now we can know all the functions inside this library.
Let's check out what `intersperse` does, that sounds cool.

```
iex(5)> h Enum.intersperse
            def intersperse(enumerable, element)

Intersperses element between each element of the enumeration.

Complexity: O(n).

Examples

┃ iex> Enum.intersperse([1, 2, 3], 0)
┃ [1, 0, 2, 0, 3]
┃
┃ iex> Enum.intersperse([1], 0)
┃ [1]
┃
```

So, with anything we have access to, we can just pull up docs...thats pretty amazing to a lot of people who arent from the world of Java and other languages in which this is the norm.

Let's actually make a little module and do some stuff so we can use our newfound toys.

```
iex(6)> defmodule SayMath do
iex(6)> defmodule SayMath do
...(6)>   def add(a, b) do
...(6)>     IO.puts "#{a} + #{b} is #{a + b}"
...(6)>   end
...(6)> end
{:module, SayMath,
 <<70, 79, 82, 49, 0, 0, 6, 164, 66, 69, 65, 77, 69, 120, 68, 99, 0, 0, 0, 157, 131, 104, 2, 100, 0, 14, 101, 108, 105, 120, 105, 114, 95, 100, 111, 99, 115, 95, 118, 49, 108, 0, 0, 0, 4, 104, 2, ...>>,
  {:add, 2}}
iex(7)>SayMath.add 1, 2
1 + 2 is 3
:ok
iex(8)> h SayMath.add
SayMath was not compiled with docs
```

Oh, shit, we don't magically just get these docs for free.
It turns out we have to make them outselves.
Let's open a file called `say_math.ex`

```elixir
defmodule SayMath do
   @moduledoc """
A simple module to print math operations and their result
   """

   @doc "Prints the sentence stating what two numbers being added are and their result"
   def add a, b do
     IO.puts "#{a} + #{b} is #{a + b}"
   end
 end
```

As you can see we are using the module attributes `@doc` and `@moduledoc` here.
What `@doc` does is document individual functions, while `@moduledoc` is for an entire module.
It is worth noting how `@moduledoc` uses a full block inside triple quotes, while function docs tyically are a single line.

While we are at it, let's revise our function to have some type guards.

```elixir
..
   @doc "prints the addition of two numbers and their result"
   @spec add(number(), number()) :: atom()
   def add a, b do
     IO.puts "#{a} + #{b} is #{a + b}"
   end
..
```

Now, when we utilize `@spec`, we have a simple pattern.
First, we say what the spec is for, in this case, the function `add`:

`@spec add( )`

Next, inside the name of the function we give a type for what each argument will be, in this case two numbers.

`@spec add(number(), number())`

And finally we declare what we return:

`@spec add(number(), number()) :: atom()`

The `::` denotes the separation to now stating what you return.
If you come from a language like Ruby or Python this might seem a bit foreign, but it is quite convenient and combined with pattern matching can do some very powerful things.
Check out the docs on typeguards for more on the matter.

Now, lets go back to IEx.

```
$ iex


iex(1)> ls
.git           .gitignore     LICENSE        README.md      src
iex(2)> cd "src"
/Users/bobdawg/all_about_iex/src
iex(3)> c "say_math.ex"
[SayMath]
iex(4)> SayMath.add 1, 2
1 + 2 is 3
:ok
iex(5)> h SayMath
                    SayMath

A simple module to print math operations and their result

iex(6)> h SayMath.add

                  def add(a, b)

prints the addition of two numbers and their result

iex(7) SayMath.add("a", 2)
iex(7)> SayMath.add "a", 2
** (ArithmeticError) bad argument in arithmetic expression
```

And now we have docs!
However, note that we had to compile our file.
This is because it is an `.ex` file rather than an executable script, or `.exs`.
If we change it up a bit, we can access it the same way with a different approach:

```
$ cp src/say_math.ex src/say_math.exs
```

And now, we simply add one line to the bottom of our new file:

```
$ vi say_math.exs

...
require IEx; IEx.pry
```

and we can run it now and have the same toys with:

```
$ iex -S mix run src/say_math.exs
# and we can use it as we please
```

Note however, that since `.exs` files are not compiled in the same way, you can not get the docs even though we wrote them in, since that happens at compile-time.

So now we have successfully scripted a bit, compiled files, moved around a directory, generated and written documentation, and also got an introduction to typeguards and some other neat elixir features.

We can also configure and customize our environment when it comes to IEx.

### Coming soon...
