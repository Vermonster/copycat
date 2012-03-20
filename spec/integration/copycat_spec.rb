#encoding: utf-8

require 'spec_helper'

feature "use #t" do

  it "the dummy app has a translation for site.index.header but not site.index.intro" do
    I18n.t('site.index.header').should == 'The Header'
    I18n.t('site.index.intro').should == "translation missing: en.site.index.intro"
  end

  it "uses i18n.t" do
    visit root_path
    page.should have_content 'The Header'
    page.should have_content 'Intro' #ActionView::Helpers::TranslationHelper#translate wrapper 
  end

  it "creates a copycat_translation if the yaml has an entry" do
    CopycatTranslation.find_by_key('site.index.header').should be_nil
    visit root_path
    CopycatTranslation.find_by_key('site.index.header').should_not be_nil
  end

  it "creates a copycat_translation if the yaml does not have an entry" do
    CopycatTranslation.find_by_key('site.index.intro').should be_nil
    visit root_path
    CopycatTranslation.find_by_key('site.index.intro').should_not be_nil
  end

  it "shows the copycat_translation instead of the yaml" do
    FactoryGirl.create(:copycat_translation, key: 'site.index.header', value: 'A different header')
    visit root_path
    page.should_not have_content 'The Header'
    page.should have_content 'A different header'
  end

end

require 'tempfile'

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

    visit "/copycat_translations.yaml"
    CopycatTranslation.destroy_all
    assert CopycatTranslation.count == 0

    yaml = page.text
    file = Tempfile.new 'copycat'
    file.write yaml
    file.close

    visit upload_copycat_translations_path
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
    Factory(:copycat_translation, :key => "a.foo", :value => "“hello world“ üokåa®fgsdf;::fs;kdf")
    visit "/copycat_translations.yaml"
    CopycatTranslation.destroy_all
    yaml = page.text
    file = Tempfile.new 'copycat'
    file.write yaml
    file.close
    visit upload_copycat_translations_path
    attach_file "file", file.path
    click_button "Upload"
    file.unlink
    assert CopycatTranslation.find_by_key("a.foo").value == "“hello world“ üokåa®fgsdf;::fs;kdf"
  end

  it "gives 400 on bad upload" do
    file = Tempfile.new 'copycat'
    file.write "<<<%%#$W%s"
    file.close

    visit upload_copycat_translations_path
    attach_file "file", file.path
    click_button "Upload"
    file.unlink
    page.status_code.should == 400
    page.should have_content("There was an error processing your upload!")
    assert CopycatTranslation.count == 0
  end

end

feature "locales" do

  it "displays different text based on users' locale" do
    Factory(:copycat_translation, locale: 'en', key: 'site.index.intro', value: 'world')
    Factory(:copycat_translation, locale: 'es', key: 'site.index.intro', value: 'mundo')

    I18n.locale = :en
    visit root_path
    page.should have_content 'world'
    page.should_not have_content 'mundo'
    
    I18n.locale = :es
    visit root_path
    page.should have_content 'mundo'
    page.should_not have_content 'world'
    
    I18n.locale = :fa
    visit root_path
    page.should_not have_content 'world'
    page.should_not have_content 'mundo'

    I18n.locale = :en  # reset
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

    page.driver.browser.basic_authorize COPYCAT_USERNAME, COPYCAT_PASSWORD
    visit upload_copycat_translations_path
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

    page.driver.browser.basic_authorize COPYCAT_USERNAME, COPYCAT_PASSWORD
    visit "/copycat_translations.yaml"
    yaml = page.text
    assert yaml =~ /en:\s*hello: world/
    assert yaml =~ /es:\s*hello: mundo/  
  end

end
