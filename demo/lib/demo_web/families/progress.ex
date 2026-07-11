defmodule DemoWeb.Families.Progress do
  @moduledoc """
  Component-lab stories for the Progress family — `spinner`, `progress`,
  `skeleton`, and the `async_state` wrapper. Follows the
  `DemoWeb.Families.Actions` exemplar.
  """
  use DemoWeb, :html

  @code %{
    spinner: ~S|<.spinner size="sm" label="Loading" />
<.spinner size="md" label="Loading" />
<.spinner size="lg" label="Loading dashboard" />|,
    progress: ~S|<.progress value={24} label="Uploading" show_value />
<.progress value={64} label="Uploading" show_value />
<.progress value={100} label="Uploading" show_value />|,
    progress_indeterminate: ~S|<.progress indeterminate label="Processing" />|,
    skeleton: ~S|<.skeleton width="3rem" height="3rem" shape="circle" />
<.skeleton width="12rem" height="1.25rem" shape="text" />
<.skeleton width="8rem" height="1rem" shape="pill" />
<.skeleton width="100%" height="6rem" shape="rect" />|,
    async_loading: ~S|<.async_state state={:loading}>
  <:loading>
    <.skeleton :for={_ <- 1..3} width="100%" height="2.5rem" />
  </:loading>
  <:empty>No orders yet.</:empty>
  <div>Loaded content</div>
</.async_state>|,
    async_empty: ~S|<.async_state state={:empty}>
  <:loading><.spinner label="Loading orders" /></:loading>
  <:empty>
    <.empty_state title="No orders yet" description="Orders appear here once a customer checks out." />
  </:empty>
  <div>Loaded content</div>
</.async_state>|
  }

  def lab(assigns) do
    assigns = assign(assigns, :code, @code)

    ~H"""
    <div class="demo-stories">
      <.story
        title="Spinner"
        description="An indeterminate busy indicator for short, unmeasurable waits. Sizes: sm, md, lg."
        code={@code.spinner}
      >
        <.spinner size="sm" label="Loading" />
        <.spinner size="md" label="Loading" />
        <.spinner size="lg" label="Loading dashboard" />
      </.story>

      <.story
        title="Progress — determinate"
        description="A real role=progressbar with aria-valuenow and an optional visible percentage."
        code={@code.progress}
      >
        <div style="width:100%;max-width:24rem;display:grid;gap:1rem;">
          <.progress value={24} label="Uploading" show_value />
          <.progress value={64} label="Uploading" show_value />
          <.progress value={100} label="Uploading" show_value />
        </div>
      </.story>

      <.story
        title="Progress — indeterminate"
        description="Drops aria-valuenow and sweeps, so AT announces busy rather than a false number."
        code={@code.progress_indeterminate}
      >
        <div style="width:100%;max-width:24rem;">
          <.progress indeterminate label="Processing" />
        </div>
      </.story>

      <.story
        title="Skeleton"
        description="Layout-reserving placeholders. Give each the size the real content will occupy."
        code={@code.skeleton}
      >
        <div style="width:100%;max-width:24rem;display:flex;flex-direction:column;gap:0.75rem;">
          <div style="display:flex;align-items:center;gap:0.75rem;">
            <.skeleton width="3rem" height="3rem" shape="circle" />
            <.skeleton width="12rem" height="1.25rem" shape="text" />
          </div>
          <.skeleton width="8rem" height="1rem" shape="pill" />
          <.skeleton width="100%" height="6rem" shape="rect" />
        </div>
      </.story>

      <.story
        title="Async state — loading"
        description="Renders the :loading branch; here a stack of skeletons stands in for the data."
        code={@code.async_loading}
      >
        <div style="width:100%;max-width:24rem;">
          <.async_state state={:loading}>
            <:loading>
              <div style="display:grid;gap:0.5rem;">
                <.skeleton :for={_ <- 1..3} width="100%" height="2.5rem" />
              </div>
            </:loading>
            <:empty>No orders yet.</:empty>
            <div>Loaded content</div>
          </.async_state>
        </div>
      </.story>

      <.story
        title="Async state — empty"
        description="Renders the :empty branch once a loaded result has no rows."
        code={@code.async_empty}
      >
        <div style="width:100%;max-width:24rem;">
          <.async_state state={:empty}>
            <:loading><.spinner label="Loading orders" /></:loading>
            <:empty>
              <.empty_state
                title="No orders yet"
                description="Orders appear here once a customer checks out."
              />
            </:empty>
            <div>Loaded content</div>
          </.async_state>
        </div>
      </.story>
    </div>
    """
  end
end
