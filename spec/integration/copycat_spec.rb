require 'spec_helper'

feature "displaying copy" do

  #body = %| 
  #   <h2> Hello World </h2> 
  #   <div> 
  #     <%= Copybara.t('sample_copy') %>
  #   </div> 
  # |

  before(:each) { Copycat.clear_cache } 

  it "displays the default when no copycat_translation is present" do
    visit root_path
    assert_match "Hello World", body
    assert_match "sample_copy", body
  end

  it "displays the copycat_translation when it's available" do
    Factory(:copycat_translation, :key => "sample_copy", :value => "copyfoo")
    visit root_path 
    assert_match "Hello World", body
    assert_match "copyfoo", body
  end

end

feature "creating copy" do

  before(:each) { Copycat.clear_cache } 
  
  it "creates an empty copycat_translation when we render a page that calls Copycat with a new key" do
    assert CopycatTranslation.count == 0
    visit root_path
    assert CopycatTranslation.count == 1
    assert CopycatTranslation.first.key = "sample_copy"
    assert CopycatTranslation.first.value = "Missing copy for sample_value"
  end

end

feature "cacheing copy" do
  
  before(:each) { Copycat.clear_cache }

  it "has no cache for a new key until we visit the page" do
    Factory(:copycat_translation, :key => "sample_copy", :value => "copyfoo")
    assert Copycat.cache["sample_copy"].nil?
    visit root_path
    assert Copycat.cache["sample_copy"] == "copyfoo"
  end

  it "clears the cache when we update a copycat_translation" do
    cct = Factory(:copycat_translation, :key => "sample_copy", :value => "copyfoo")
    visit root_path 
    assert Copycat.cache["sample_copy"] == "copyfoo"
    visit "/copycat_translations/#{cct.id}/edit"
    click_button "Update"
    assert Copycat.cache["sample_copy"].nil?
  end

end

feature "downloading and uploading yaml files" do

  it "is unchanged when we download yaml, delete everything, and upload yaml" do
    Factory(:copycat_translation, :key => "a.foo1", :value => "bar1")
    Factory(:copycat_translation, :key => "a.foo2", :value => "bar2")
    Factory(:copycat_translation, :key => "a.b.foo3", :value => "bar3")
    Factory(:copycat_translation, :key => "c.foo4", :value => "bar4")
    Factory(:copycat_translation, :key => "foo5", :value => "bar5")
    assert CopycatTranslation.count == 5

    visit "/copycat_translations.yaml"
    yaml = page.text
    CopycatTranslation.all.map(&:destroy)
    assert CopycatTranslation.count == 0

    CopycatTranslation.import_yaml(YAML.load(StringIO.new(yaml)))
    assert CopycatTranslation.find_by_key("a.foo1").value == "bar1"
    assert CopycatTranslation.find_by_key("a.foo2").value == "bar2"
    assert CopycatTranslation.find_by_key("a.b.foo3").value == "bar3"
    assert CopycatTranslation.find_by_key("c.foo4").value == "bar4"
    assert CopycatTranslation.find_by_key("foo5").value == "bar5"
    assert CopycatTranslation.count == 5
  end

end

