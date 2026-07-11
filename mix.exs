defmodule AuroraUI.MixProject do
  use Mix.Project

  @version "0.1.2"
  @source_url "https://github.com/liamkillingback/aurora-ui"

  def project do
    [
      app: :aurora_ui,
      version: @version,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: [warnings_as_errors: true],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      name: "Aurora UI",
      description: description(),
      package: package(),
      docs: docs(),
      source_url: @source_url,
      test_coverage: [summary: [threshold: 0]]
    ]
  end

  def cli do
    [preferred_envs: ["test.watch": :test, check: :test]]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Aurora UI is a rendering library. Its only hard runtime dependency is the
  # Phoenix rendering/LiveView stack it produces markup for. Everything else is
  # tooling for the consumer's own app and stays out of the shipped package.
  defp deps do
    [
      {:phoenix_live_view, "~> 0.20 or ~> 1.0"},
      {:phoenix_html, "~> 3.3 or ~> 4.0"},

      # Docs / dev / test tooling only — never shipped to consumers.
      # ex_doc must be available in :dev so `mix hex.publish` (which runs in the
      # dev env and invokes the `docs` task) can build the documentation.
      {:jason, "~> 1.2", only: [:dev, :test]},
      {:floki, ">= 0.30.0", only: :test},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:makeup_elixir, "~> 0.16", only: :dev, runtime: false},
      {:makeup_eex, "~> 0.1", only: :dev, runtime: false}
    ]
  end

  defp description do
    "A free, MIT-licensed Phoenix LiveView + Tailwind UI kit: 15 accessible, " <>
      "themeable component families with complete interaction states, motion, " <>
      "and an optional, separately bundled Three.js experience layer."
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Liam Killingback"],
      links: %{
        "GitHub" => @source_url,
        "Docs" => "https://aurora-ui.phxtemplates.com",
        "PHXTemplates" => "https://phxtemplates.com"
      },
      files: ~w(lib priv/static assets/css assets/js .formatter.exs mix.exs
                README.md LICENSE CHANGELOG.md NOTICE.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "CHANGELOG.md",
        "LICENSE",
        "NOTICE.md",
        "docs/getting-started.md",
        "docs/tokens.md",
        "docs/motion.md",
        "docs/accessibility.md",
        "docs/liveview.md",
        "docs/compatibility.md",
        "docs/upgrade.md",
        "docs/troubleshooting.md"
      ],
      groups_for_extras: [
        Guides: ~r/docs\/.?/
      ],
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end

  defp aliases do
    [
      # Fail the build on unformatted code, warnings, and stale example snippets.
      check: [
        "format --check-formatted",
        "compile --warnings-as-errors",
        "test",
        "aurora.snippets --check"
      ]
    ]
  end
end
