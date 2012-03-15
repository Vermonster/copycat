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

    CopycatTranslation.import_yaml(StringIO.new(yaml))
    assert CopycatTranslation.find_by_key("a.foo1").value == "bar1"
    assert CopycatTranslation.find_by_key("a.foo2").value == "bar2"
    assert CopycatTranslation.find_by_key("a.b.foo3").value == "bar3"
    assert CopycatTranslation.find_by_key("c.foo4").value == "bar4"
    assert CopycatTranslation.find_by_key("foo5").value == "bar5"
    assert CopycatTranslation.count == 5
  end

end

