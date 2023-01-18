(import ../../src/suresql :prefix "")

(var pq/connect identity)
(def database-url "postgres://localhost:5432/suresql_test_db")

(try!
  (import pq)
  (os/shell "dropdb suresql_test_db")
  (os/shell "createdb suresql_test_db"))

(defqueries "sql/pq-users.sql"
            {:connection (pq/connect database-url)})
