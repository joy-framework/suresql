(import tester :prefix "" :exit true)
(import ./users-2 :as users)

(var sqlite-installed? false)
(try
  (do
    (import sqlite3)
    (set sqlite-installed? true))
  ([_]))

(def connection-string "sqlite-2.sqlite3")

(when sqlite-installed?
  (with [db (sqlite3/open connection-string)]
    (users/drop-table db)
    (users/create-table db))

  (defsuite "sqlite-2"
    (test "insert"
      (is (deep= @{:id 1 :name "sean" :active 1}
                 (with [db (sqlite3/open connection-string)]
                   (users/insert db {:name "sean" :active 1})
                   (users/last-inserted db)))))


    (test "select"
      (is (deep= @{:id 1 :name "sean" :active 1}
                 (with [db (sqlite3/open connection-string)]
                   (users/find db 1)))))


    (test "where"
      (is (deep= @[@{:id 1 :name "sean" :active 1}]
                 (with [db (sqlite3/open connection-string)]
                   (users/where db {:id 1})))))


    (test "update"
      (is (deep= @{:id 1 :name "sean" :active 0}
                 (with [db (sqlite3/open connection-string)]
                   (users/update db {:name "sean" :active 0 :id 1})
                   (users/find db 1)))))


    (test "delete"
      (is (deep= @[]
                 (with [db (sqlite3/open connection-string)]
                   (users/delete db 1)))))

    (test "with transaction"
      (is (= 1
             (do
               (var num-users 0)
               (with [db (sqlite3/open connection-string)]
                 (users/begin-transaction db)
                 (users/insert db {:name "test" :active 1})
                 (let [user (users/last-inserted db)]
                   (users/update db (put user :name "test1")))
                 (users/delete db)
                 (set num-users (users/count db))
                 (users/end-transaction db))
               num-users))))))
