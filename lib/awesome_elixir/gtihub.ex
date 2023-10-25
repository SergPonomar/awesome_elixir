defmodule AwesomeElixir.Github do
  alias AwesomeElixir.Repo
  alias AwesomeElixir.Category
  alias Ecto.Multi
  import Ecto.Query, only: [from: 2]
  require Logger

  def refresh_data() do
    {:ok, response} = get_readme_md()
    categories = parse_md_to_categories(response.body)
    insert_categories_to_db(categories)
    fetch_repos_and_insert_to_db()
  end

  defp insert_categories_to_db(categories) do 
    categories
    |> Enum.reduce(
      Multi.new(),
      fn el, acc -> 
        {:category, name, _desc, links} = el
        acc
        |> Multi.insert(
          name, 
          create_category(el), 
          on_conflict: {:replace_all_except, [:id, :inserted_at]},
          conflict_target: :name
        )
        |> Multi.merge(fn mult ->
          category = Map.get(mult, name)
          links
          |> Enum.reduce(
            Multi.new(),
            &Multi.insert(
              &2, 
              &1, 
              Ecto.build_assoc(category, :repo, %{path: &1}),
              on_conflict: :nothing,
              conflict_target: :path
            )
          )
        end)
      end)
    |> Repo.transaction()
  end

  defp fetch_repos_and_insert_to_db() do 
    query = from(r in Category.Repo, select: r.path)
    paths = Repo.all(query)

    paths
      |> Enum.each(fn path -> 
        case fetch_repo(path) do
          {:ok, response} ->

            repo_changeset = Category.Repo.changeset(
              %Category.Repo{}, 
              %{
                name: response.body["name"],
                description: response.body["description"],
                stars: response.body["stargazers_count"],
                last_commited: response.body["pushed_at"],
                path: path
              }
            )

            Repo.insert(
              repo_changeset,
              on_conflict: {:replace, [:name, :description, :stars, :last_commited, :updated_at]},
              conflict_target: :path
            )

          {:error, _} -> Logger.debug "Can't fetch repo with path: #{inspect(path)}"
        end
      end)
  end

  defp get_readme_md() do
    Tesla.get("https://raw.githubusercontent.com/h4cc/awesome-elixir/master/README.md")
  end

  defp parse_md_to_categories(md) do
    {:ok, ast, []} = Earmark.Parser.as_ast(md)
    ast
    |> Enum.reduce_while([], fn x, acc -> 
      parsed = parse_categories(x)
      if parsed == :halt do 
        {:halt, acc}
      else 
        {:cont, [parsed|acc]}
      end
    end)
    |> Enum.reverse()
    |> Enum.filter(
      fn 
        list when is_list(list) -> Enum.all?(list, fn x -> x !== :anchor end)
        x -> x !== nil 
      end)
    |> Enum.chunk_every(3, 3, :discard)
    |> Enum.filter(fn [_name, _desc, links] -> length(links) !== 0 end)
    |> Enum.map(fn [name, desc, links] -> 
      {:category, name, desc, links}
     end)
  end

  defp parse_categories(node) do
    case node do
      {"h1", [], ["Resources"], %{}} -> :halt
      {"h2", [], [category], %{}} -> category
      {"p", [], [{"em", [], [description], %{}}], %{}} -> description
      #description with link
      {"p", [], [{"em", [], [a, {"a", _, [b], %{}}, c], %{}}], %{}} -> a <> b <> c
      {"ul", [], repos, %{}} -> 
        repos
        |> Enum.map(fn repo -> parse_repos repo end)
        |> Enum.filter(fn repo -> repo != nil end)
      _ -> nil
    end
  end

  defp parse_repos(node) do
    case node do
      {"li", [], [{"a", [{"href", link}], [_name], %{}} | _description], %{}} 
        -> cond do 
          String.starts_with?(link, "https://github.com") -> String.replace(link, "https://github.com/", "")
          String.starts_with?(link, "#") -> :anchor
          true -> nil
          end
      _ -> nil
    end
  end

  defp fetch_repo(path) do
    [token: token] = Application.get_env(:awesome_elixir, :github_api)

    middleware = [
      {Tesla.Middleware.BaseUrl, "https://api.github.com"},
      {Tesla.Middleware.Headers, [{"user-agent", "Awesome-Elixir-App"}]},
      {Tesla.Middleware.BearerAuth, token: token},
      Tesla.Middleware.FollowRedirects,
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Retry,
        delay: 500,
        max_retries: 2,
        max_delay: 4_000,
        should_retry: fn
          {:ok, %{status: status}} when status in [400, 500] -> true
          {:ok, _} -> false
          {:error, _} -> true
        end
      }
    ]

    client = Tesla.client(middleware)
    Tesla.get(client, "/repos/" <> path)
  end

  defp create_category({:category, name, desc, _links}) do
    Category.changeset(%Category{}, %{name: name, description: desc})
  end

end
