defmodule DemoWeb.Markdown do
  @moduledoc """
  Server-side Markdown rendering for the prose documentation pages.

  Docs live as `.md` files in the library's `docs/` directory (one level up
  from the demo app). We read a whitelisted page at request time and convert it
  to HTML with Earmark, so `/docs/:page` renders fully without any JavaScript.
  Output is wrapped in Aurora UI's `<.prose>` by the caller.
  """

  # docs/ sits at the repository root, next to demo/. This module file lives at
  # demo/lib/demo_web/markdown.ex, so climb four levels then into docs/.
  @docs_dir Path.expand(Path.join([__DIR__, "..", "..", "..", "docs"]))

  @doc "Absolute path of the directory holding the docs markdown files."
  @spec docs_dir() :: String.t()
  def docs_dir, do: @docs_dir

  @doc """
  Reads and renders the docs page for `slug` (already whitelisted by the
  caller via `DemoWeb.Nav.doc_page/1`). Returns `{:ok, safe_html}` or
  `{:error, reason}`.
  """
  @spec render_page(String.t()) :: {:ok, Phoenix.HTML.safe()} | {:error, term()}
  def render_page(slug) do
    path = Path.join(@docs_dir, "#{slug}.md")

    with {:ok, markdown} <- File.read(path),
         {:ok, html, _warnings} <- to_html(markdown) do
      {:ok, Phoenix.HTML.raw(html)}
    end
  end

  defp to_html(markdown) do
    case Earmark.as_html(markdown, compact_output: false) do
      {:ok, html, warnings} -> {:ok, html, warnings}
      # Earmark returns {:error, html, messages} on non-fatal parse issues; the
      # HTML is still usable, so treat it as success for docs display.
      {:error, html, warnings} -> {:ok, html, warnings}
    end
  end
end
