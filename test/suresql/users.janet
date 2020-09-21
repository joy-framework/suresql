(import sqlite3)

(os/setenv "DATABASE_URL" "test.sqlite3")

(import "src/suresql/suresql" :prefix "")

(defqueries "sql/users.sql"
            {:connection (sqlite3/open "test.sqlite3")})
