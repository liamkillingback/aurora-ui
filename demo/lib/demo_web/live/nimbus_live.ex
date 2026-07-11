defmodule DemoWeb.NimbusLive do
  @moduledoc """
  **Nimbus** — a small, coherent example application built entirely from Aurora
  UI (`/app` and `/app/new`). Not a gallery: a believable little project
  dashboard that shows the kit working together as a product.

  It demonstrates, in one place: a responsive navbar + sidebar shell, stat cards,
  a sortable/filterable/selectable data table with a live result count, an async
  loading state (simulated with `Process.send_after/3`), a toast group, a
  validated "new project" form (field/choices/selection) in a dialog, a filters
  drawer, a command palette, theme + reduced-motion controls, an RTL toggle, a
  deterministic reset, and — at the very end, never gating anything — the opt-in
  newsletter and a restrained premium CTA.

  There is no database and no real service: all data is in-memory `Demo.Sample`
  fixtures, and the newsletter is the in-memory `Demo.Newsletter`.
  """
  use DemoWeb, :live_view

  @statuses [
    {"All statuses", "all"},
    {"Active", "active"},
    {"Paused", "paused"},
    {"Archived", "archived"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Nimbus — the Aurora UI example app")
     |> assign(
       :page_description,
       "Nimbus is a small project dashboard built entirely from Aurora UI: responsive shell, sortable data table, filters, dialog form, command palette, toasts, and async loading — with no database."
     )
     |> assign(:nav_active, "app")
     |> assign(:owners, [{"Any owner", "all"} | Demo.Sample.project_owners()])
     |> assign(:owner_options, Demo.Sample.project_owners())
     |> assign(:statuses, @statuses)
     |> assign(:current_user, Demo.Sample.current_user())
     |> assign(:stats, Demo.Sample.stats())
     |> assign(:toast_seq, 0)
     |> reset_newsletter()
     |> reset_demo_state()
     |> schedule_load()
     |> recompute()}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, :show_new, socket.assigns.live_action == :new)}
  end

  # ── Table: sorting & selection ─────────────────────────────────────────────
  @impl true
  def handle_event("sort", %{"key" => key}, socket) do
    {sort_by, sort_dir} = toggle_sort(socket.assigns.sort_by, socket.assigns.sort_dir, key)
    {:noreply, socket |> assign(sort_by: sort_by, sort_dir: sort_dir) |> recompute()}
  end

  def handle_event("select_row", %{"id" => id}, socket) do
    selected =
      if id in socket.assigns.selected,
        do: List.delete(socket.assigns.selected, id),
        else: [id | socket.assigns.selected]

    {:noreply, socket |> assign(:selected, selected) |> recompute()}
  end

  def handle_event("select_all", _params, socket) do
    visible_ids = Enum.map(socket.assigns.visible, & &1.id)

    selected =
      if socket.assigns.all_selected,
        do: socket.assigns.selected -- visible_ids,
        else: Enum.uniq(socket.assigns.selected ++ visible_ids)

    {:noreply, socket |> assign(:selected, selected) |> recompute()}
  end

  def handle_event("archive_selected", _params, socket) do
    ids = socket.assigns.selected

    projects =
      Enum.map(socket.assigns.projects, fn p ->
        if p.id in ids, do: %{p | status: "archived", updated: "just now"}, else: p
      end)

    {:noreply,
     socket
     |> assign(projects: projects, selected: [])
     |> add_toast("info", "Projects archived", "#{length(ids)} project(s) moved to archived.")
     |> recompute()}
  end

  # ── Filters (shared by the filter bar and the drawer) ──────────────────────
  def handle_event("filter", params, socket) do
    {:noreply,
     socket
     |> maybe_put(:query, params["q"])
     |> maybe_put(:status_filter, params["status"])
     |> maybe_put(:owner_filter, params["owner"])
     |> maybe_put(:density, params["density"])
     |> recompute()}
  end

  def handle_event("clear_filters", _params, socket) do
    {:noreply, socket |> assign(default_filters()) |> recompute()}
  end

  def handle_event("drop_filter", %{"key" => key}, socket) do
    socket =
      case key do
        "q" -> assign(socket, :query, "")
        "status" -> assign(socket, :status_filter, "all")
        "owner" -> assign(socket, :owner_filter, "all")
        "archived" -> assign(socket, :show_archived, false)
        _ -> socket
      end

    {:noreply, recompute(socket)}
  end

  def handle_event("toggle_archived", _params, socket) do
    {:noreply, socket |> assign(:show_archived, !socket.assigns.show_archived) |> recompute()}
  end

  def handle_event("toggle_filters", _params, socket) do
    {:noreply, assign(socket, :show_filters, !socket.assigns.show_filters)}
  end

  def handle_event("close_filters", _params, socket) do
    {:noreply, assign(socket, :show_filters, false)}
  end

  # ── RTL toggle (theme + motion are handled client-side by the shell hook) ──
  def handle_event("toggle_rtl", _params, socket) do
    {:noreply, assign(socket, :dir, if(socket.assigns.dir == "rtl", do: "ltr", else: "rtl"))}
  end

  # ── New project form ───────────────────────────────────────────────────────
  def handle_event("validate_project", %{"project" => params}, socket) do
    normalized = normalize_project(params)

    {:noreply,
     assign(socket, project_params: normalized, project_errors: validate_project(normalized))}
  end

  def handle_event("create_project", %{"project" => params}, socket) do
    normalized = normalize_project(params)
    errors = validate_project(normalized)

    if errors == %{} do
      project = build_project(normalized, socket.assigns.projects)

      {:noreply,
       socket
       |> assign(:projects, [project | socket.assigns.projects])
       |> reset_project_form()
       |> add_toast("success", "Project created", "#{project.name} (#{project.key}) is ready.")
       |> recompute()
       |> push_patch(to: ~p"/app")}
    else
      {:noreply,
       assign(socket, project_params: normalized, project_errors: errors, project_submitted: true)}
    end
  end

  def handle_event("close_new", _params, socket) do
    {:noreply, socket |> reset_project_form() |> push_patch(to: ~p"/app")}
  end

  # ── Toasts ─────────────────────────────────────────────────────────────────
  def handle_event("drop_toast", %{"id" => id}, socket) do
    {:noreply, drop_toast(socket, id)}
  end

  # ── Deterministic reset ────────────────────────────────────────────────────
  def handle_event("reset_demo", _params, socket) do
    {:noreply,
     socket
     |> reset_demo_state()
     |> reset_newsletter()
     |> schedule_load()
     |> add_toast("info", "Demo reset", "Sample data and filters restored to defaults.")
     |> recompute()}
  end

  # ── Newsletter (footer signup) ─────────────────────────────────────────────
  def handle_event("validate_email", %{"email" => email}, socket) do
    error =
      if email == "" or Demo.Newsletter.valid_email?(email),
        do: nil,
        else: "That doesn't look like an email yet."

    {:noreply, assign(socket, news_email: email, news_error: error)}
  end

  def handle_event("subscribe", %{"email" => email} = params, socket) do
    case Demo.Newsletter.subscribe(%{email: email, source: params["source"] || "app-footer"}) do
      {:ok, sub} ->
        {:noreply, assign(socket, news_state: :subscribed, news_confirmed: sub.email)}

      {:error, :invalid_email} ->
        {:noreply, assign(socket, news_email: email, news_error: "Enter a valid email address.")}

      {:error, :suppressed} ->
        {:noreply,
         assign(socket,
           news_email: email,
           news_error: "This address unsubscribed and won't be re-added automatically."
         )}
    end
  end

  def handle_event("reset_newsletter", _params, socket) do
    {:noreply, reset_newsletter(socket)}
  end

  # ── Async load + toast expiry ──────────────────────────────────────────────
  @impl true
  def handle_info(:data_loaded, socket) do
    {:noreply,
     socket
     |> assign(:table_loading, false)
     |> assign(:activity_state, :ok)
     |> assign(:activities, Demo.Sample.activity())
     |> recompute()}
  end

  def handle_info({:expire_toast, id}, socket) do
    {:noreply, drop_toast(socket, id)}
  end

  # ═══════════════════════════════════════════════════════════════════════════
  # Render
  # ═══════════════════════════════════════════════════════════════════════════

  @impl true
  def render(assigns) do
    ~H"""
    <div id="nimbus-root" class="nimbus" dir={@dir} phx-hook=".NimbusShell">
      <.skip_link href="#nimbus-main">Skip to dashboard</.skip_link>

      <.navbar label="Nimbus">
        <:brand>
          <.link navigate={~p"/app"} class="nimbus-brand aui-focusable">
            <span class="nimbus-brand__mark" aria-hidden="true"></span>
            <span class="nimbus-brand__name">Nimbus</span>
          </.link>
        </:brand>
        <:link navigate={~p"/app"} current>Dashboard</:link>
        <:link navigate={~p"/lab"}>The Lab</:link>
        <:link navigate={~p"/docs/getting-started"}>Docs</:link>
        <:actions>
          {theme_controls(assigns)}
          <.avatar name={@current_user.name} size="sm" status="online" />
        </:actions>
      </.navbar>

      <div class="nimbus__body">
        <.sidebar label="Nimbus sections">
          <:section label="Workspace">
            <.sidebar_item navigate={~p"/app"} current>
              <:icon><.icon name="hero-squares-2x2" class="size-4" /></:icon>
              Dashboard
            </.sidebar_item>
            <.sidebar_item href="#projects-panel">
              <:icon><.icon name="hero-folder" class="size-4" /></:icon>
              Projects
            </.sidebar_item>
            <.sidebar_item href="#activity-panel">
              <:icon><.icon name="hero-bell" class="size-4" /></:icon>
              Activity
            </.sidebar_item>
          </:section>
          <:section label="Aurora UI">
            <.sidebar_item navigate={~p"/docs/getting-started"}>
              <:icon><.icon name="hero-book-open" class="size-4" /></:icon>
              Install & docs
            </.sidebar_item>
            <.sidebar_item navigate={~p"/components"}>
              <:icon><.icon name="hero-cube" class="size-4" /></:icon>
              All components
            </.sidebar_item>
            <.sidebar_item navigate={~p"/lab"}>
              <:icon><.icon name="hero-sparkles" class="size-4" /></:icon>
              The Lab
            </.sidebar_item>
          </:section>
        </.sidebar>

        <main id="nimbus-main" class="nimbus__main">
          <header class="nimbus-head">
            <div class="nimbus-head__intro">
              <p class="nimbus-head__eyebrow">Example app</p>
              <h1 class="nimbus-head__title">Good afternoon, {first_name(@current_user.name)}</h1>
              <p class="nimbus-head__sub">Here's what's moving across your projects today.</p>
            </div>
            <div class="nimbus-head__actions">
              <.command_palette id="nimbus-cmd" trigger_label="Search or jump to…" shortcut="⌘K">
                <:group label="Actions">
                  <button
                    role="option"
                    data-aui-command-item
                    class="nimbus-cmd-item"
                    phx-click={JS.patch(~p"/app/new")}
                  >
                    New project
                  </button>
                  <button
                    role="option"
                    data-aui-command-item
                    class="nimbus-cmd-item"
                    phx-click="reset_demo"
                  >
                    Reset demo data
                  </button>
                  <button
                    role="option"
                    data-aui-command-item
                    class="nimbus-cmd-item"
                    phx-click="toggle_rtl"
                  >
                    Toggle text direction (RTL)
                  </button>
                </:group>
                <:group label="Navigate">
                  <button
                    role="option"
                    data-aui-command-item
                    class="nimbus-cmd-item"
                    phx-click={JS.navigate(~p"/lab")}
                  >
                    Open the Lab
                  </button>
                  <button
                    role="option"
                    data-aui-command-item
                    class="nimbus-cmd-item"
                    phx-click={JS.navigate(~p"/components")}
                  >
                    Browse all components
                  </button>
                  <button
                    role="option"
                    data-aui-command-item
                    class="nimbus-cmd-item"
                    phx-click={JS.navigate(~p"/docs/getting-started")}
                  >
                    Getting started docs
                  </button>
                </:group>
                <:empty>No commands match that search.</:empty>
              </.command_palette>

              <.button variant="primary" patch={~p"/app/new"}>
                <:icon_start><.icon name="hero-plus" class="size-4" /></:icon_start>
                New project
              </.button>
              <.button variant="ghost" phx-click="reset_demo" title="Restore sample data">
                <:icon_start><.icon name="hero-arrow-path" class="size-4" /></:icon_start>
                Reset
              </.button>
            </div>
          </header>

          <section class="nimbus-stats" aria-label="Key metrics">
            <.stat
              :for={s <- @stats}
              label={s.label}
              value={s.value}
              delta={s.delta}
              trend={s.trend}
              loading={@table_loading}
            />
          </section>

          <section id="projects-panel" class="nimbus-panel" aria-label="Projects">
            <div class="nimbus-panel__head">
              <h2 class="nimbus-panel__title">Projects</h2>
              <.button variant="secondary" size="sm" phx-click="toggle_filters">
                <:icon_start><.icon name="hero-adjustments-horizontal" class="size-4" /></:icon_start>
                Filters
              </.button>
            </div>

            <.filter_bar
              count={@count}
              count_unit="projects"
              active?={filters_active?(assigns)}
              clear_event="clear_filters"
            >
              <form class="nimbus-filters" phx-change="filter" phx-submit="filter">
                <.input
                  type="search"
                  name="q"
                  value={@query}
                  placeholder="Search projects or owners…"
                  aria-label="Search projects"
                  phx-debounce="200"
                >
                  <:prefix><.icon name="hero-magnifying-glass" class="size-4" /></:prefix>
                </.input>
                <.select name="status" value={@status_filter} options={@statuses} />
                <.select name="owner" value={@owner_filter} options={@owners} />
              </form>
              <:chips>
                <.filter_chip
                  :if={@query != ""}
                  label={"Search: #{@query}"}
                  remove_event="drop_filter"
                  value="q"
                />
                <.filter_chip
                  :if={@status_filter != "all"}
                  label={"Status: #{@status_filter}"}
                  remove_event="drop_filter"
                  value="status"
                />
                <.filter_chip
                  :if={@owner_filter != "all"}
                  label={"Owner: #{@owner_filter}"}
                  remove_event="drop_filter"
                  value="owner"
                />
                <.filter_chip
                  :if={@show_archived}
                  label="Including archived"
                  remove_event="drop_filter"
                  value="archived"
                />
              </:chips>
            </.filter_bar>

            <div class={["nimbus-table", @density == "compact" && "nimbus-table--compact"]}>
              <.table
                caption="Projects in this workspace"
                caption_visible={false}
                rows={@visible}
                selectable
                selected={@selected}
                row_id={& &1.id}
                all_selected={@all_selected}
                loading={@table_loading}
                responsive="scroll"
                sort_by={@sort_by}
                sort_dir={@sort_dir}
                sort_event="sort"
                select_event="select_row"
                select_all_event="select_all"
              >
                <:col :let={p} label="Project" key="name" sortable>
                  <div class="nimbus-cellproject">
                    <span class="nimbus-cellproject__key" aria-hidden="true">{p.key}</span>
                    <span class="nimbus-cellproject__name">{p.name}</span>
                  </div>
                </:col>
                <:col :let={p} label="Status" key="status" sortable>
                  <.badge variant={status_variant(p.status)} dot>{p.status}</.badge>
                </:col>
                <:col :let={p} label="Owner">{p.owner}</:col>
                <:col :let={p} label="Progress" key="progress" sortable numeric>
                  <div class="nimbus-cellprogress">
                    <.progress value={p.progress} size="sm" />
                    <span class="nimbus-cellprogress__pct">{p.progress}%</span>
                  </div>
                </:col>
                <:col :let={p} label="Open tasks" key="open_tasks" sortable numeric>
                  {p.open_tasks}
                </:col>
                <:bulk_actions>
                  <.button variant="danger" size="sm" phx-click="archive_selected">
                    <:icon_start><.icon name="hero-archive-box" class="size-4" /></:icon_start>
                    Archive
                  </.button>
                </:bulk_actions>
                <:empty>
                  <.empty_state
                    title="No projects match"
                    description="Try clearing a filter or broadening your search."
                  >
                    <:icon><.icon name="hero-folder-open" class="size-8" /></:icon>
                    <:actions>
                      <.button variant="secondary" size="sm" phx-click="clear_filters">
                        Clear filters
                      </.button>
                    </:actions>
                  </.empty_state>
                </:empty>
              </.table>
            </div>
          </section>

          <section id="activity-panel" class="nimbus-panel" aria-label="Recent activity">
            <div class="nimbus-panel__head">
              <h2 class="nimbus-panel__title">Recent activity</h2>
              <.inline_status severity="success" label="All systems operational" />
            </div>

            <.async_state state={@activity_state}>
              <:loading>
                <ul class="nimbus-activity" aria-hidden="true">
                  <li :for={_ <- 1..4} class="nimbus-activity__item">
                    <.skeleton width="2rem" height="2rem" shape="circle" />
                    <div class="nimbus-activity__lines">
                      <.skeleton width="60%" height="0.9rem" shape="text" />
                      <.skeleton width="30%" height="0.75rem" shape="text" />
                    </div>
                  </li>
                </ul>
              </:loading>
              <:empty>No recent activity.</:empty>
              <:error>
                Couldn't load activity. <.button size="sm" phx-click="reset_demo">Retry</.button>
              </:error>
              <ul class="nimbus-activity">
                <li :for={a <- @activities} class="nimbus-activity__item">
                  <span class="nimbus-activity__icon" aria-hidden="true">
                    <.icon name={a.icon} class="size-4" />
                  </span>
                  <div class="nimbus-activity__lines">
                    <p class="nimbus-activity__text">
                      <strong>{a.actor}</strong> {a.verb} {a.target}
                    </p>
                    <p class="nimbus-activity__time">{a.at}</p>
                  </div>
                </li>
              </ul>
            </.async_state>
          </section>

          <footer class="nimbus-footer">
            <DemoWeb.Funnel.newsletter_form
              source="app-footer"
              email={@news_email}
              error={@news_error}
              state={@news_state}
              confirmed_email={@news_confirmed}
              heading="Ship this pattern in your own app"
            />
          </footer>

          <DemoWeb.Funnel.premium_cta src="app" />
        </main>
      </div>

      <.toast_group id="nimbus-toasts">
        <.toast
          :for={t <- @toasts}
          id={"toast-#{t.id}"}
          severity={t.severity}
          title={t.title}
          on_dismiss={JS.push("drop_toast", value: %{id: t.id})}
        >
          {t.body}
        </.toast>
      </.toast_group>

      <.drawer
        id="nimbus-filters"
        side="end"
        modal={false}
        open={@show_filters}
        on_close={JS.push("close_filters")}
      >
        <:title>Refine projects</:title>
        <:description>
          Filters apply live. This drawer is non-modal — the dashboard stays usable behind it.
        </:description>
        <form class="nimbus-drawerform" phx-change="filter">
          <div class="nimbus-field">
            <span class="nimbus-field__label">Status</span>
            <.select name="status" value={@status_filter} options={@statuses} />
          </div>
          <div class="nimbus-field">
            <span class="nimbus-field__label">Owner</span>
            <.select name="owner" value={@owner_filter} options={@owners} />
          </div>
          <div class="nimbus-field">
            <span class="nimbus-field__label">Density</span>
            <.segmented_control
              name="density"
              value={@density}
              label="Table density"
              options={[{"Comfortable", "comfortable"}, {"Compact", "compact"}]}
            />
          </div>
        </form>
        <.switch checked={@show_archived} phx-click="toggle_archived">
          Include archived projects
          <:description>Archived projects are hidden from the default view.</:description>
        </.switch>
        <:footer>
          <.button variant="ghost" phx-click="clear_filters" data-aui-drawer-close>Clear all</.button>
          <.button variant="primary" data-aui-drawer-close>Done</.button>
        </:footer>
      </.drawer>

      <.dialog
        id="nimbus-new"
        open={@show_new}
        size="lg"
        on_close={JS.push("close_new")}
      >
        <:title>New project</:title>
        <:description>
          Set up a project in this workspace. Nothing is saved to a server — this is a demo.
        </:description>

        <.alert
          :if={@project_submitted and @project_errors != %{}}
          variant="danger"
          title="Please fix the highlighted fields"
        >
          A few details still need attention before this project can be created.
        </.alert>

        <form
          id="nimbus-new-form"
          class="nimbus-form"
          phx-change="validate_project"
          phx-submit="create_project"
          novalidate
        >
          <div class="nimbus-form__row">
            <.field :let={f} id="np-name" label="Project name" error={@project_errors[:name]} required>
              <.input
                {f}
                type="text"
                name="project[name]"
                value={@project_params["name"]}
                placeholder="Aurora Web"
                phx-debounce="150"
              />
            </.field>
            <.field
              :let={f}
              id="np-key"
              label="Key"
              help="2–5 letters, e.g. AUR"
              error={@project_errors[:key]}
              required
            >
              <.input
                {f}
                type="text"
                name="project[key]"
                value={@project_params["key"]}
                placeholder="AUR"
                maxlength={5}
                phx-debounce="150"
              />
            </.field>
          </div>

          <.field id="np-owner" label="Owner" error={@project_errors[:owner]} required>
            <.select
              id="np-owner"
              name="project[owner]"
              value={@project_params["owner"]}
              invalid={@project_errors[:owner] != nil}
              prompt="Choose an owner"
              options={@owner_options}
            />
          </.field>

          <.radio_group
            label="Visibility"
            name="project[visibility]"
            value={@project_params["visibility"]}
            options={[
              %{label: "Private", value: "private", description: "Only you can see it."},
              %{label: "Team", value: "team", description: "Everyone in the workspace."},
              %{label: "Public", value: "public", description: "Anyone with the link."}
            ]}
          />

          <div class="nimbus-field">
            <span class="nimbus-field__label">Initial status</span>
            <.segmented_control
              name="project[status]"
              value={@project_params["status"]}
              label="Initial status"
              options={[{"Active", "active"}, {"Paused", "paused"}]}
            />
          </div>

          <.field :let={f} id="np-desc" label="Description" optional>
            <.textarea
              {f}
              name="project[description]"
              value={@project_params["description"]}
              rows={3}
              maxlength={160}
              show_count
              autosize
              placeholder="What is this project about?"
            />
          </.field>

          <.switch name="project[notify]" value="true" checked={@project_params["notify"] == "true"}>
            Notify the team on create
          </.switch>
        </form>

        <:footer>
          <.button variant="ghost" data-aui-dialog-close phx-click="close_new">Cancel</.button>
          <.button variant="primary" type="submit" form="nimbus-new-form">
            <:icon_start><.icon name="hero-plus" class="size-4" /></:icon_start>
            Create project
          </.button>
        </:footer>
      </.dialog>
    </div>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".NimbusShell">
      export default {
        mounted() {
          this.root = document.documentElement
          this.onTheme = (e) => this.setTheme(e.detail && e.detail.value)
          this.onMotion = () => this.toggleMotion()
          window.addEventListener("aui:theme", this.onTheme)
          window.addEventListener("aui:motion", this.onMotion)
          this.sync()
        },
        updated() { this.sync() },
        destroyed() {
          window.removeEventListener("aui:theme", this.onTheme)
          window.removeEventListener("aui:motion", this.onMotion)
        },
        setTheme(value) {
          if (value === "system") {
            this.root.removeAttribute("data-aui-theme")
            localStorage.setItem("aui-theme", "system")
          } else if (value) {
            this.root.setAttribute("data-aui-theme", value)
            localStorage.setItem("aui-theme", value)
          }
          this.sync()
        },
        toggleMotion() {
          const reduced = this.root.getAttribute("data-motion") === "reduce"
          if (reduced) {
            this.root.removeAttribute("data-motion")
            localStorage.removeItem("aui-motion")
          } else {
            this.root.setAttribute("data-motion", "reduce")
            localStorage.setItem("aui-motion", "reduce")
          }
          this.sync()
        },
        sync() {
          const theme = this.root.getAttribute("data-aui-theme") || "system"
          this.el.querySelectorAll("[data-theme-btn]").forEach((b) => {
            b.setAttribute("aria-pressed", String(b.dataset.themeBtn === theme))
          })
          const reduced = this.root.getAttribute("data-motion") === "reduce"
          this.el.querySelectorAll("[data-motion-btn]").forEach((b) => {
            b.setAttribute("aria-pressed", String(reduced))
          })
        }
      }
    </script>
    """
  end

  # The top-bar theme / motion / RTL cluster, mirroring the docs shell so the
  # example app has the same theme and reduced-motion controls.
  defp theme_controls(assigns) do
    ~H"""
    <div class="nimbus-controls">
      <div class="demo-seg" role="group" aria-label="Color theme">
        <button
          type="button"
          class="demo-seg__btn aui-focusable"
          data-theme-btn="system"
          aria-label="Match system theme"
          phx-click={JS.dispatch("aui:theme", detail: %{value: "system"})}
        >
          <.icon name="hero-computer-desktop" class="size-4" />
        </button>
        <button
          type="button"
          class="demo-seg__btn aui-focusable"
          data-theme-btn="light"
          aria-label="Light theme"
          phx-click={JS.dispatch("aui:theme", detail: %{value: "light"})}
        >
          <.icon name="hero-sun" class="size-4" />
        </button>
        <button
          type="button"
          class="demo-seg__btn aui-focusable"
          data-theme-btn="dark"
          aria-label="Dark theme"
          phx-click={JS.dispatch("aui:theme", detail: %{value: "dark"})}
        >
          <.icon name="hero-moon" class="size-4" />
        </button>
      </div>
      <button
        type="button"
        class="demo-toggle aui-focusable"
        data-motion-btn
        aria-label="Toggle reduced motion"
        title="Toggle reduced motion"
        phx-click={JS.dispatch("aui:motion")}
      >
        <.icon name="hero-bolt" class="size-4" />
      </button>
      <button
        type="button"
        class="demo-toggle aui-focusable"
        aria-label="Toggle right-to-left layout"
        aria-pressed={to_string(@dir == "rtl")}
        title="Toggle RTL"
        phx-click="toggle_rtl"
      >
        <.icon name="hero-language" class="size-4" />
      </button>
    </div>
    """
  end

  # ═══════════════════════════════════════════════════════════════════════════
  # State helpers
  # ═══════════════════════════════════════════════════════════════════════════

  defp reset_demo_state(socket) do
    socket
    |> assign(:projects, Demo.Sample.nimbus_projects())
    |> assign(:sort_by, "name")
    |> assign(:sort_dir, "asc")
    |> assign(:selected, [])
    |> assign(:density, "comfortable")
    |> assign(:dir, "ltr")
    |> assign(:show_filters, false)
    |> assign(:show_new, false)
    |> assign(:toasts, [])
    |> assign(default_filters())
    |> reset_project_form()
  end

  defp default_filters do
    [query: "", status_filter: "all", owner_filter: "all", show_archived: false]
  end

  defp reset_project_form(socket) do
    assign(socket, project_params: blank_project(), project_errors: %{}, project_submitted: false)
  end

  defp reset_newsletter(socket) do
    assign(socket, news_email: "", news_error: nil, news_state: :idle, news_confirmed: nil)
  end

  defp schedule_load(socket) do
    Process.send_after(self(), :data_loaded, 800)
    assign(socket, table_loading: true, activity_state: :loading, activities: [])
  end

  # Recompute the derived view (filtered + sorted rows, count, select-all state).
  defp recompute(socket) do
    a = socket.assigns
    visible = a.projects |> filter_projects(a) |> sort_projects(a.sort_by, a.sort_dir)
    ids = Enum.map(visible, & &1.id)
    all_selected = visible != [] and Enum.all?(ids, &(&1 in a.selected))
    assign(socket, visible: visible, count: length(visible), all_selected: all_selected)
  end

  defp filter_projects(projects, a) do
    q = String.downcase(a.query)

    Enum.filter(projects, fn p ->
      status_match?(p, a.status_filter, a.show_archived) and
        (a.owner_filter == "all" or p.owner == a.owner_filter) and
        (q == "" or String.contains?(String.downcase(p.name), q) or
           String.contains?(String.downcase(p.owner), q) or
           String.contains?(String.downcase(p.key), q))
    end)
  end

  defp status_match?(p, "all", show_archived), do: show_archived or p.status != "archived"
  defp status_match?(p, status, _show_archived), do: p.status == status

  defp sort_projects(projects, key, dir) do
    sorter = fn p -> sort_key(p, key) end

    projects
    |> Enum.sort_by(sorter, if(dir == "desc", do: :desc, else: :asc))
  end

  defp sort_key(p, "name"), do: p.name
  defp sort_key(p, "status"), do: p.status
  defp sort_key(p, "progress"), do: p.progress
  defp sort_key(p, "open_tasks"), do: p.open_tasks
  defp sort_key(p, _), do: p.name

  defp toggle_sort(sort_by, sort_dir, key) do
    cond do
      sort_by != key -> {key, "asc"}
      sort_dir == "asc" -> {key, "desc"}
      true -> {key, "asc"}
    end
  end

  defp filters_active?(a) do
    a.query != "" or a.status_filter != "all" or a.owner_filter != "all" or a.show_archived
  end

  # ── Toasts ──────────────────────────────────────────────────────────────────
  defp add_toast(socket, severity, title, body) do
    id = socket.assigns.toast_seq + 1
    Process.send_after(self(), {:expire_toast, id}, 6500)

    socket
    |> assign(:toast_seq, id)
    |> assign(
      :toasts,
      socket.assigns.toasts ++ [%{id: id, severity: severity, title: title, body: body}]
    )
  end

  defp drop_toast(socket, id) do
    assign(socket, :toasts, Enum.reject(socket.assigns.toasts, &(&1.id == id)))
  end

  # ── New project form data ────────────────────────────────────────────────────
  defp blank_project do
    %{
      "name" => "",
      "key" => "",
      "owner" => "",
      "visibility" => "team",
      "status" => "active",
      "description" => "",
      "notify" => "true"
    }
  end

  defp normalize_project(p) do
    %{
      "name" => p["name"] || "",
      "key" => p["key"] || "",
      "owner" => p["owner"] || "",
      "visibility" => p["visibility"] || "team",
      "status" => p["status"] || "active",
      "description" => p["description"] || "",
      "notify" => if(p["notify"] == "true", do: "true", else: "false")
    }
  end

  defp validate_project(p) do
    %{}
    |> validate_name(p["name"])
    |> validate_key(p["key"])
    |> validate_owner(p["owner"])
  end

  defp validate_name(errors, name) do
    if String.length(String.trim(name)) < 3,
      do: Map.put(errors, :name, "Give the project a name of at least 3 characters."),
      else: errors
  end

  defp validate_key(errors, key) do
    key = String.trim(key)

    cond do
      key == "" ->
        Map.put(errors, :key, "A short key like AUR is required.")

      not Regex.match?(~r/^[A-Za-z]{2,5}$/, key) ->
        Map.put(errors, :key, "Use 2–5 letters, no spaces.")

      true ->
        errors
    end
  end

  defp validate_owner(errors, owner) do
    if String.trim(owner) == "",
      do: Map.put(errors, :owner, "Choose an owner for the project."),
      else: errors
  end

  defp build_project(p, existing) do
    key = p["key"] |> String.trim() |> String.upcase()
    base = key |> String.downcase()
    taken = MapSet.new(existing, & &1.id)

    id =
      if MapSet.member?(taken, base),
        do: "#{base}-#{System.unique_integer([:positive])}",
        else: base

    %{
      id: id,
      name: String.trim(p["name"]),
      key: key,
      status: p["status"],
      owner: p["owner"],
      progress: 0,
      open_tasks: 0,
      updated: "just now",
      visibility: p["visibility"]
    }
  end

  # ── Misc ─────────────────────────────────────────────────────────────────────
  defp maybe_put(socket, _key, nil), do: socket
  defp maybe_put(socket, key, value), do: assign(socket, key, value)

  defp status_variant("active"), do: "success"
  defp status_variant("paused"), do: "warning"
  defp status_variant("archived"), do: "neutral"
  defp status_variant(_), do: "info"

  defp first_name(name), do: name |> String.split(" ") |> List.first()
end
