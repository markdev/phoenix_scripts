# /bin/bash

# cd ../..
# SEDSTRONE=$(sed '9q;d' config/config.exs)
# LOWER=$(echo $SEDSTRONE | awk -F ':|,' '{print $2}')

# SEDSTRTWO=$(sed '33q;d' web/web.ex) 
# UPPER=$(echo $SEDSTRTWO | awk -F 'alias|Repo' '{print $2}' | sed 's/.$//')
# cd -

echo "Initializing simple heroku";