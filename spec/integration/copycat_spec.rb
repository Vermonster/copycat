#encoding: utf-8

require 'spec_helper'


feature "copycat index" do
 
  before do
    Factory(:copycat_translation, :key => "foo", :value => "bar")
    page.driver.browser.basic_authorize COPYCAT_USERNAME, COPYCAT_PASSWORD
    visit copycat_translations_path
  end

  it "has a nav bar" do
    click_link 'Import / Export'
    click_link 'Readme'
    click_link 'Copycat'
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
    Factory(:copycat_translation, :key => "site.index.something")
    fill_in 'search', :with => 'index'
    click_button 'Search'
    page.should have_content 'site.index.something'
  end

  it "can show all" do
    Factory(:copycat_translation, :key => "foe", :value => "beer")
    click_button 'Search'
    page.should have_content 'foo'
    page.should have_content 'foe'
  end

  context "more than one locale" do
    xit "scopes to locale" do
      Factory(:copycat_translation, :key => "füi", :value => "bäri", :locale => "it")
      click_link 'Show all'
      page.should have_content 'foo'
      page.should have_content 'bar'
      page.should_not have_content 'füi'
      page.should_not have_content 'bäri'
      select 'it', :from => 'locale'
      click_button 'Change Locale'
      click_link 'Show all'
      page.should have_content 'füi'
      page.should have_content 'bäri' 
      page.should_not have_content 'foo'
      page.should_not have_content 'bar'
    end
  end

end

feature "downloading and uploading yaml files" do
  before do
    page.driver.browser.basic_authorize COPYCAT_USERNAME, COPYCAT_PASSWORD
  end

  it "round-trips the YAML" do
    Factory(:copycat_translation, :key => "a.foo1", :value => "bar1")
    Factory(:copycat_translation, :key => "a.foo2:", :value => "bar2")
    Factory(:copycat_translation, :key => "a.b.foo3", :value => "bar3")
    Factory(:copycat_translation, :key => "c.foo4", :value => "bar4")
    Factory(:copycat_translation, :key => 2, :value => "bar5")
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
    Factory(:copycat_translation, :key => "a.foo", :value => value)

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

    page.driver.browser.basic_authorize COPYCAT_USERNAME, COPYCAT_PASSWORD
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
    Factory(:copycat_translation, locale: 'en', key: 'hello', value: 'world')
    Factory(:copycat_translation, locale: 'es', key: 'hello', value: 'mundo')

    visit download_copycat_translations_path
    yaml = page.text
    assert yaml =~ /en:\s*hello: world/
    assert yaml =~ /es:\s*hello: mundo/  
  end

end
