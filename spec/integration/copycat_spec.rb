require 'spec_helper'

feature "displaying copy" do

  #foos = %| 
  #   <h2> Hello World </h2> 
  #   <div> 
  #     <%= Copybara.t('sample_copy') %>
  #   </div> 
  # |

  it "displays the default when no copybar is present" do
    visit root_path
    assert_match "Hello World", body
    assert_match "sample_copy", body
  end

  it "displays the copybar when it's available" do
    Factory(:copybar, :key => "sample_copy", :value => "copyfoo")
    visit "/foos"
    assert_match "Hello World", body
    assert_match "copyfoo", body
  end

end

feature "cacheing copy" do
  pending
  
  before { Copybara.clear_cache }

  it "has no cache for a new key until we visit the page" do
    Factory(:copybar, :key => "sample_copy", :value => "copyfoo")
    assert Copybara.cache["sample_copy"].nil?
    visit "/foos"
    assert Copybara.cache["sample_copy"] == "copyfoo"
  end

  it "clears the cache when we update a copybar" do
    copybar = Factory(:copybar, :key => "sample_copy", :value => "copyfoo")
    visit "/foos"
    assert Copybara.cache["sample_copy"] == "copyfoo"
    visit "/copybars/#{copybar.id}/edit"
    click_button "Submit"
    assert Copybara.cache["sample_copy"].nil?
  end

end

