# suresql
__A sql library for janet__

## Install

```sh
jpm install https://github.com/joy-framework/suresql
```

You will also need one of the following libraries:

```sh
jpm install http://github.com/janet-lang/sqlite3
# or
jpm install http://github.com/andrewchambers/janet-pq
```

## Create a database

suresql currently supports two databases

1. sqlite3
2. postgres

### sqlite3

Run this command to create a sqlite database in the current directory

```sh
touch todos_dev.sqlite3
```

Note: `todos_dev.sqlite3` can be any name

### postgres

Run this command to create a postgres database, assuming a running postgres server and a `createdb` cli script in the current `PATH`

```sh
createdb todos_dev
```

## Queries

Suresql doesn't abstract sql away from you, it gives you an easy [yesql](https://github.com/krisajenkins/yesql) inspired way of working *with* sql! Even migrations can happen in plain sql:

Step 1. Create a sql file wherever you want

```sql
-- sql/users.sql

-- name: create-table
create table if not exists users (
  id integer primary key, -- or serial primary key for postgres
  name text not null,
  email text unique not null
)
```

Step 2. Reference that sql file in a `.janet` file with `defqueries` (named whatever you want)

```clojure
; # users.janet
(import sqlite3)
(import suresql :prefix "")

(defqueries "sql/users.sql"
            {:connection (sqlite3/open "db.sqlite3")})
```

Step 3. Reference that janet file and start calling functions from your sql file:

```clojure
(import ./users)

(users/create-table)
```

This works for any query:

```sql
-- sql/users.sql

-- ...other queries

-- name: where
select *
from users
where name = :name

-- name: find
-- fn: first
select *
from users
where id = ?

-- name: insert
insert into users (
  email,
  name
) values (
  :email,
  :name
)

-- name: update
update users
set email = :email,
    name = :name
where id = :id

-- name: delete
delete
from users
where id = ?
```

And now `defqueries` inserts all of those named queries as functions into the `users.janet` file:

```clojure
(import ./users)

(users/insert {:name "name" :email "email"}) ; # => @[]

(users/insert {:name "name" :email "email2"}) ; # => @[]

(users/update {:name "name" :email "email1" :id 1}) ; # => @[]

(users/find 1) ; # => {:id 1 :name "name" :email "email1"}

(users/where {:name "name"}) ; # => @[{:id 1 :name "name" :email "email1"} {:id 2 :name "name" :email "email2"}]

(users/delete 1) ; # => @[]
```

You may have noticed that you can not only name sql queries, you can also pass janet functions to them with `-- fn: `

```sql
-- name: find
-- fn: first
select *
from users
where id = ?
```

This works for any janet function defined alongside `defqueries`, even your own. This function gets `eval-string`'d and takes the returned rows as an argument (if there are any).

That's it! Be *sure* to enjoy sql!
