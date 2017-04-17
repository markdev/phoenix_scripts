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
