get "/hello" do
  send_resp(conn, 200, "<h1>world</h1>")
end

def getLatestCommit(username) do
  client = Tentacat.Client.new(%{access_token: Commit.Keys.github_key})
  [repo | _] = Tentacat.Repositories.list_users(username, client, [sort: "pushed"])
  repoName = Map.get repo, "name"
  [commit | _] = Tentacat.Commits.list(username, repoName, client)
  commit
end

# Send a plain-text response of just the message
get "/:name" do
  message = Map.get (Map.get getLatestCommit(name), "commit"), "message"
  conn
  |> send_resp(200, message)
  |> halt
end

# Send JSON response
get "/json/:name" do
  conn
  |> put_resp_content_type("application/json")
  |> send_resp(200, Poison.encode!(getLatestCommit(name)))
  |> halt
end