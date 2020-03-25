Given /I am logged in/ do 
  DossierData.populate_repos
  session = DossierData.populate_session
  
  visit(BasePage) do |page|
    page.browser.cookies.add :session, session[:uuid], path: '/', expires: (Time.now + 100000), secure: false
    page.browser.refresh
    sleep 100
  end
end
