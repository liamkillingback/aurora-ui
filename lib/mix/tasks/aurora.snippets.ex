defmodule Mix.Tasks.Aurora.Snippets do
  @shortdoc "Verifies documentation code snippets stay in sync with compiled source"
  @moduledoc """
  Keeps example code shown in the docs synchronized with real, compiled,
  testable source so a stale snippet fails CI instead of misleading a reader.

  Snippets live in `docs/snippets/*.exs`. Each file is a self-contained,
  compilable Elixir module using Aurora UI components. The docs and the component
  lab render these same modules, so what a reader copies is what CI compiled.

      mix aurora.snippets           # compile every snippet, fail on error
      mix aurora.snippets --check   # same, used in CI (alias `mix check`)

  A missing `docs/snippets` directory is not an error before any snippet exists;
  the task reports "no snippets" and succeeds so the build bootstraps cleanly.
  """
  use Mix.Task

  @snippet_dir "docs/snippets"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("compile")
    # Ensure the library's modules are loadable before we compile snippets that
    # import them, so a cold/parallel build can't race the dependency load order.
    Mix.Task.run("loadpaths")
    Application.ensure_all_started(:aurora_ui)
    Code.ensure_compiled!(AuroraUI.Internal)

    case snippet_files() do
      [] ->
        Mix.shell().info("[aurora.snippets] no snippets in #{@snippet_dir} yet — ok")
        :ok

      files ->
        {ok, failed} = Enum.split_with(files, &compiles?/1)
        Mix.shell().info("[aurora.snippets] #{length(ok)} ok, #{length(failed)} failed")

        if failed != [] do
          Mix.raise("""
          Stale or broken documentation snippets:

          #{Enum.map_join(failed, "\n", &("  - " <> &1))}

          Fix the snippet or the component it demonstrates. Snippets must compile
          against the current source.
          """)
        end

        :ok
    end
  end

  defp snippet_files do
    Path.wildcard(Path.join(@snippet_dir, "*.exs"))
  end

  defp compiles?(file) do
    Code.compile_file(file)
    true
  rescue
    _ -> false
  after
    :ok
  end
end
