require_relative '../../db/entity'

class DossierData
  class << self
    def populate_user
      Entity.users.find_or_create({ login: 'testdude', token: 'abc123' })
    end

    def populate_session
      testdude = populate_user
      Entity.sessions.delete_by_user_id testdude[:id]
      Entity.sessions.create testdude[:id]
    end

    def populate_repos
      user = populate_user
      repos = ('a'..'z').to_a.map.with_index do |letter, idx| 
        { type: 'GITHUB', owner: 'testdude', name: "#{letter}_repo", url: 'http://www.google.com', resource_id: "#{idx}" }
      end
      ids =  Entity.repos.sync repos
      user_repos = ids.map do |id|
        { user_id: user[:id], repo_id: id }
      end
      Entity.users_repos.sync user_repos
    end
  end
end