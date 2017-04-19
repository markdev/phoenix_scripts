# /bin/bash

echo "Initializing simple heroku 2";

cd ../..
printf '\n%s\n%s\n' '# Phoenix_scripts' '/phoenix_scripts' >> .gitignore
git init && git add . && git commit -m "Initial commit of Phoenix app"

curl http://www.apache.org/licenses/LICENSE-2.0.txt > LICENSE
git add LICENSE && git commit -m "Add Apache License 2.0"

cd -

###### Tiansu config
cp package.json ../../package.json
echo "package.json copied";

cp brunch-config.js ../../brunch-config.js
echo "brunch-config.js copied";

cp app.js ../../web/static/js/app.js
echo "app.js copied";

mkdir ../../web/static/scss

cp app.scss ../../web/static/scss/app.scss
echo "app.scss copied";

cp index.html.eex ../../web/templates/page/index.html.eex
echo "index.html.eex copied";

cd ../..
npm install
cd -
######





######## Simple Auth
cd ../..
SEDSTRONE=$(sed '9q;d' config/config.exs)
LOWER=$(echo $SEDSTRONE | awk -F ':|,' '{print $2}')

SEDSTRTWO=$(sed '33q;d' web/web.ex) 
UPPER=$(echo $SEDSTRTWO | awk -F 'alias|Repo' '{print $2}' | sed 's/.$//')
cd -


# Battle plan
# 1. Migrations (user and post)
# Create the user model
cd ../..
mix phoenix.gen.model User users email:string name:string password_hash:string is_admin:boolean
# add null: false
sed -i '' '6s/$/, null: false/' $(pwd)/$(find priv/repo/migrations/ -name "*create_user*")
# add create unique_index
sed -i '' '12s/$/\
      create unique_index(:users, [:email])/' $(pwd)/$(find priv/repo/migrations/ -name "*create_user*")
mix phoenix.gen.model Post posts title:string body:text user_id:references:users
cd -
echo "Completed -- 1: Migrations";


# 2. mix.exs Dependencies (comeonin and guardian)
# Add comeonin dependency
sed -i '' "22s|:postgrex|:postgrex, :comeonin|g" $(pwd)/../../mix.exs
sed -i '' '40s|]$|,\
     {:comeonin, "~> 2.5"}]|g' $(pwd)/../../mix.exs
# Add guardian dependency
sed -i '' '41s|]$|,\
     {:guardian, "~> 0.12.0"}]|g' $(pwd)/../../mix.exs
echo "Completed -- 2: Dependencies";


# 3. config
# Add config/config.exs
cp config/config.exs $(pwd)/../../config/config.exs
sed -i '' "s|my_application|${LOWER}|g" $(pwd)/../../config/config.exs
sed -i '' "s|MyApplication|${UPPER}|g" $(pwd)/../../config/config.exs
echo "Completed -- 3: config";

# 4. seeds
echo "TODO: -- 4: seeds";

# 5. mkdir -p web/files
for f in $(find web | awk '!/.eex/ && !/.ex/'); 
	do 
		mkdir -p "../../"${f}; 
	done

# 5b. cp web/files
for f in $(find web | awk '/.eex/ || /.ex/'); 
	do 
		cp ${f} "../../"${f}; 
	done

# 5a. sed web/files
perl -pi -e "s/MyApplication/${UPPER}/g" `find ../../web -name "*.ex" -or -name "*.eex"`
echo "Completed -- 5: mv web files";






cd ../..
mix deps.get
mix ecto.create
mix ecto.migrate

heroku create
HEROKUURL=$(heroku info -s | grep web_url | cut -d= -f2 | awk -F '//|/' '{print $2}')

SEDSTRONE=$(sed '9q;d' config/config.exs)
LOWER=$(echo $SEDSTRONE | awk -F ':|,' '{print $2}')

SEDSTRTWO=$(sed '33q;d' web/web.ex) 
UPPER=$(echo $SEDSTRTWO | awk -F 'alias|Repo' '{print $2}' | sed 's/.$//')

cp phoenix_scripts/simple_heroku/config/prod.exs config/prod.exs
echo "copied prod.exs";

sed -i '' "s|my-application-url|${HEROKUURL}|g" config/prod.exs
sed -i '' "s/my_application/${LOWER}/g" config/prod.exs
sed -i '' "s/MyApplication/${UPPER}/g" config/prod.exs


cp phoenix_scripts/simple_heroku_2/Procfile ./Procfile
echo "copied Procfile";
cp phoenix_scripts/simple_heroku_2/elixir_buildpack.config ./elixir_buildpack.config
echo "copied elixir_buildpack";
sed -i '' '8s/.*/transport :websocket, Phoenix.Transports.WebSocket, timeout: 45_000/' $(pwd)/web/channels/user_socket.ex
echo "added websocket timeout";


heroku buildpacks:add https://github.com/HashNuke/heroku-buildpack-elixir
heroku buildpacks:add https://github.com/gjaldon/phoenix-static-buildpack
heroku addons:create heroku-postgresql
echo "added heroku buildpacks and addons";
# heroku addons:create heroku-postgresql:hobby-dev
# heroku config:set POOL_SIZE=18
# heroku run "POOL_SIZE=2 mix hello_phoenix.task"


SECRETLINE=$(sed '12q;d' config/prod.secret.exs)
THESECRET=$(echo $SECRETLINE | awk -F '"|"' '{print $2}')
heroku config:set SECRET_KEY_BASE="${THESECRET}"
echo "added secretlines";

git add . && git commit -m "Adds heoku config"
git push heroku master

heroku run mix ecto.create
echo "IGNORE THE RED ERROR MESSAGE ABOVE";
heroku run mix ecto.migrate
heroku open
