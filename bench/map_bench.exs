defmodule MapBench do
  use Benchfella

  @list Enum.to_list(1..10_000)

  bench "mapping via foldr" do
    Folds.mapr(@list, &(&1*2))
  end

  bench "mapping via foldl" do
    Folds.mapl(@list, &(&1*2))
  end

  bench "mapping via foldl and reversing" do
    Folds.maplr(@list, &(&1*2))
  end
end
