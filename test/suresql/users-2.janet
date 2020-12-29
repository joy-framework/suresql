(import "src/suresql/init" :prefix "")

(def database-url "users-2.sqlite3")

(try!
  (import sqlite3))

(defqueries "sql/users-2.sql")
