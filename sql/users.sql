-- name: create-table
create table if not exists users (
  id integer primary key,
  name text unique not null,
  active boolean not null default(0)
)

-- name: drop-table
drop table if exists users

-- name: where
select *
from users
where id = :id

-- name: find
-- fn: first
select *
from users
where id = ?

-- name: find-by-rowid
-- fn: first
select *
from users
where rowid = ?

-- name: last-inserted
-- fn: |(-> $ first (get :id) (users/find-by-rowid))
select last_insert_rowid() as id

-- name: insert
insert into users (
  name,
  active
) values (
  :name,
  :active
)

-- name: update
update users
set active = :active,
    name = :name
where id = :id

-- name: delete
delete from users where id = ?
