Given /I am logged in/ do 
  visit(BasePage) do |page|
    page.browser.cookies.add :session, @session[:uuid], path: '/', expires: (Time.now + 100000), secure: false
    page.browser.refresh
  end
end
