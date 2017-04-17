# /bin/bash

# cd ../..
# SEDSTRONE=$(sed '9q;d' config/config.exs)
# LOWER=$(echo $SEDSTRONE | awk -F ':|,' '{print $2}')

# SEDSTRTWO=$(sed '33q;d' web/web.ex) 
# UPPER=$(echo $SEDSTRTWO | awk -F 'alias|Repo' '{print $2}' | sed 's/.$//')
# cd -

echo "Initializing simple heroku";

cd ../..
git init && git add . && git commit -m "Initial commit of Phoenix app"

curl http://www.apache.org/licenses/LICENSE-2.0.txt > LICENSE
git add LICENSE && git commit -m "Add Apache License 2.0"

mix phoenix.gen.html User users name:string email:string
git add . && git commit -m "Add generated User model"

sed -i '' '19s|$|\
\
		resources "/users", UserController|g' $(pwd)/web/router.ex
git add . && git commit -m "Add Users resource to browser scope"

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

heroku buildpacks:add https://github.com/HashNuke/heroku-buildpack-elixir
heroku buildpacks:add https://github.com/gjaldon/phoenix-static-buildpack
heroku addons:create heroku-postgresql

SECRETLINE=$(sed '12q;d' config/prod.secret.exs)
THESECRET=$(echo $SECRETLINE | awk -F '"|"' '{print $2}')
heroku config:set SECRET_KEY_BASE="${THESECRET}"









# mix ecto.create
# mix ecto.migrate
# mix ecto.migrate

# heroku create
# git remote -v

# heroku buildpacks:add https://github.com/HashNuke/heroku-buildpack-elixir
# heroku buildpacks:add https://github.com/gjaldon/phoenix-static-buildpack
# heroku addons:create heroku-postgresql

# SECRET=$(mix phoenix.gen.secret)
# heroku config:set SECET_KEY_BASE="${SECRET}"

# git push heroku master

# git add .
# git commit -m "floof"
# heroku create
# heroku addons:create heroku-postgresql
# git push heroku master
# heroku run mix ecto.create

# git add .
# git commit -m "config"
# git push heroku master

# heroku run mix ecto.create
# heroku run mix ecto.migrate
# heroku open














# mix ecto.create
# mix ecto.migrate


# cd -

# cp config/prod.exs ../../config/prod.exs
# echo "copied prod.exs";

# cd ../..

# heroku create

# HEROKUURL=$(heroku info -s | grep web_url | cut -d= -f2 | awk -F '//|/' '{print $2}')

# SEDSTRONE=$(sed '9q;d' config/config.exs)
# LOWER=$(echo $SEDSTRONE | awk -F ':|,' '{print $2}')

# SEDSTRTWO=$(sed '33q;d' web/web.ex) 
# UPPER=$(echo $SEDSTRTWO | awk -F 'alias|Repo' '{print $2}' | sed 's/.$//')

# sed -i '' "s|my-application-url|${HEROKUURL}|g" config/prod.exs
# sed -i '' "s/my_application/${LOWER}/g" config/prod.exs
# sed -i '' "s/MyApplication/${UPPER}/g" config/prod.exs
# cd -




# heroku buildpacks:add https://github.com/HashNuke/heroku-buildpack-elixir
# heroku buildpacks:add https://github.com/gjaldon/phoenix-static-buildpack

# heroku addons:create heroku-postgresql

# SECRET=$(mix phoenix.gen.secret)
# heroku config:set SECET_KEY_BASE="${SECRET}"

# git add . 
# git commit -m "heroku config" 
# git push heroku master
# cd -

# git push heroku master
# heroku run mix ecto.create
# heroku run mix ecto.migrate
# heroku open