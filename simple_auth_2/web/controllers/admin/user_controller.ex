defmodule MyApplication.Admin.UserController do
  use MyApplication.Web, :controller
  alias MyApplication.User
  
  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def show(conn, %{"id" => id}) do
	user = User |> Repo.get!(id)
	render(conn, "show.html", user: user)
  end
end