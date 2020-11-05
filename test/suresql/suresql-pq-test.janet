(import tester :prefix "" :exit true)
(import ./pq-users :as users)

(var pq-installed? false)
(try
  (do
    (import pq)
    (set pq-installed? true))
  ([_]))

(when pq-installed?
  (users/drop-table)
  (users/create-table)

  (defsuite "postgres"
    (test "insert"
      (is (deep= @{:id 1 :name "sean" :active 1}
                 (users/insert "sean" 1))))


    (test "select"
      (is (deep= @{:id 1 :name "sean" :active 1}
                 (users/find 1))))


    (test "where"
      (is (deep= @[@{:id 1 :name "sean" :active 1}]
                 (users/active?))))


    (test "update"
      (is (deep= @{:id 1 :name "sean" :active 0}
                 (users/update 0 "sean" 1))))


    (test "delete"
      (is (deep= @{:id 1 :name "sean" :active 0}
                 (users/delete 1))))))
