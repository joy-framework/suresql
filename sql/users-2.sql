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
limit 1

-- name: last-inserted
-- fn: first
select *
from users
where rowid in (
  select last_insert_rowid()
)
limit 1

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
delete
from users
where id = ?

-- name: begin-transaction
begin transaction;

-- name: end-transaction
end transaction;

-- name: count
-- fn: |(-> $ first (get :num))
select count(id) as num from users;
