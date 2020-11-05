(import tester :prefix "" :exit true)
(import ./users)

(var sqlite-installed? false)
(try
  (do
    (import sqlite3)
    (set sqlite-installed? true))
  ([_]))

(when sqlite-installed?
  (users/drop-table)
  (users/create-table)

  (defsuite "sqlite"
    (test "insert"
      (is (deep= @{:name "sean" :active 1 :id 1}
                 (users/insert {:name "sean" :active 1}))))


    (test "select"
      (is (deep= @{:id 1 :name "sean" :active 1}
                 (users/find 1))))


    (test "where"
      (is (deep= @[@{:id 1 :name "sean" :active 1}]
                 (users/where {:id 1}))))


    (test "update"
      (is (deep= @[]
                 (users/update {:name "sean" :active 0 :id 1}))))


    (test "delete"
      (is (deep= @[]
                 (users/delete 1))))))
