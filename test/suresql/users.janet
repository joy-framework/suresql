(import "src/suresql/init" :prefix "")

(var sqlite3/open identity)
(def database-url "test.sqlite3")

(try!
  (import sqlite3))

(defqueries "sql/users.sql"
            {:connection (sqlite3/open "test.sqlite3")})
