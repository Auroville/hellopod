# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Hellopod.Repo.insert!(%Hellopod.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


Hellopod.Repo.insert!(%Hellopod.Content.Article{title: "Hello world 1", body: "Sample text 1"})

Hellopod.Repo.insert!(%Hellopod.Content.Article{title: "Hello world 2", body: "Sample text 2"})
