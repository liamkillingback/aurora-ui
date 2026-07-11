defmodule DemoWeb.Families.DataDisplay do
  @moduledoc """
  Component-lab stories for the DataDisplay family — card, badge, avatar (+
  group), stat, and description list. Follows the `DemoWeb.Families.Actions`
  exemplar: a `@code` map of copyable HEEx and a `lab/1` render returning a
  `<div class="demo-stories">` of `<.story>` blocks.
  """
  use DemoWeb, :html

  alias Demo.Sample

  @code %{
    card: ~S|<.card>
  <:header><h3>Weekly report</h3></:header>
  <:body>All systems nominal. 42 deploys shipped this week with zero rollbacks.</:body>
  <:footer><.button variant="secondary" size="sm">View details</.button></:footer>
</.card>|,
    card_elevations: ~S|<.card elevation="flat"><:body>Flat</:body></.card>
<.card elevation="sm"><:body>Small</:body></.card>
<.card elevation="md"><:body>Medium</:body></.card>|,
    card_interactive:
      ~S|<.card interactive navigate={~p"/components/data-display"} link_label="Open Aurora Web">
  <:header><h3>Aurora Web</h3></:header>
  <:body>The whole card is one link — no nested interactive controls.</:body>
</.card>
<.card interactive selected navigate={~p"/components/data-display"} link_label="Open Nebula API">
  <:header><h3>Nebula API</h3></:header>
  <:body>Selected marks the current card with aria-current.</:body>
</.card>|,
    badge_variants: ~S|<.badge variant="neutral">Neutral</.badge>
<.badge variant="info">Info</.badge>
<.badge variant="success">Success</.badge>
<.badge variant="warning">Warning</.badge>
<.badge variant="danger">Danger</.badge>
<.badge variant="accent">Accent</.badge>|,
    badge_dot: ~S|<.badge variant="success" dot>Live</.badge>
<.badge variant="warning" dot>Degraded</.badge>
<.badge variant="danger" dot>Down</.badge>|,
    badge_removable:
      ~S|<.badge removable on_remove={JS.push("drop", value: %{id: 1})}>Design</.badge>
<.badge variant="info" removable on_remove={JS.push("drop", value: %{id: 2})}>Engineering</.badge>|,
    avatar: ~S|<.avatar src="https://i.pravatar.cc/80?img=5" alt="Ada Lovelace" />
<.avatar name="Grace Hopper" />
<.avatar name="Alan Turing" shape="square" />|,
    avatar_sizes: ~S|<.avatar name="Ada Lovelace" size="sm" />
<.avatar name="Ada Lovelace" size="md" />
<.avatar name="Ada Lovelace" size="lg" />|,
    avatar_status: ~S|<.avatar name="Ada Lovelace" status="online" />
<.avatar name="Grace Hopper" status="away" />
<.avatar name="Alan Turing" status="busy" />
<.avatar name="Katherine Johnson" status="offline" />|,
    avatar_group: ~S|<.avatar_group label="Project members">
  <.avatar name="Ada Lovelace" />
  <.avatar name="Grace Hopper" />
  <.avatar name="Alan Turing" />
  <span class="aui-avatar-group__overflow" aria-hidden="true">+2</span>
</.avatar_group>|,
    stat:
      ~S|<.stat label="Active users" value="12,480" delta="8.2%" trend="up" description="vs. last week" />
<.stat label="Requests / min" value="1,204" delta="3.1%" trend="down" description="vs. last week" />
<.stat label="Error rate" value="0.04%" delta="0.0%" trend="flat" description="within budget" />|,
    description_list: ~S|<.description_list>
  <:item term="Plan">Pro</:item>
  <:item term="Owner">Ada Lovelace</:item>
  <:item term="Renews">March 1, 2026</:item>
  <:item term="Seats">12 of 20 used</:item>
</.description_list>|
  }

  def lab(assigns) do
    assigns =
      assigns
      |> assign(:code, @code)
      |> assign(:stats, Sample.stats())

    ~H"""
    <div class="demo-stories">
      <.story
        title="Card"
        description="An <article> surface with header, body, and footer slots."
        code={@code.card}
      >
        <div style="width:100%;max-width:22rem;">
          <.card>
            <:header>
              <h3>Weekly report</h3>
            </:header>
            <:body>All systems nominal. 42 deploys shipped this week with zero rollbacks.</:body>
            <:footer><.button variant="secondary" size="sm">View details</.button></:footer>
          </.card>
        </div>
      </.story>

      <.story
        title="Card elevations"
        description="Resting shadow depth: flat, sm (default), and md."
        code={@code.card_elevations}
      >
        <.card elevation="flat">
          <:body>Flat</:body>
        </.card>
        <.card elevation="sm">
          <:body>Small</:body>
        </.card>
        <.card elevation="md">
          <:body>Medium</:body>
        </.card>
      </.story>

      <.story
        title="Interactive card"
        description="The entire card is one stretched link. Selected marks the current card."
        code={@code.card_interactive}
      >
        <.card interactive navigate={~p"/components/data-display"} link_label="Open Aurora Web">
          <:header>
            <h3>Aurora Web</h3>
          </:header>
          <:body>The whole card is one link — no nested interactive controls.</:body>
        </.card>
        <.card
          interactive
          selected
          navigate={~p"/components/data-display"}
          link_label="Open Nebula API"
        >
          <:header>
            <h3>Nebula API</h3>
          </:header>
          <:body>Selected marks the current card with aria-current.</:body>
        </.card>
      </.story>

      <.story
        title="Badge variants"
        description="Six semantic pills. Pick by meaning, not by color alone."
        code={@code.badge_variants}
      >
        <.badge variant="neutral">Neutral</.badge>
        <.badge variant="info">Info</.badge>
        <.badge variant="success">Success</.badge>
        <.badge variant="warning">Warning</.badge>
        <.badge variant="danger">Danger</.badge>
        <.badge variant="accent">Accent</.badge>
      </.story>

      <.story
        title="Badge with status dot"
        description="A leading dot reinforces state for at-a-glance scanning."
        code={@code.badge_dot}
      >
        <.badge variant="success" dot>Live</.badge>
        <.badge variant="warning" dot>Degraded</.badge>
        <.badge variant="danger" dot>Down</.badge>
      </.story>

      <.story
        title="Removable badges"
        description="The remove control is a real, labelled button — wire it with on_remove."
        code={@code.badge_removable}
      >
        <.badge removable on_remove={JS.push("drop", value: %{id: 1})}>Design</.badge>
        <.badge variant="info" removable on_remove={JS.push("drop", value: %{id: 2})}>
          Engineering
        </.badge>
      </.story>

      <.story
        title="Avatar"
        description="An <img> with required alt, or an initials fallback derived from the name."
        code={@code.avatar}
      >
        <.avatar src="https://i.pravatar.cc/80?img=5" alt="Ada Lovelace" />
        <.avatar name="Grace Hopper" />
        <.avatar name="Alan Turing" shape="square" />
      </.story>

      <.story title="Avatar sizes" description="sm, md (default), and lg." code={@code.avatar_sizes}>
        <.avatar name="Ada Lovelace" size="sm" />
        <.avatar name="Ada Lovelace" size="md" />
        <.avatar name="Ada Lovelace" size="lg" />
      </.story>

      <.story
        title="Avatar status"
        description="A status ring, dot, and visually-hidden status text — never color alone."
        code={@code.avatar_status}
      >
        <.avatar name="Ada Lovelace" status="online" />
        <.avatar name="Grace Hopper" status="away" />
        <.avatar name="Alan Turing" status="busy" />
        <.avatar name="Katherine Johnson" status="offline" />
      </.story>

      <.story
        title="Avatar group"
        description="Overlapping cluster with an accessible name and a +N overflow pill."
        code={@code.avatar_group}
      >
        <.avatar_group label="Project members">
          <.avatar name="Ada Lovelace" />
          <.avatar name="Grace Hopper" />
          <.avatar name="Alan Turing" />
          <span class="aui-avatar-group__overflow" aria-hidden="true">+2</span>
        </.avatar_group>
      </.story>

      <.story
        title="Stat"
        description="A KPI with a delta whose direction is stated in hidden text and a caret."
        code={@code.stat}
      >
        <.stat
          label="Active users"
          value="12,480"
          delta="8.2%"
          trend="up"
          description="vs. last week"
        />
        <.stat
          label="Requests / min"
          value="1,204"
          delta="3.1%"
          trend="down"
          description="vs. last week"
        />
        <.stat label="Error rate" value="0.04%" delta="0.0%" trend="flat" description="within budget" />
      </.story>

      <.story
        title="Description list"
        description="A semantic <dl> of term/description pairs in a responsive grid."
        code={@code.description_list}
      >
        <.description_list>
          <:item term="Plan">Pro</:item>
          <:item term="Owner">Ada Lovelace</:item>
          <:item term="Renews">March 1, 2026</:item>
          <:item term="Seats">12 of 20 used</:item>
        </.description_list>
      </.story>
    </div>
    """
  end
end
