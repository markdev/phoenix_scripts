# /bin/bash

# Must start at the initialize directory
cd ../..

# Set script variables
MYDIR=$(pwd)

SEDSTRONE=$(sed '9q;d' config/config.exs)
LOWER=$(echo $SEDSTRONE | awk -F ':|,' '{print $2}')

SEDSTRTWO=$(sed '33q;d' web/web.ex) 
UPPER=$(echo $SEDSTRTWO | awk -F 'alias|Repo' '{print $2}' | sed 's/.$//')

SECRETLINE=$(sed '12q;d' config/prod.secret.exs)
THESECRET=$(echo $SECRETLINE | awk -F '"|"' '{print $2}')

# Get branches from user
printf "\n";
printf "Initializing Herokufy\n\n";
printf "Enter the git branch names you want to create as Heroku apps (comma-delimited, no spaces)\n";
printf "FOR EXAMPLE: \"staging,production\"\n";
read BRANCHSTRING;

#copy config/prod.exs
cp "$MYDIR"/phoenix_scripts/herokufy/config/prod.exs config/prod.exs
echo "copied prod.exs";
sed -i '' "s/my_application/${LOWER}/g" config/prod.exs
sed -i '' "s/MyApplication/${UPPER}/g" config/prod.exs

# Create Heroku Procfile
touch "$MYDIR"/Procfile
echo "web: MIX_ENV=prod mix phoenix.server" > Procfile
echo "created Procfile";

# Create elixir_buildpack
touch "$MYDIR"/elixir_buildpack.config
echo "config_vars_to_export=(MY_VAR)" > Procfile
echo "created elixir_buildpack";

# Add socket timeout
sed -i '' '8s/.*/transport :websocket, Phoenix.Transports.WebSocket, timeout: 45_000/' "$MYDIR"/web/channels/user_socket.ex
echo "added websocket timeout";

IFS=',' read -ra ADDR <<< "$BRANCHSTRING"
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

	heroku config:set --app "$APP" SECRET_KEY_BASE="\"${THESECRET}\""

	# TODO: FIgure out what to do with Procfile
	# echo "" >> "$MYDIR"/Procfile
	# echo "# Procfile for $i" >> "$MYDIR"/Procfile
	# echo "web: MIX_ENV=$i mix phoenix.server" >> "$MYDIR"/Procfile

	git add . && git commit -m "Adds heroku config"
	git push "$i" master

	heroku run --app "$APP" mix ecto.create
	heroku run --app "$APP" mix ecto.migrate
done


