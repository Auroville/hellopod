defmodule Hellopod.Repo do
  use Ecto.Repo,
    otp_app: :hellopod,
    adapter: Ecto.Adapters.Postgres
end
