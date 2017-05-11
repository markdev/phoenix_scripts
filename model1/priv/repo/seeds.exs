MyApplication.Repo.delete_all MyApplication.User

MyApplication.User.changeset(%MyApplication.User{}, %{name: "Mark", email: "mark.karavan@gmail.com", password: "password", password_confirmation: "password", admin: true})
|> MyApplication.Repo.insert!

MyApplication.User.changeset(%MyApplication.User{}, %{name: "Guest", email: "guest@example.org", password: "password", password_confirmation: "password", admin: false})
|> MyApplication.Repo.insert!