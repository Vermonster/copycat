#encoding: utf-8
require 'spec_helper'

describe CopycatTranslation do

  it "imports YAML" do
    Factory(:copycat_translation, :key => "sample_copy", :value => "copyfoo")
    Factory(:copycat_translation, :key => "sample_copy2", :value => "copybaz")

    assert CopycatTranslation.find_by_key("sample_copy").value == "copyfoo"
    assert CopycatTranslation.find_by_key("sample_copy2").value == "copybaz"
    assert CopycatTranslation.find_by_key("hello").nil?

    yaml = <<-YAML
      en:
        hello: "Hello world"
        sample_copy: "lorem ipsum"   
    YAML
    CopycatTranslation.import_yaml(StringIO.new(yaml))

    assert CopycatTranslation.find_by_key("sample_copy").value == "lorem ipsum"
    assert CopycatTranslation.find_by_key("sample_copy2").value == "copybaz"
    assert CopycatTranslation.find_by_key("hello").value == "Hello world"
  end

  describe "export YAML" do
    it "can be consumed by i18N" do
      I18n.t('site.title').should_not == 'My Blog'
      CopycatTranslation.destroy_all
      CopycatTranslation.create(key: 'site.title', value: 'My Blog')
      data = YAML.load(CopycatTranslation.export_yaml)
      CopycatTranslation.destroy_all
      data.each { |locale, d| I18n.backend.store_translations(locale, d || {}) } #i18n/backend/base.rb:159
      I18n.t('site.title').should == 'My Blog'
    end
  end

  it "exports YAML" do
    Factory(:copycat_translation, :key => "sample_copy", :value => "copyfoo")
    Factory(:copycat_translation, :key => "sample_copy2", :value => "copybaz")
    yaml = CopycatTranslation.export_yaml
    assert yaml =~ /sample_copy: copyfoo\n\s*sample_copy2: copybaz/
    
    Factory(:copycat_translation, :key => "a.sample_copy3", :value => "copyfoo")
    Factory(:copycat_translation, :key => "a.sample_copy4", :value => "copybaz")
    yaml = CopycatTranslation.export_yaml
    assert yaml =~ /a:\n\s*sample_copy3: copyfoo\n\s* sample_copy4: copybaz/
  end

  it "exports and then imports complicated YAML" do
    key = "moby_dick"
    value = %|<p>Lorem ipsum</p><p class="highlight">∆'≈:</p>|
    Factory(:copycat_translation, key: key, value: value)
    yaml = CopycatTranslation.export_yaml
    CopycatTranslation.destroy_all
    CopycatTranslation.import_yaml(StringIO.new(yaml))
    CopycatTranslation.find_by_key(key).value.should == value
  end

end




