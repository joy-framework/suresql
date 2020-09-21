-- name: create-table
create table users (
  id serial primary key,
  name text unique not null,
  active integer not null default(0)
)

-- name: drop-table
drop table if exists users

-- name: active?
select *
from users
where active = 1

-- name: find
-- fn: first
select *
from users
where id = $1

-- name: insert
-- fn: first
insert into users (
  name,
  active
) values (
  $1,
  $2
)
returning *

-- name: update
-- fn: first
update users
set active = $1,
    name = $2
where id = $3
returning *

-- name: delete
-- fn: first
delete
from users
where id = $1
returning *
