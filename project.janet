(declare-project
  :name "suresql"
  :description "A sql library for janet"
  :author "Sean Walker"
  :license "MIT"
  :url "https://github.com/joy-framework/suresql"
  :repo "git+https://github.com/joy-framework/suresql")

(declare-source
  :source @["src"])

(phony "tests" []
  (os/shell "find . -name '*.janet' | entr -c jpm test"))
