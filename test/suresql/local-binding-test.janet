(import ../../src/suresql)
(import ./users)
(import tester :prefix "" :exit true)
(import sqlite3 :as sqlite)


(defsuite "local bindings"
  (def fns (suresql/defqueries "sql/one.sql"
                               {:connection (sqlite/open "test.db")}))

  (test "defquery returns functions"
        (is (deep= @{:14 14}
                   ((fns :one) {})))))
