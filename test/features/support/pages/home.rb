class HomePage < BasePage
  
  divs :repo_infos, class: 'repo__info'

  def next_page
    browser.lis(class: 'uk-pagination-previous')[-1].a.click
  end
end