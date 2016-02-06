defmodule SayMath do
   @moduledoc """
A simple module to print math operations and their result
   """

   @doc "prints the addition of two numbers and their result"
   @spec add(number(), number()) :: atom()
   def add a, b do
     IO.puts "#{a} + #{b} is #{a + b}"
   end
end
