defmodule TrendingHashtag.Repo do
  use Ecto.Repo,
    otp_app: :trending_hashtag,
    adapter: Ecto.Adapters.Postgres
end
