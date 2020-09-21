(import tester :prefix "" :exit true)
(import sqlite3)
(import ./users)

(users/drop-table)
(users/create-table)

(deftest
  (test "insert"
    (is (deep= @[]
               (users/insert {:name "sean" :active 1}))))


  (test "select"
    (is (= {:id 1 :name "sean" :active 1}
           (users/find 1))))


  (test "where"
    (is (deep= @[{:id 1 :name "sean" :active 1}]
               (users/where {:id 1}))))


  (test "update"
    (is (deep= @[]
               (users/update {:name "sean" :active 0 :id 1}))))


  (test "delete"
    (is (deep= @[]
               (users/delete 1)))))

