{ name = "bot-dsl-example"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "bifunctors"
  , "control"
  , "datetime"
  , "effect"
  , "either"
  , "integers"
  , "newtype"
  , "parsing"
  , "prelude"
  , "record"
  , "transformers"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
