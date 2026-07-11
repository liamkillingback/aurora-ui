defmodule AuroraUI.Internal do
  @moduledoc false
  # Internal helpers shared by component families. Not part of the public API;
  # signatures here may change without a deprecation window.

  @doc """
  Joins class fragments into a single space-separated string.

  Accepts strings, lists (nested, arbitrarily deep), and `{class, enabled?}`
  tuples so variant maps can be expressed declaratively. `nil`, `false`, and
  empty strings are dropped. Order is preserved; later classes are expected to
  win via Tailwind/source order, so caller-supplied classes come last.
  """
  @spec cx(term()) :: String.t()
  def cx(input) do
    input
    |> flatten_classes()
    |> Enum.join(" ")
  end

  defp flatten_classes(list) when is_list(list),
    do: Enum.flat_map(list, &flatten_classes/1)

  defp flatten_classes({class, true}), do: flatten_classes(class)
  defp flatten_classes({_class, _falsy}), do: []
  defp flatten_classes(nil), do: []
  defp flatten_classes(false), do: []
  defp flatten_classes(""), do: []

  defp flatten_classes(string) when is_binary(string) do
    case String.trim(string) do
      "" -> []
      trimmed -> [trimmed]
    end
  end

  @doc """
  Resolves a value against a map of allowed variants, raising a clear compile-
  friendly error when a component is handed an unsupported value. Keeps the
  finite-variant APIs honest instead of silently rendering nothing.
  """
  @spec variant(map(), term(), term()) :: term()
  def variant(mapping, key, _default) when is_map_key(mapping, key),
    do: Map.fetch!(mapping, key)

  def variant(mapping, key, default) do
    raise ArgumentError,
          "unknown variant #{inspect(key)}; expected one of #{inspect(Map.keys(mapping))}. " <>
            "Falling back to #{inspect(default)} would hide the bug."
  end

  @doc """
  Generates a deterministic id from a base and an optional suffix. Deterministic
  ids keep hook targets and ARIA relationships stable across LiveView patches.
  """
  @spec id(String.t() | nil, String.t()) :: String.t()
  def id(nil, suffix), do: "aui-" <> suffix <> "-" <> rand()
  def id(base, suffix), do: base <> "-" <> suffix

  defp rand, do: 8 |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)
end
