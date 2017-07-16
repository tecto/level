defmodule Bridge.Web.Schema.Types do
  @moduledoc """
  GraphQL type definitions.
  """

  use Absinthe.Schema.Notation

  alias Bridge.Web.Schema.Helpers

  scalar :time do
    description "ISO-8601 time"
    parse &Timex.parse(&1.value, "{ISO:Extended:Z}")
    serialize &Timex.format!(&1, "{ISO:Extended:Z}")
  end

  @desc "A user object"
  object :user do
    field :id, non_null(:id)
    field :email, non_null(:string)
    field :username, non_null(:string)
    field :first_name, :string
    field :last_name, :string
    field :time_zone, :string
    field :inserted_at, non_null(:time)
    field :updated_at, non_null(:time)

    field :team, non_null(:team) do
      resolve fn user, _, _ ->
        batch({Helpers, :by_id, Bridge.Team}, user.team_id, fn batch_results ->
          {:ok, Map.get(batch_results, user.team_id)}
        end)
      end
    end
  end

  @desc "A team object"
  object :team do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :slug, non_null(:string)
    field :inserted_at, non_null(:time)
    field :updated_at, non_null(:time)
  end

  @desc "An invitation to a team"
  object :invitation do
    field :id, non_null(:id)
    field :invitor, non_null(:user)
    field :email, non_null(:string)
    field :inserted_at, non_null(:time)
    field :updated_at, non_null(:time)
  end

  @desc "The response to inviting a user to a team"
  object :invite_user_payload do
    field :success, :boolean
    field :invitation, :invitation
    field :errors, list_of(:error)
  end

  @desc "A validation error"
  object :error do
    field :attribute, non_null(:string)
    field :message, non_null(:string)
  end
end
