require_relative 'db'

class Repos
  class << self
    def get_all
      sql = <<-END
        select * from repos
      END
      Database.resource[sql].all
    end

    def sync(repos) 
      Database.resource[:repos]
      .returning(:id)
      .insert_conflict(
        constraint: :unique_repo,
        update: {
          owner: Sequel[:excluded][:owner],
          name: Sequel[:excluded][:name],
          url: Sequel[:excluded][:url]
        }
      )
      .multi_insert(repos)
    end

    def belong_to_user(repo_id, user_id)
      sql = <<-END
        select r.id from repos as r
        inner join users_repos as up
        on up.repo_id = r.id 
        where up.user_id = :user
        and r.id = :repo
      END
      Database.resource[sql, {repo: repo_id, user: user_id }].first
    end

    def count_by_user(user_id)
      sql = <<-END
        select count(r.id) as count
        from repos as r
        inner join users_repos as up
        on up.repo_id = r.id
        where up.user_id = ?
      END
      Database.resource[sql, user_id].first
    end


    def find_by_user(payload)
      sql = <<-END
        select r.id, r.name, r.owner,
        coalesce(
          json_agg(
            json_build_object('id', rp.id, 'name', rp.name, 'framework', rp.framework, 'token', rp.token)
          ) filter (where rp.id is not null),
          '[]'
        ) as reports
        from repos as r
        left join reports as rp
        on r.id = rp.repo_id
        inner join users_repos as up
        on up.repo_id = r.id
        where up.user_id = :id
        group by r.id, r.name, r.owner
        order by r.owner, r.name asc
        limit :per_page offset :offset
      END
      Database.resource[sql, payload].all
    end

  end
end