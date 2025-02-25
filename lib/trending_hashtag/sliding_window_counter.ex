defmodule SlidingWindowCounter do
  @moduledoc """
  A sliding window implementation in Elixir using a queue and a hashmap.
  """

  defstruct size: 0, queue: :queue.new(), map: %{}, current_size: 0

  @doc """
  Creates a new sliding window with the given size.
  """
  def new(size) when size > 0 do
    %SlidingWindowCounter{size: size, queue: :queue.new(), map: %{}, current_size: 0}
  end

  @doc """
  Adds a new element to the window, removing the oldest if necessary.
  """
  def add(%SlidingWindowCounter{size: size, queue: queue, map: map, current_size: current_size} = window, element) do
    {new_queue, new_map, current_size} =
      if current_size >= size do
        {{:value, oldest}, updated_queue} = :queue.out(queue)
        {updated_queue, Map.update(map, oldest, 0, fn count -> count - 1 end), current_size - 1}
      else
        {queue, map, current_size}
      end

    updated_queue = :queue.in(element, new_queue)
    updated_map = Map.update(new_map, element, 1, fn count -> count + 1 end)
    current_size = current_size + 1

    %SlidingWindowCounter{window | queue: updated_queue, map: updated_map, current_size: current_size}
  end

  @doc """
  Retrieves the elements currently in the sliding window.
  """
  def get_elements(%SlidingWindowCounter{map: map, current_size: current_size}) do
    {current_size, map}
  end
end
