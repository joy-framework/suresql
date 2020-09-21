(import pq)

(os/setenv "DATABASE_URL" "postgres://localhost:5432/suresql_test_db")

(import "src/suresql/suresql" :prefix "")

(os/shell "dropdb suresql_test_db")
(os/shell "createdb suresql_test_db")

(defqueries "sql/pq-users.sql"
            {:connection (pq/connect "postgres://localhost:5432/suresql_test_db")})
