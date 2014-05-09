#encoding: utf-8
require 'spec_helper'

describe CopycatTranslation do

  describe "database constraints" do
    it "validates uniqueness of key & locale" do
      CopycatTranslation.new(key: "foo", locale: "en", value: "bar").save
      a = CopycatTranslation.new(key: "foo", locale: "en", value: "bar2")
      expect { a.save }.to raise_error
      b = CopycatTranslation.new(key: "foo", locale: "fa", value: "bar")
      expect { b.save }.not_to raise_error
    end
  end

  describe "helper methods" do
    it "flattens hashes" do
      before = {"a" => {"b" => "c", "d" => "e"}, "f" => {"g" => {"h" => "i", "j" => "k"}, "l" => "m"}}
      after = CopycatTranslation.hash_flatten(before)
      assert after == {"a.b" => "c", "a.d" => "e", "f.g.h" => "i", "f.g.j" => "k", "f.l" => "m"}
    end

    it "fattens hashes" do
      hash = {"a" => {"b" => "c", "d" => "e"}, "f" => {"g" => {"h" => "i"}, "l" => "m"}}
      keys = "f.g.j".split(".")
      value = "k"
      CopycatTranslation.hash_fatten!(hash, keys, value)
      assert hash == {"a" => {"b" => "c", "d" => "e"}, "f" => {"g" => {"h" => "i", "j" => "k"}, "l" => "m"}}
    end
  end

  it "imports YAML" do
    FactoryGirl.create(:copycat_translation, :key => "sample_copy", :value => "copyfoo")
    FactoryGirl.create(:copycat_translation, :key => "sample_copy2", :value => "copybaz")

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
      expect(I18n.t('site.title')).not_to eq('My Blog')
      CopycatTranslation.destroy_all
      CopycatTranslation.create(key: 'site.title', value: 'My Blog', locale: 'en')
      data = YAML.load(CopycatTranslation.export_yaml)
      CopycatTranslation.destroy_all
      data.each { |locale, d| I18n.backend.store_translations(locale, d || {}) } #i18n/backend/base.rb:159
      expect(I18n.t('site.title')).to eq('My Blog')
    end
  end

  it "exports YAML" do
    FactoryGirl.create(:copycat_translation, :key => "sample_copy", :value => "copyfoo")
    FactoryGirl.create(:copycat_translation, :key => "sample_copy2", :value => "copybaz")
    yaml = CopycatTranslation.export_yaml
    assert yaml =~ /sample_copy: copyfoo\n\s*sample_copy2: copybaz/

    FactoryGirl.create(:copycat_translation, :key => "a.sample_copy3", :value => "copyfoo")
    FactoryGirl.create(:copycat_translation, :key => "a.sample_copy4", :value => "copybaz")
    yaml = CopycatTranslation.export_yaml
    assert yaml =~ /a:\n\s*sample_copy3: copyfoo\n\s* sample_copy4: copybaz/
  end

  it "exports and then imports complicated YAML" do
    key = "moby_dick"
    value = %|<p>Lorem ipsum</p><p class="highlight">∆'≈:</p>|
    FactoryGirl.create(:copycat_translation, key: key, value: value)
    yaml = CopycatTranslation.export_yaml
    CopycatTranslation.destroy_all
    CopycatTranslation.import_yaml(StringIO.new(yaml))
    expect(CopycatTranslation.find_by_key(key).value).to eq(value)
  end

end




