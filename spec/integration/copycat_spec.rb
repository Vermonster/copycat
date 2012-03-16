require 'spec_helper'

feature "use #t" do

  it "uses i18n.t" do
    visit root_path
    page.should have_content 'The Header'
    page.should have_content 'site.index.intro'
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

  it "gives 400 on bad upload" do
    visit "/copycat_translations.yaml"

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

