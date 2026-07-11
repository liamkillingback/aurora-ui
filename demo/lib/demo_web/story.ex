defmodule DemoWeb.Story do
  @moduledoc """
  The reusable building block for every component-lab page.

  A "story" is one titled example: a live preview panel rendered with real
  Aurora UI components, followed by the exact HEEx that produced it in a
  copyable code block (Aurora's `code_block/1`, with its `AuroraCopyButton`).

  Every family lab page is built from `story/1`, so the whole `/components`
  section stays visually and structurally consistent.

  ## Example

      <.story
        title="Variants"
        description="Six visual priorities, from primary to link."
        code={~S|<.button>Save</.button>
      <.button variant="danger">Delete</.button>|}
      >
        <.button>Save</.button>
        <.button variant="danger">Delete</.button>
      </.story>
  """
  use Phoenix.Component

  import AuroraUI.Components.Media, only: [code_block: 1]

  attr :title, :string, required: true, doc: "the story heading"
  attr :description, :string, default: nil, doc: "one-line context under the title"
  attr :id, :string, default: nil, doc: "stable id; generated from the title when omitted"

  attr :code, :string,
    default: nil,
    doc: "raw HEEx source shown in the copyable code block; omit to hide the code panel"

  attr :language, :string, default: "heex", doc: "code fence language for highlighters"

  attr :preview_class, :string,
    default: nil,
    doc: "extra classes for the preview surface (e.g. layout utilities)"

  attr :rest, :global

  slot :inner_block, required: true, doc: "the live preview"

  @doc """
  Renders a single story: heading, live preview surface, and (optionally) the
  copyable source. See the module doc for the full example.
  """
  def story(assigns) do
    # `attr :id` defaults to nil, so the key is always present and `assign_new`
    # would never fire — derive the id from the title when the caller omits it.
    slug =
      assigns.title
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9]+/, "-")
      |> String.trim("-")

    assigns = assign(assigns, :id, assigns.id || "story-#{slug}")

    ~H"""
    <section id={@id} class="demo-story" {@rest}>
      <header class="demo-story__head">
        <h3 class="demo-story__title">{@title}</h3>
        <p :if={@description} class="demo-story__desc">{@description}</p>
      </header>

      <div class={["demo-story__preview", @preview_class]} data-preview-surface>
        {render_slot(@inner_block)}
      </div>

      <div :if={@code} class="demo-story__code">
        <.code_block code={@code} language={@language} id={"#{@id}-code"} />
      </div>
    </section>
    """
  end
end
