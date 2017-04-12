# /bin/bash
heroku create --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git"
heroku buildpacks:add https://github.com/gjaldon/heroku-buildpack-phoenix-static.git


# Fix prod.exs
sed '16s/.*/url: [scheme: "https", host: "$(heroku info -s | grep web_url | cut -d= -f2)", port: 443], force_ssl: [rewrite_on: [:x_forwarded_proto]],' $(pwd)/config/prod.exs

# Copy Profile
cp Procfile ../../Procfile
echo "copied Procfile";

# Copy elixir_buildpack
cp elixir_buildpack.config ../../elixir_buildpack.config
echo "copied elixir_buildpack";

# Go to root directory
cd ../../

# Add socket timeout
sed '8s/.*/transport :websocket, Phoenix.Transports.WebSocket, timeout: 45_000/' $(pwd)/web/channels/user_socket.ex

