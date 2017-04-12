# /bin/bash
cd ../..
heroku create --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git"
heroku buildpacks:add https://github.com/gjaldon/heroku-buildpack-phoenix-static.git
cd -

# Fix prod.exs
cp prod.exs ../../config/prod.exs
echo "copied prod.exs";

cd ../..
HEROKUURL=$(heroku info -s | grep web_url | cut -d= -f2 | awk -F '//|/' '{print $2}')

SEDSTRONE=$(sed '9q;d' config/config.exs)
LOWER=$(echo $SEDSTRONE | awk -F ':|,' '{print $2}')

SEDSTRTWO=$(sed '33q;d' web/web.ex) 
UPPER=$(echo $SEDSTRTWO | awk -F 'alias|Repo' '{print $2}' | sed 's/.$//')

sed -ie "s|my-application-url|${HEROKUURL}|g" config/prod.exs
sed -ie "s/my_application/${LOWER}/g" config/prod.exs
sed -ie "s/MyApplication/${UPPER}/g" config/prod.exs
cd -

# Copy Profile
cp Procfile ../../Procfile
echo "copied Procfile";

# Copy elixir_buildpack
cp elixir_buildpack.config ../../elixir_buildpack.config
echo "copied elixir_buildpack";

# Add socket timeout
cd ../../
sed '8s/.*/transport :websocket, Phoenix.Transports.WebSocket, timeout: 45_000/' $(pwd)/web/channels/user_socket.ex
cd -

# Addon config
cd ../..
heroku addons:create heroku-postgresql:hobby-dev
heroku config:set POOL_SIZE=18
heroku run "POOL_SIZE=2 mix hello_phoenix.task"

SECRET=$(mix phoenix.gen.secret)
heroku config:set SECET_KEY_BASE="${SECRET}"

git add . 
git commit -m "heroku config" 
git push heroku master
cd -