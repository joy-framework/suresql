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


(defn- connection? [conn]
  (or (sqlite? conn)
      (pq? conn)))


(defn- table/slice [dict ks]
  (var output @{})

  (each k ks
    (put output k (get dict k)))

  output)


(defn- columns [sql]
  (let [cols (peg/match ~{:main (some (choice :col 1))
                          :col (sequence ":" (capture (some (if (choice :w "_") 1))))}
                        sql)]
    (map keyword (or cols []))))


(defn- sql-params [args columns]
  (let [[arg] args]
    (if (dictionary? arg)
      (if columns (table/slice arg columns) arg)
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


(defn- query [conn sql f args columns]
  (let [func (when f (eval-string f))
        rows (cond
               (sqlite? conn)
               (map |(table ;(kvs $)) (sqlite3/eval conn sql (sql-params args columns)))

               (pq? conn)
               (pq/all conn sql ;args)

               :else
               (error (string/format "Unsupported connection type %q" conn)))]
    (if (function? func)
      (func rows)
      rows)))


(defn- query-fn [connection {"sql" sql "fn" f}]
  (let [columns (columns sql)]
    (fn [& args]
      (cond
        (nil? connection)
        (let [[conn] args]
          (query conn sql f (drop 1 args) columns))

        :else
        (if (connection? (last args))
            (query (last args) sql f (filter |(not (connection? $)) args)
                                     columns)
            (query connection sql f args columns))))))


(defn defqueries [sql-file &opt options]
  (let [queries (->> (slurp sql-file)
                     (parse-queries))
        connection (get options :connection)
        connected-queries @{}]

    (loop [q :in queries]
      (let [{"name" name} q
            q-fn (query-fn connection q)]
        (defglobal (symbol name) q-fn)
        (put connected-queries
             (keyword name)
             q-fn)))
    connected-queries))
