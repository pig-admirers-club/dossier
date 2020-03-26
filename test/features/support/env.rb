require 'cucumber'
require 'dotenv'
require 'page-object'
require 'page-object/page_factory'
require 'watir'
require 'watir-scroll'
require_relative '../../lib/dossier_data'
require_relative 'pages/base'

Dotenv.load "#{File.dirname(__FILE__)}/../../../.env"
browser = Watir::Browser.new :chrome

World(PageObject::PageFactory)

ENV['test'] = 'true'
`rake db:migrate`

Before do
  @browser = browser
  DossierData.populate_repos
  @session = DossierData.populate_session
end

at_exit do 
  `rake db:clean`
end