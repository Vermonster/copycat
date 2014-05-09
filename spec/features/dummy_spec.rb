#encoding: utf-8

require 'spec_helper'

feature "use #t" do

  it "the dummy app has a translation for site.index.header but not site.index.intro" do
    expect(I18n.t('site.index.header')).to eq('The Header')
    expect(I18n.t('site.index.intro')).to eq("translation missing: en.site.index.intro")
  end

  it "uses i18n.t" do
    visit root_path
    expect(page).to have_content 'The Header'
    expect(page).to have_content 'Intro' #ActionView::Helpers::TranslationHelper#translate wrapper
  end

  it "creates a copycat_translation if the yaml has an entry" do
    expect(CopycatTranslation.find_by_key('site.index.header')).to be_nil
    visit root_path
    expect(CopycatTranslation.find_by_key('site.index.header')).not_to be_nil
  end

  it "creates a copycat_translation if the yaml does not have an entry" do
    expect(CopycatTranslation.find_by_key('site.index.intro')).to be_nil
    visit root_path
    expect(CopycatTranslation.find_by_key('site.index.intro')).not_to be_nil
  end

  it "shows the copycat_translation instead of the yaml" do
    FactoryGirl.create(:copycat_translation, key: 'site.index.header', value: 'A different header')
    visit root_path
    expect(page).not_to have_content 'The Header'
    expect(page).to have_content 'A different header'
  end

end

feature "locales" do

  it "displays different text based on users' locale" do
    FactoryGirl.create(:copycat_translation, locale: 'en', key: 'site.index.intro', value: 'world')
    FactoryGirl.create(:copycat_translation, locale: 'es', key: 'site.index.intro', value: 'mundo')

    I18n.locale = :en
    visit root_path
    expect(page).to have_content 'world'
    expect(page).not_to have_content 'mundo'

    I18n.locale = :es
    visit root_path
    expect(page).to have_content 'mundo'
    expect(page).not_to have_content 'world'

    I18n.locale = :fa
    visit root_path
    expect(page).not_to have_content 'world'
    expect(page).not_to have_content 'mundo'

    I18n.locale = :en  # reset
  end

end

feature "yaml" do

  it "round-trips both translations correctly (and doesn't export nils)" do
    visit root_path
    expect(CopycatTranslation.find_by_key('site.index.intro').value).to be_nil
    expect(CopycatTranslation.find_by_key('site.index.header').value).to eq('The Header')
    expect(CopycatTranslation.count).to eq(2)

    page.driver.browser.basic_authorize Copycat.username, Copycat.password
    visit import_export_copycat_translations_path
    click_link 'Download as YAML'
    CopycatTranslation.destroy_all
    expect(CopycatTranslation.count).to eq(0)
    yaml = page.body
    file = Tempfile.new 'copycat'
    file.write yaml
    file.close
    visit import_export_copycat_translations_path
    attach_file "file", file.path
    click_button "Upload"
    file.unlink

    expect(CopycatTranslation.count).to eq(1)
    expect(CopycatTranslation.find_by_key('site.index.intro')).to be_nil
    expect(CopycatTranslation.find_by_key('site.index.header').value).to eq('The Header')
  end

end
