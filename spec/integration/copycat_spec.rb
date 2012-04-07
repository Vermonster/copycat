#encoding: utf-8

require 'spec_helper'


feature "copycat index" do
 
  before do
    FactoryGirl.create(:copycat_translation, :key => "foo", :value => "bar")
    page.driver.browser.basic_authorize Copycat.username, Copycat.password
    visit copycat_translations_path
  end

  it "has a nav bar" do
    click_link 'Import / Export'
    click_link 'Help'
    click_link 'Search'
  end

  it "doesn't show any tokens by default" do
    page.should_not have_content 'foo'
    page.should_not have_content 'bar'
  end

  it "allows search by key" do
    fill_in 'search', :with => 'foo'
    click_button 'Search'
    page.should have_content 'foo'
    page.should have_content 'bar'
  end

  it "allows search by key" do
    fill_in 'search', :with => 'xfoo'
    click_button 'Search'
    page.should_not have_content 'foo'
    page.should_not have_content 'bar'
  end

  it "allows search by value" do
    fill_in 'search', :with => 'bar'
    click_button 'Search'
    page.should have_content 'foo'
    page.should have_content 'bar'
  end

  it "allows search by value" do
    fill_in 'search', :with => 'xbar'
    click_button 'Search'
    page.should_not have_content 'foo'
    page.should_not have_content 'bar'
  end
  
  it "searches in the middles of strings" do
    FactoryGirl.create(:copycat_translation, :key => "site.index.something")
    fill_in 'search', :with => 'index'
    click_button 'Search'
    page.should have_content 'site.index.something'
  end

  it "can show all" do
    FactoryGirl.create(:copycat_translation, :key => "foe", :value => "beer")
    click_button 'Search'
    page.should have_content 'foo'
    page.should have_content 'foe'
  end

  context "more than one locale" do

    before do
      CopycatTranslation.destroy_all
      FactoryGirl.create(:copycat_translation, key: "foo", value: "bar1", locale: "en")
      FactoryGirl.create(:copycat_translation, key: "foo", value: "bar2", locale: "fa")
      FactoryGirl.create(:copycat_translation, key: "foo", value: "bar3", locale: "it")
    end

    #locale
    # 1. not on URL at all
    #   - set to default_locale
    # 2. present but blank
    # 3. present with value

    #search
    # 1. not on URL at all
    #  - show nothing
    # 2. present but blank
    #  - show everything
    #    - L1 got set to default locale
    #    - L2 show for all locales
    #    - L3 scope to one locale
    # 3. present with value
    #  - show matching
    #    - L1 got set to default locale
    #    - L2 show for all locales
    #    - L3 scope to one locale

    it "nil locale, nil search" do
      visit copycat_translations_path
      page.should_not have_content 'foo'
    end

    it "nil locale, blank search" do
      # impossible for user to replicate this case
      visit copycat_translations_path('search' => '', 'commit' => 'Search')
      page.should have_content 'bar1'
      page.should_not have_content 'bar2'
      page.should_not have_content 'bar3'
    end

    it "nil locale, present search" do
      # impossible for user to replicate this case
      visit copycat_translations_path('search' => 'foo', 'commit' => 'Search')
      page.should have_content 'bar1'
      page.should_not have_content 'bar2'
      page.should_not have_content 'bar3'
      visit copycat_translations_path('search' => 'fuu', 'commit' => 'Search')
      page.should_not have_content 'foo'
    end

    it "blank locale, nil search" do
      # impossible for user to replicate this case
      visit copycat_translations_path('locale' => '', 'commit' => 'Search')
      page.should_not have_content 'foo'
    end

    it "blank locale, blank search" do
      select '', :from => 'locale'
      click_button 'Search'
      page.should have_content 'bar1'
      page.should have_content 'bar2'
      page.should have_content 'bar3'
    end

    it "blank locale, present search" do
      select '', :from => 'locale'
      fill_in 'search', :with => 'foo'
      click_button 'Search'
      page.should have_content 'bar1'
      page.should have_content 'bar2'
      page.should have_content 'bar3'
      fill_in 'search', :with => 'fuu'
      click_button 'Search'
      page.should_not have_content 'foo'
    end

    it "present locale, nil search" do
      # impossible for user to replicate this case
      visit copycat_translations_path('locale' => 'en', 'commit' => 'Search')
      page.should_not have_content 'foo'
    end

    it "present locale, blank search" do
      select 'en', :from => 'locale'
      click_button 'Search'
      page.should have_content 'bar1'
      page.should_not have_content 'bar2'
      page.should_not have_content 'bar3'
      select 'fa', :from => 'locale'
      click_button 'Search'
      page.should_not have_content 'bar1'
      page.should have_content 'bar2'
      page.should_not have_content 'bar3'
      select 'it', :from => 'locale'
      click_button 'Search'
      page.should_not have_content 'bar1'
      page.should_not have_content 'bar2'
      page.should have_content 'bar3'
    end

    it "present locale, present search" do
      select 'en', :from => 'locale'
      fill_in 'search', :with => 'foo'
      click_button 'Search'
      page.should have_content 'bar1'
      page.should_not have_content 'bar2'
      page.should_not have_content 'bar3'
      select 'fa', :from => 'locale'
      fill_in 'search', :with => 'foo'
      click_button 'Search'
      page.should_not have_content 'bar1'
      page.should have_content 'bar2'
      page.should_not have_content 'bar3'
      select 'it', :from => 'locale'
      fill_in 'search', :with => 'foo'
      click_button 'Search'
      page.should_not have_content 'bar1'
      page.should_not have_content 'bar2'
      page.should have_content 'bar3'
      select 'en', :from => 'locale'
      fill_in 'search', :with => 'fuu'
      click_button 'Search'
      page.should_not have_content 'foo'
    end

  end

