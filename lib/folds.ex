defmodule Folds do
  def foldr(_, v, []), do: v
  def foldr(f, v, [x|xs]) do
    f.(x, foldr(f, v, xs))
  end

  def foldl(_, v, []), do: v
  def foldl(f, v, [x|xs]) do
    foldl(f, f.(v, x), xs)
  end

  def mapr(list, f) do
    mapper = fn item, rest -> [f.(item)|rest] end
    foldr(mapper, [], list)
  end

  # double = fn n -> n*2 end
  # e.g. mapr([1,2,3], &double/1)
  # => foldr(mapper, [], [1,2,3])
  # => mapper.(1, foldr(mapper, [], [2,3]))
  # => mapper.(1, mapper.(2, foldr(mapper, [], [3])))
  # => mapper.(1, mapper.(2, mapper.(3, foldr(mapper, [], []))))
  # => mapper.(1, mapper.(2, mapper.(3, [])))
  # => mapper.(1, mapper.(2, [double(3)|[]]))
  # => mapper.(1, mapper.(2, [6|[]]))
  # => mapper.(1, mapper.(2, [6]))
  # => mapper.(1, [double(2)|[6]])
  # => mapper.(1, [4|[6]])
  # => mapper.(1, [4,6])
  # => [double(1)|[4,6]]
  # => [2|[4,6]]
  # => [2,4,6]

  def mapl(list, f) do
    mapper = fn list, item -> list ++ [f.(item)] end
    foldl(mapper, [], list)
  end

  def maplr(list, f) do
    mapper = fn list, item -> [f.(item)|list] end
    foldl(mapper, [], list) |> Enum.reverse
  end

  # double = fn n -> n*2 end
  # e.g. mapl([1,2,3], &double/1)
  # => foldl(mapper, [], [1,2,3])
  # => foldl(mapper, mapper.([], 1), [2,3])
  # => foldl(mapper, [] ++ [double(1)], [2,3])
  # => foldl(mapper, [] ++ [2], [2,3])
  # => foldl(mapper, [2], [2,3])
  # => foldl(mapper, mapper.([2], 2), [3])
  # => foldl(mapper, [2] ++ [double(2)], [3])
  # => foldl(mapper, [2] ++ [4], [3])
  # => foldl(mapper, [2,4], [3])
  # => foldl(mapper, mapper.([4,2], 3), [])
  # => foldl(mapper, [2,4] ++ [double(3)], [])
  # => foldl(mapper, [2,4] ++ [6], [])
  # => foldl(mapper, [2,4,6], [])
  # => [2,4,6]

  # Notice that folding to the left requires a different mapping operation. In
  # fact it is a slower implementation, because pushing items onto the top of
  # the list (to the right) is a faster operation than concatenation (to the
  # left).

  # Let's call >> the binary operator that maps to a value's double. In that
  # case the expanded right fold would look like:
  # (1 >> (2 >> (3 >> [])))
  # (1 >> (2 >> [6|[]])))
  # (1 >> (2 >> [6]))
  # (1 >> [4|[6]])
  # (1 >> [4,6])
  # [2|[4,6]]
  # [2,4,6]

  # The left fold would look like:
  # ((([] >> 1) >> 2) >> 3)
  # (([] ++ [2] >> 2) >> 3)
  # ([2] ++ [4] >> 3)
  # ([2,4] >> 3)
  # [2,4] ++ [3]
  # [2,4,6]

  # The benchmark is really interesting...
  # ● master ~/Code/OSS/folding_elixir » mix bench
  #Settings:
  #  duration:      1.0 s

  #  ## MapBench
  #  [18:46:43] 1/2: mapping via foldr
  #  [18:46:47] 2/2: mapping via foldl

  #  Finished in 5.64 seconds

  #  ## MapBench
  #  mapping via foldr        5000   651.73 µs/op
  #  mapping via foldl           5   275805.00 µs/op

  # This tells us that in 1 second, the foldr version was able to run 5000
  # times, while the foldl version old ran 5 times. Also the time spent per
  # iteration is massively different.
end
