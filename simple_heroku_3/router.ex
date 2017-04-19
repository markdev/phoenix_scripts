defmodule MyApplication.Router do
  use MyApplication.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :with_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug MyApplication.CurrentUser
  end

  pipeline :login_required do
    plug Guardian.Plug.EnsureAuthenticated,
         handler: MyApplication.GuardianErrorHandler
  end

  pipeline :admin_required do
    plug MyApplication.CheckAdmin
  end

  scope "/", MyApplication do
    pipe_through [:browser, :with_session] # Use the default browser stack

    get "/", PageController, :index

    resources "/users", UserController, only: [:show, :new, :create]

    resources "/sessions", SessionController, only: [:new, :create, :delete]

    # guest zone
    scope "/", MyApplication do
      pipe_through [:browser, :with_session]
      get "/", PageController, :index
      resources "/sessions", SessionController, only: [:new, :create, 
                                                       :delete]
      resources "/users", UserController, only: [:new, :create]
      # registered user zone
      scope "/" do
        pipe_through [:login_required]
        resources "/users", UserController, only: [:show] do
          resources "/posts", PostController
        end
        # admin zone
        scope "/admin", Admin, as: :admin do
          pipe_through [:admin_required]
          resources "/users", UserController, only: [:index, :show] do
            resources "/posts", PostController, only: [:index, :show]
          end
        end
      end
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", MyApplication do
  #   pipe_through :api
  # end
end
