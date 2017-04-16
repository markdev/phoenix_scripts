# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :simple_auth,
  ecto_repos: [MyApplication.Repo]

# Configures the endpoint
config :simple_auth, MyApplication.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "yAz5RhEjmtbvahJzAg3qhBb3U1qQBUXmTpsTIrDO5EPQffTvZgMLHmIRCRv47rnj",
  render_errors: [view: MyApplication.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MyApplication.PubSub, adapter: Phoenix.PubSub.PG2]

config :guardian, Guardian,
 issuer: "MyApplication.#{Mix.env}",
 ttl: {30, :days},
 verify_issuer: true,
 serializer: MyApplication.GuardianSerializer,
 secret_key: to_string(Mix.env) <> "SuPerseCret_aBraCadabrA"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
