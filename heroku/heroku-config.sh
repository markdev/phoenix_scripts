# /bin/bash

# Fix prod.exs
cp prod.exs ../../config/prod.exs
echo "copied prod.exs";

# Add socket timeout
sed '8s/.*/transport :websocket, Phoenix.Transports.WebSocket, timeout: 45_000/' /Users/karavanm/end2end/_sandbox/some_shit_9/web/channels/user_socket.ex

cp Procfile ../../Procfile
echo "copied Procfile";

cp elixir_buildpack.config ../../elixir_buildpack.config
echo "copied elixir_buildpack";
