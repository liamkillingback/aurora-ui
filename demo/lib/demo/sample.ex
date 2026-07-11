defmodule Demo.Sample do
  @moduledoc """
  In-memory sample data for the docs, component lab, and example app.

  There is no database in the demo. Every function here returns plain maps or
  lists of maps so stories can render realistic content — users, projects,
  table rows, menu items, navigation, notifications — without any persistence.
  Data is deterministic so screenshots and tests stay stable.
  """

  @doc "A short list of people, for avatars, tables, and menus."
  @spec users() :: [map()]
  def users do
    [
      %{
        id: 1,
        name: "Ada Lovelace",
        email: "ada@aurora.dev",
        role: "Owner",
        status: "online",
        initials: "AL"
      },
      %{
        id: 2,
        name: "Grace Hopper",
        email: "grace@aurora.dev",
        role: "Admin",
        status: "away",
        initials: "GH"
      },
      %{
        id: 3,
        name: "Alan Turing",
        email: "alan@aurora.dev",
        role: "Editor",
        status: "busy",
        initials: "AT"
      },
      %{
        id: 4,
        name: "Katherine Johnson",
        email: "katherine@aurora.dev",
        role: "Viewer",
        status: "offline",
        initials: "KJ"
      },
      %{
        id: 5,
        name: "Edsger Dijkstra",
        email: "edsger@aurora.dev",
        role: "Editor",
        status: "online",
        initials: "ED"
      }
    ]
  end

  @doc "Projects, for cards, tables, and stat rows."
  @spec projects() :: [map()]
  def projects do
    [
      %{
        id: "aurora-web",
        name: "Aurora Web",
        status: "active",
        progress: 72,
        owner: "Ada Lovelace",
        updated: "2m ago"
      },
      %{
        id: "nebula-api",
        name: "Nebula API",
        status: "active",
        progress: 41,
        owner: "Grace Hopper",
        updated: "1h ago"
      },
      %{
        id: "comet-mobile",
        name: "Comet Mobile",
        status: "paused",
        progress: 18,
        owner: "Alan Turing",
        updated: "yesterday"
      },
      %{
        id: "pulsar-docs",
        name: "Pulsar Docs",
        status: "archived",
        progress: 100,
        owner: "Katherine Johnson",
        updated: "3d ago"
      }
    ]
  end

  @doc "Tabular rows for the `table`/`data_grid` stories."
  @spec table_rows() :: [map()]
  def table_rows do
    projects = projects()

    users()
    |> Enum.with_index()
    |> Enum.map(fn {u, i} ->
      p = Enum.at(projects, rem(i, length(projects)))
      %{id: u.id, name: u.name, email: u.email, role: u.role, project: p.name, status: p.status}
    end)
  end

  @doc "Menu / command items with a label, optional icon name, and shortcut."
  @spec menu_items() :: [map()]
  def menu_items do
    [
      %{id: "new", label: "New project", icon: "hero-plus", shortcut: "N"},
      %{id: "invite", label: "Invite people", icon: "hero-user-plus", shortcut: "I"},
      %{id: "settings", label: "Settings", icon: "hero-cog-6-tooth", shortcut: ","},
      %{
        id: "archive",
        label: "Archive",
        icon: "hero-archive-box",
        shortcut: nil,
        destructive: false
      },
      %{id: "delete", label: "Delete", icon: "hero-trash", shortcut: nil, destructive: true}
    ]
  end

  @doc "Top-level nav items for navbar/sidebar stories (label + path)."
  @spec nav_items() :: [map()]
  def nav_items do
    [
      %{label: "Dashboard", path: "/app", icon: "hero-home"},
      %{label: "Projects", path: "/app/projects", icon: "hero-folder"},
      %{label: "Team", path: "/app/team", icon: "hero-users"},
      %{label: "Reports", path: "/app/reports", icon: "hero-chart-bar"},
      %{label: "Settings", path: "/app/settings", icon: "hero-cog-6-tooth"}
    ]
  end

  @doc "Notifications for toast/alert/feedback stories."
  @spec notifications() :: [map()]
  def notifications do
    [
      %{
        id: 1,
        severity: "success",
        title: "Deploy complete",
        body: "aurora-web shipped to production."
      },
      %{
        id: 2,
        severity: "info",
        title: "New comment",
        body: "Grace mentioned you on Nebula API."
      },
      %{
        id: 3,
        severity: "warning",
        title: "Usage at 80%",
        body: "You are approaching your plan limit."
      },
      %{id: 4, severity: "danger", title: "Build failed", body: "comet-mobile failed 3 checks."}
    ]
  end

  @doc "A handful of stat tiles (label, value, delta, trend)."
  @spec stats() :: [map()]
  def stats do
    [
      %{label: "Active users", value: "12,480", delta: "+8.2%", trend: "up"},
      %{label: "Requests / min", value: "1,204", delta: "-3.1%", trend: "down"},
      %{label: "Error rate", value: "0.04%", delta: "0.0%", trend: "flat"},
      %{label: "Uptime", value: "99.98%", delta: "+0.01%", trend: "up"}
    ]
  end

  @doc "A single fake user (the current signed-in user), for shells/avatars."
  @spec current_user() :: map()
  def current_user, do: hd(users())

  @doc """
  A richer project list for the **Nimbus** example app: enough rows, statuses,
  and owners that sorting and filtering are actually meaningful. Deterministic so
  the example is stable across reloads and screenshots.
  """
  @spec nimbus_projects() :: [map()]
  def nimbus_projects do
    [
      %{
        id: "aurora-web",
        name: "Aurora Web",
        key: "AUR",
        status: "active",
        owner: "Ada Lovelace",
        progress: 72,
        open_tasks: 8,
        updated: "2m ago"
      },
      %{
        id: "nebula-api",
        name: "Nebula API",
        key: "NEB",
        status: "active",
        owner: "Grace Hopper",
        progress: 41,
        open_tasks: 14,
        updated: "1h ago"
      },
      %{
        id: "comet-mobile",
        name: "Comet Mobile",
        key: "CMT",
        status: "paused",
        owner: "Alan Turing",
        progress: 18,
        open_tasks: 3,
        updated: "yesterday"
      },
      %{
        id: "pulsar-docs",
        name: "Pulsar Docs",
        key: "PLS",
        status: "archived",
        owner: "Katherine Johnson",
        progress: 100,
        open_tasks: 0,
        updated: "3d ago"
      },
      %{
        id: "quasar-billing",
        name: "Quasar Billing",
        key: "QSR",
        status: "active",
        owner: "Edsger Dijkstra",
        progress: 57,
        open_tasks: 11,
        updated: "20m ago"
      },
      %{
        id: "orbit-design",
        name: "Orbit Design System",
        key: "ORB",
        status: "active",
        owner: "Ada Lovelace",
        progress: 88,
        open_tasks: 5,
        updated: "4h ago"
      },
      %{
        id: "meteor-search",
        name: "Meteor Search",
        key: "MET",
        status: "paused",
        owner: "Grace Hopper",
        progress: 34,
        open_tasks: 7,
        updated: "2d ago"
      },
      %{
        id: "eclipse-auth",
        name: "Eclipse Auth",
        key: "ECL",
        status: "active",
        owner: "Alan Turing",
        progress: 63,
        open_tasks: 9,
        updated: "35m ago"
      }
    ]
  end

  @doc "Distinct project owners, as `{label, value}` tuples for a select."
  @spec project_owners() :: [{String.t(), String.t()}]
  def project_owners do
    nimbus_projects()
    |> Enum.map(& &1.owner)
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.map(&{&1, &1})
  end

  @doc "A small activity feed for the example app's async panel."
  @spec activity() :: [map()]
  def activity do
    [
      %{
        id: 1,
        actor: "Grace Hopper",
        verb: "merged",
        target: "PR #482 in Nebula API",
        at: "12 min ago",
        icon: "hero-arrow-path-rounded-square"
      },
      %{
        id: 2,
        actor: "Ada Lovelace",
        verb: "deployed",
        target: "Aurora Web to production",
        at: "38 min ago",
        icon: "hero-rocket-launch"
      },
      %{
        id: 3,
        actor: "Edsger Dijkstra",
        verb: "opened",
        target: "an issue in Quasar Billing",
        at: "1 hr ago",
        icon: "hero-exclamation-circle"
      },
      %{
        id: 4,
        actor: "Alan Turing",
        verb: "commented on",
        target: "Eclipse Auth spec",
        at: "2 hr ago",
        icon: "hero-chat-bubble-left-right"
      }
    ]
  end
end
