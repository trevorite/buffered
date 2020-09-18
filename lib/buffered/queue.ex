defmodule Buffered.Queue do
  @behaviour :gen_statem

  defmodule Buffer do
    defstruct items: [], filled: 0, size: 0, timeout: 0, flush: nil
  end

  # Interface
  def start_link(size, timeout, flush, opts \\ []) do
    :gen_statem.start_link(
      __MODULE__,
      %Buffer{size: size, timeout: timeout, flush: flush},
      opts
    )
  end

  def enqueue(pid, new_items) do
    :gen_statem.call(pid, {:enqueue, new_items})
  end

  def flush(pid) do
    :gen_statem.call(pid, :flush)
  end

  # Callbacks
  def callback_mode() do
    [:handle_event_function, :state_enter]
  end

  def init(data) do
    {:ok, :empty, data}
  end

  # State callbacks
  def handle_event({:call, from}, {:enqueue, []}, _state, _buffer) do
    # Ignore void enqueue
    {:keep_state_and_data, [{:reply, from, :ok}]}
  end

  def handle_event({:call, from}, {:enqueue, new_items}, _, %Buffer{} = buffer) do
    {next_state, new_buffer, flush_list} =
      buffer
      |> __enqueue(new_items)

    flush_list |> Enum.each(buffer.flush)
    {:next_state, next_state, new_buffer, {:reply, from, :ok}}
  end

  def handle_event({:call, from}, :flush, _, %Buffer{} = buffer) do
    __flush(buffer) |> Tuple.append({:reply, from, :ok})
  end

  def handle_event(:enter, :empty, :buffering, %Buffer{timeout: timeout}) do
    {:keep_state_and_data, {:state_timeout, timeout, :flush}}
  end

  def handle_event(:enter, :buffering, :empty, _) do
    :keep_state_and_data
  end

  def handle_event(:state_timeout, :flush, :buffering, %Buffer{} = buffer) do
    __flush(buffer)
  end

  # Private
  defp __enqueue(%Buffer{} = buffer, new_items) when is_list(new_items) do
    new_buffer_filled = length(new_items) + buffer.filled

    if new_buffer_filled >= buffer.size do
      {:empty, %Buffer{buffer | items: [], filled: 0},
       (buffer.items ++ new_items) |> Enum.chunk_every(buffer.size)}
    else
      {:buffering, %Buffer{buffer | items: buffer.items ++ new_items, filled: new_buffer_filled},
       []}
    end
  end

  defp __flush(%Buffer{} = buffer) do
    buffer.items
    |> Enum.chunk_every(buffer.size)
    |> Enum.each(buffer.flush)

    {:next_state, :empty, %Buffer{buffer | items: [], filled: 0}}
  end
end