end

feature "copycat edit" do
  before do
    FactoryGirl.create(:copycat_translation, :key => "foo", :value => "bar")
    page.driver.browser.basic_authorize Copycat.username, Copycat.password
    visit copycat_translations_path
  end

  scenario "visit edit form" do
    fill_in 'search', :with => 'foo'
    click_button 'Search'
    click_link 'foo'
    fill_in "copycat_translation[value]", :with => 'baz'
  end
end

feature "copycat update, delete" do
  before do
    FactoryGirl.create(:copycat_translation, :key => "foo", :value => "bar")
    page.driver.browser.basic_authorize Copycat.username, Copycat.password
    visit copycat_translations_path
    fill_in 'search', :with => 'foo'
    click_button 'Search'
    click_link 'foo'
  end

  scenario "update" do
    fill_in "copycat_translation[value]", :with => 'baz'
    click_button "Update"
    current_path.should == copycat_translations_path
    CopycatTranslation.find_by_key("foo").value.should == 'baz'
    page.should have_content "foo updated!"
  end

  scenario "delete" do
    click_button "Delete this item"
    current_path.should == copycat_translations_path
    CopycatTranslation.find_by_key("foo").should be_nil
    page.should have_content "foo deleted!"
  end
end

feature "downloading and uploading yaml files" do
  before do
    page.driver.browser.basic_authorize Copycat.username, Copycat.password
  end

  it "round-trips the YAML" do
    FactoryGirl.create(:copycat_translation, :key => "a.foo1", :value => "bar1")
    FactoryGirl.create(:copycat_translation, :key => "a.foo2:", :value => "bar2")
    FactoryGirl.create(:copycat_translation, :key => "a.b.foo3", :value => "bar3")
    FactoryGirl.create(:copycat_translation, :key => "c.foo4", :value => "bar4")
    FactoryGirl.create(:copycat_translation, :key => 2, :value => "bar5")
    assert CopycatTranslation.count == 5

    visit import_export_copycat_translations_path
    click_link 'Download as YAML'
    CopycatTranslation.destroy_all
    assert CopycatTranslation.count == 0

    yaml = page.text
    file = Tempfile.new 'copycat'
    file.write yaml
    file.close

    visit import_export_copycat_translations_path
    attach_file "file", file.path
    click_button "Upload"
    file.unlink

    assert CopycatTranslation.count == 5
    assert CopycatTranslation.find_by_key("a.foo1").value == "bar1"
    assert CopycatTranslation.find_by_key("a.foo2:").value == "bar2"
    assert CopycatTranslation.find_by_key("a.b.foo3").value == "bar3"
    assert CopycatTranslation.find_by_key("c.foo4").value == "bar4"
    assert CopycatTranslation.find_by_key(2).value == "bar5"
  end

  it "round-trips the yaml with complicated text" do
    value = "“hello world“ üokåa®fgsdf;::fs;kdf"
    FactoryGirl.create(:copycat_translation, :key => "a.foo", :value => value)

    visit import_export_copycat_translations_path
    click_link 'Download as YAML'
    CopycatTranslation.destroy_all

    yaml = page.text
    file = Tempfile.new 'copycat'
    file.write yaml
    file.close

    visit import_export_copycat_translations_path
    attach_file "file", file.path
    click_button "Upload"
    file.unlink
    assert CopycatTranslation.find_by_key("a.foo").value == value
  end

  it "gives 400 on bad upload" do
    file = Tempfile.new 'copycat'
    file.write "<<<%%#$W%s"
    file.close

    visit import_export_copycat_translations_path
    attach_file "file", file.path
    click_button "Upload"
    file.unlink
    page.status_code.should == 400
    page.should have_content("There was an error processing your upload!")
    assert CopycatTranslation.count == 0
  end

end

feature "locales" do
  before do

    page.driver.browser.basic_authorize Copycat.username, Copycat.password
  end

  it "imports yaml containing multiple locales" do
    file = Tempfile.new 'copycat'
    file.write <<-YAML
      en:
        hello: world
      es:
        hello: mundo
    YAML
    file.close

    visit import_export_copycat_translations_path
    attach_file "file", file.path
    click_button "Upload"
    file.unlink

    assert CopycatTranslation.count == 2
    a = CopycatTranslation.where(locale: 'en').first
    assert a.key == 'hello'
    assert a.value == 'world'
    b = CopycatTranslation.where(locale: 'es').first
    assert b.key == 'hello'
    assert b.value == 'mundo'
  end

  it "exports yaml containing multiple locales" do
    FactoryGirl.create(:copycat_translation, locale: 'en', key: 'hello', value: 'world')
    FactoryGirl.create(:copycat_translation, locale: 'es', key: 'hello', value: 'mundo')

    visit download_copycat_translations_path
    yaml = page.text
    assert yaml =~ /en:\s*hello: world/
    assert yaml =~ /es:\s*hello: mundo/  
  end

end
