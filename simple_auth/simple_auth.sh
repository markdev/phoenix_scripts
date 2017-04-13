# /bin/bash

cd ../..

# Create the user model
mix phoenix.gen.model User users email:string name:string password_hash:string is_admin:boolean
# add null: false
sed -ie '6s/$/, null: false/' $(pwd)/$(find priv/repo/migrations/ -name "*create_user*")
# add create unique_index
sed -ie '11s/$/\
      create unique_index(:users, [:email])/' $(pwd)/$(find priv/repo/migrations/ -name "*create_user*")

# Create posts model
mix phoenix.gen.model Post posts title:string body:text user_id:references:users

# Run migrations
mix ecto.migrate

cd -   