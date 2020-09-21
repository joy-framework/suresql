(declare-project
  :name "suresql"
  :description "A sql library for janet"
  :dependencies ["https://github.com/joy-framework/tester"
                 "https://github.com/janet-lang/sqlite3"
                 "https://github.com/andrewchambers/janet-pq"]
  :author "Sean Walker"
  :license "MIT"
  :url "https://github.com/joy-framework/suresql"
  :repo "git+https://github.com/joy-framework/suresql")

(declare-source
  :source @["src/suresql/suresql.janet"])

(phony "watch" []
  (os/shell "find . -name '*.janet' | entr -r -d jpm test"))
