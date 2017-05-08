# /bin/bash

for app in $(heroku apps); do 
   if [[ "$app" -ne "apple-cupcake-79503" ]]; then 
      heroku apps:destroy --app $app --confirm $app;
   fi 
done
