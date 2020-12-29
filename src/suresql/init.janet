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


(defn- pq? [conn]
  (= :pq/context (type conn)))


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


(defn- query [conn sql f args]
  (let [func (when f (eval-string f))
        rows (cond
               (sqlite? conn)
               (map |(table ;(kvs $)) (sqlite3/eval conn sql (sql-params args)))

               (pq? conn)
               (pq/all conn sql ;args)

               :else
               (error (string/format "Unsupported connection type %q" conn)))]
    (if (function? func)
      (func rows)
      rows)))


(defn- query-fn [connection {"sql" sql "fn" f}]
  (fn [& args]
    (cond
      (nil? connection)
      (let [[conn] args]
        (query conn sql f (drop 1 args)))

      :else
      (query connection sql f args))))


(defn defqueries [sql-file &opt options]
  (let [queries (->> (slurp sql-file)
                     (parse-queries))
        connection (get options :connection)]

    (loop [q :in queries]
      (let [{"name" name} q]
        (defglobal (symbol name) (query-fn connection q))))))
