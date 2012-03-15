require 'spec_helper'

describe CopycatTranslation do

  it "imports YAML" do
    Factory(:copycat_translation, :key => "en.sample_copy", :value => "copyfoo")
    Factory(:copycat_translation, :key => "sample_copy2", :value => "copybaz")

    assert CopycatTranslation.find_by_key("en.sample_copy").value == "copyfoo"
    assert CopycatTranslation.find_by_key("sample_copy2").value == "copybaz"
    assert CopycatTranslation.find_by_key("en.hello").nil?

    yaml = <<-YAML
      en:
        hello: "Hello world"
        sample_copy: "lorem ipsum"   
    YAML
    CopycatTranslation.import_yaml(YAML.load(StringIO.new(yaml)))

    assert CopycatTranslation.find_by_key("en.sample_copy").value == "lorem ipsum"
    assert CopycatTranslation.find_by_key("sample_copy2").value == "copybaz"
    assert CopycatTranslation.find_by_key("en.hello").value == "Hello world"
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
    Factory(:copycat_translation, :key => "moby_dick", :value => %|Call me Ishmael. Some years ago - never mind how long precisely - having little or no money in my purse, and nothing particular to interest me on shore, I thought I would sail about a little and see the watery part of the world. It is a way I have of driving off the spleen, and regulating the circulation. Whenever I find myself growing grim about the mouth; whenever it is a damp, drizzly November in my soul; whenever I find myself involuntarily pausing before coffin warehouses, and bringing up the rear of every funeral I meet; and especially whenever my hypos get such an upper hand of me, that it requires a strong moral principle to prevent me from deliberately stepping into the street, and methodically knocking people's hats off - then, I account it high time to get to sea as soon as I can. This is my substitute for pistol and ball. With a philosophical flourish Cato throws himself upon his sword; I quietly take to the ship. There is nothing surprising in this. If they but knew it, almost all men in their degree, some time or other, cherish very nearly the same feelings towards the ocean with me.|)
    yaml = CopycatTranslation.export_yaml
    CopycatTranslation.destroy_all
    CopycatTranslation.import_yaml(YAML.load(StringIO.new(yaml)))
    assert CopycatTranslation.count == 1
    assert CopycatTranslation.first.value =~ /the same feelings towards the ocean with me./
  end

end




