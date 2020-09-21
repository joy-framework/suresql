(def database-url (os/getenv "DATABASE_URL"))
(def postgres? (string/has-prefix? "postgres" (or database-url "")))


(import pq)
(import sqlite3)


(defn- fn? [str]
  (string/has-prefix? "-- fn:" str))


(defn- name? [str]
  (string/has-prefix? "-- name:" str))


(defn- sql? [str]
  (not (string/has-prefix? "--" str)))


(defn- sql-params [args]
  (let [[arg] args]
    (if (dictionary? arg)
      arg
      args)))


(defn- query [str]
  (let [lines (string/split "\n" str)
        name (->> (filter name? lines) (map |(string/replace "-- name: " "" $)) first)
        f (->> (filter fn? lines) (map |(string/replace "-- fn: " "" $)) first)
        sql (-> (filter sql? lines)
                (string/join " "))]
    {:sql (string sql ";")
     :fn f
     :name name}))


(defn- query-fn [conn {:sql sql :fn f :name name}]
  (fn [& args]
    (let [func (when f (eval-string f))
          rows (if (not postgres?)
                 (sqlite3/eval conn sql (sql-params args))
                 (cond
                   (or (string/has-prefix? "create table" sql)
                       (string/has-prefix? "drop table" sql))
                   (pq/exec conn sql ;args)

                   :else
                   (pq/all conn sql ;args)))]
      (if (function? func)
        (func rows)
        rows))))


(defn defqueries [sql-file opts]
  (default opts {})

  (let [{:connection connection} opts
        queries (->> sql-file
                     slurp
                     (string/split "\n\n")
                     (map query))]

    (loop [q :in queries]
      (let [{:name name} q]
        (defglobal (symbol name) (query-fn connection q))))))
