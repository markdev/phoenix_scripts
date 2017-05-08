# /bin/bash

# Must start at the initialize directory
cd ../..


# JUST FOR TESTING
mix phoenix.gen.html User users name:string email:string
git add . && git commit -m "Add generated User model"

sed -i '' '19s|$|\
\
		resources "/users", UserController|g' $(pwd)/web/router.ex
git add . && git commit -m "Add Users resource to browser scope"
#


MYDIR=$(pwd)

SEDSTRONE=$(sed '9q;d' config/config.exs)
LOWER=$(echo $SEDSTRONE | awk -F ':|,' '{print $2}')

SEDSTRTWO=$(sed '33q;d' web/web.ex) 
UPPER=$(echo $SEDSTRTWO | awk -F 'alias|Repo' '{print $2}' | sed 's/.$//')

printf "\n";
printf "Initializing Herokufy\n\n";
printf "Enter the git branch names you want to create as Heroku apps (comma-delimited, no spaces)\n";
printf "FOR EXAMPLE: \"staging,production\"\n";
read branchstring;

#copy files
cp "$MYDIR"/phoenix_scripts/herokufy/config/prod.exs config/prod.exs
echo "copied prod.exs";

sed -i '' "s/my_application/${LOWER}/g" config/prod.exs
sed -i '' "s/MyApplication/${UPPER}/g" config/prod.exs

touch "$MYDIR"/phoenix_scripts/herokufy/Procfile
echo "created Procfile";

cp "$MYDIR"/phoenix_scripts/herokufy/elixir_buildpack.config ./elixir_buildpack.config
echo "copied elixir_buildpack";

sed -i '' '8s/.*/transport :websocket, Phoenix.Transports.WebSocket, timeout: 45_000/' "$MYDIR"/web/channels/user_socket.ex
echo "added websocket timeout";

SECRETLINE=$(sed '12q;d' config/prod.secret.exs)
THESECRET=$(echo $SECRETLINE | awk -F '"|"' '{print $2}')
echo "$THESECRET"
heroku config:set SECRET_KEY_BASE="${THESECRET}"
echo "added secretlines";

IFS=',' read -ra ADDR <<< "$branchstring"
for i in "${ADDR[@]}"; do
    echo "CREATING" $i;
    OUTPUT=$(heroku create --remote $i)
	while read -r line; do
    	APP=$(echo $line | awk -F '|' '{print $1}' | awk -F '//|/' '{print $2}' | awk -F '.' '{print $1}');
    	echo "My app is: " $APP;
	done <<< "$OUTPUT"
	heroku buildpacks:add --app "$APP" https://github.com/HashNuke/heroku-buildpack-elixir
	heroku buildpacks:add --app "$APP" https://github.com/gjaldon/phoenix-static-buildpack
	heroku addons:create --app "$APP" heroku-postgresql

	git add . && git commit -m "Adds heroku config"
	git push "$i" master

	heroku run --app "$APP" mix ecto.create
	heroku run --app "$APP" mix ecto.migrate

	echo "" >> "$MYDIR"/Procfile
	echo "# Procfile for $i" >> "$MYDIR"/Procfile
	echo "web: MIX_ENV=$i mix phoenix.server" >> "$MYDIR"/Procfile
done




#echo $myline | awk -F '|' '{print $1}'| awk -F '//|/' '{print $2}' | awk -F '.' '{print $1}'

# cd ../..
# SEDSTRONE=$(sed '9q;d' config/config.exs)
# LOWER=$(echo $SEDSTRONE | awk -F ':|,' '{print $2}')

# SEDSTRTWO=$(sed '33q;d' web/web.ex) 
# UPPER=$(echo $SEDSTRTWO | awk -F 'alias|Repo' '{print $2}' | sed 's/.$//')
# cd -

# curl http://www.apache.org/licenses/LICENSE-2.0.txt > LICENSE
