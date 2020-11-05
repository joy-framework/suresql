(declare-project
  :name "suresql"
  :description "A sql library for janet"
  :dependencies ["https://github.com/joy-framework/tester"]
  :author "Sean Walker"
  :license "MIT"
  :url "https://github.com/joy-framework/suresql"
  :repo "git+https://github.com/joy-framework/suresql")

(declare-source
  :source @["src/"])

(phony "tests" []
  (os/shell "find . -name '*.janet' | entr -c jpm test"))
