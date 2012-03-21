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

end
