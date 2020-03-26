When /I click next page/ do
  on(HomePage) do |page|
    @current_repos = page.repo_infos_elements.map(&:text)
    page.next_page
  end
end

Then /I see the next page of results/ do 
  on(HomePage) do |page|
    repo_names = page.repo_infos_elements.map(&:text)
    expect(@current_repos).not_to eql(repo_names)
  end
end
