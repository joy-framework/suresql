# conditional imports
(defmacro try! [& forms]
  ~(try
    (do ,;forms)
    ([_])))

(var- pq/all (fn [& args] (print "Could not find library pq")))
(var- sqlite3/eval (fn [& args] (print "Could not find library sqlite3")))

(try! (import sqlite3))
(try! (import pq))

(defn- sqlite? [conn]
  (= :sqlite3.connection (type conn)))


(defn- sql-params [args]
  (let [[arg] args]
    (if (dictionary? arg)
      arg
      args)))


(defn- parse-queries [str]
  (let [queries-peg ~{:main (some (replace :query ,struct))
                      :query (* :name :fn :sql)
                      :name (* (constant "name") (? "\n") "--" :s* "name:" :s* (<- (to "\n")))
                      :fn (* (constant "fn") (+ (* (? "\n") "--" :s* "fn:" :s* (<- (to "\n")))
                                                (constant "")))
                      :label (* "--" :s* (+ "name" "fn") ":" :s* (to "\n"))
                      :sql (* (constant "sql") :s* (<- (+ (to :label) (* (any 1)))))}]
    (peg/match queries-peg str)))


(defn- query-fn [conn {"sql" sql "fn" f "name" name}]
  (fn [& args]
    (let [func (when f (eval-string f))
          rows (if (sqlite? conn)
                 (map |(table ;(kvs $)) (sqlite3/eval conn sql (sql-params args)))
                 (pq/all conn sql ;args))]
      (if (function? func)
        (func rows)
        rows))))


(defn defqueries [sql-file {:connection connection}]
  (let [queries (->> (slurp sql-file)
                     (parse-queries))]

    (loop [q :in queries]
      (let [{"name" name} q]
        (defglobal (symbol name) (query-fn connection q))))))
