defmodule Demo.Newsletter do
  @moduledoc """
  The opt-in newsletter store for the docs demo — an **in-memory** list, never a
  real provider call and never part of the shipped `aurora_ui` library.

  This backs the ethical, opt-in funnel described in
  [`docs/privacy.md`](../../../docs/privacy.md) and phase-09 evidence:

    * **Explicit opt-in.** `subscribe/1` only stores an address the visitor typed
      and consented to. Nothing is captured from component usage.
    * **Minimal storage.** Exactly `{email, consent_at, source}` per lead —
      the consent timestamp is the provable consent proof, the source tag is the
      page that referred them. No names, no tracking identifiers.
    * **Double opt-in is messaging, not delivery.** Because there is no provider,
      `subscribe/1` records the pending lead; the UI tells the visitor a
      confirmation link would be sent. Re-subscribing refreshes the pending lead
      rather than duplicating it.
    * **Suppression.** `unsubscribe/1` marks the address opted-out and a later
      `subscribe/1` will not silently re-add a suppressed address.

  State lives in a single `Agent` started in the demo's supervision tree, so the
  list is shared across LiveView processes for the life of the node. `reset/0`
  clears it — handy for the example app's deterministic "reset" button.
  """
  use Agent

  @type source :: String.t()
  @type subscriber :: %{email: String.t(), consent_at: DateTime.t(), source: source()}

  # A pragmatic address check: one @, a dotted domain, no spaces. Good enough for
  # an in-memory demo; a real provider would send the confirmation email that is
  # the actual proof the address exists.
  @email_re ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/

  def start_link(_opts) do
    Agent.start_link(fn -> %{subscribers: %{}, suppressed: MapSet.new()} end, name: __MODULE__)
  end

  @doc """
  Validate and store an opt-in lead.

  Accepts a map with `:email` and (optionally) `:source`, or a bare email string.
  Returns:

    * `{:ok, subscriber}` — stored (or refreshed) as a pending, consented lead.
    * `{:error, :invalid_email}` — the address did not look like an email.
    * `{:error, :suppressed}` — the address previously unsubscribed; it is not
      silently re-added.

  ## Examples

      iex> Demo.Newsletter.subscribe(%{email: "ada@aurora.dev", source: "subscribe"})
      {:ok, %{email: "ada@aurora.dev", source: "subscribe", consent_at: _}}
  """
  @spec subscribe(map() | String.t()) :: {:ok, subscriber()} | {:error, atom()}
  def subscribe(email) when is_binary(email), do: subscribe(%{email: email})

  def subscribe(%{} = attrs) do
    email = attrs |> Map.get(:email, "") |> to_string() |> String.trim() |> String.downcase()
    source = attrs |> Map.get(:source, "unknown") |> to_string()

    cond do
      not valid_email?(email) ->
        {:error, :invalid_email}

      suppressed?(email) ->
        {:error, :suppressed}

      true ->
        subscriber = %{email: email, consent_at: DateTime.utc_now(), source: source}

        Agent.update(__MODULE__, fn state ->
          put_in(state.subscribers[email], subscriber)
        end)

        {:ok, subscriber}
    end
  end

  @doc "One-click unsubscribe: removes the lead and records it as suppressed."
  @spec unsubscribe(String.t()) :: :ok
  def unsubscribe(email) do
    key = email |> to_string() |> String.trim() |> String.downcase()

    Agent.update(__MODULE__, fn state ->
      %{
        state
        | subscribers: Map.delete(state.subscribers, key),
          suppressed: MapSet.put(state.suppressed, key)
      }
    end)
  end

  @doc "Whether an address is currently subscribed (pending confirmation)."
  @spec subscribed?(String.t()) :: boolean()
  def subscribed?(email) do
    key = email |> to_string() |> String.trim() |> String.downcase()
    Agent.get(__MODULE__, &Map.has_key?(&1.subscribers, key))
  end

  @doc "Whether an address previously unsubscribed and is suppressed."
  @spec suppressed?(String.t()) :: boolean()
  def suppressed?(email) do
    key = email |> to_string() |> String.trim() |> String.downcase()
    Agent.get(__MODULE__, &MapSet.member?(&1.suppressed, key))
  end

  @doc "All current leads, newest consent first."
  @spec list() :: [subscriber()]
  def list do
    Agent.get(__MODULE__, fn state -> Map.values(state.subscribers) end)
    |> Enum.sort_by(& &1.consent_at, {:desc, DateTime})
  end

  @doc "How many leads are currently stored."
  @spec count() :: non_neg_integer()
  def count, do: Agent.get(__MODULE__, &map_size(&1.subscribers))

  @doc "Clear all leads and suppressions (demo/reset only)."
  @spec reset() :: :ok
  def reset,
    do: Agent.update(__MODULE__, fn _ -> %{subscribers: %{}, suppressed: MapSet.new()} end)

  @doc "Whether a string looks like a valid email address."
  @spec valid_email?(String.t()) :: boolean()
  def valid_email?(email) when is_binary(email), do: Regex.match?(@email_re, String.trim(email))
  def valid_email?(_), do: false
end
