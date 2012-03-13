require 'spec_helper'

describe CopycatTranslation do

  xit "imports YAML" do
    assert Copybar.find_by_key("sample_copy").value == "copyfoo"
    assert Copybar.find_by_key("sample_copy2").value == "copybaz"
    assert Copybar.find_by_key("hello").nil?

    yaml = <<-YAML
      en:
        hello: "Hello world"
        sample_copy: "lorem ipsum"   
    YAML
    Copybara.import_yaml(StringIO.new(yaml))

    assert Copybar.find_by_key("sample_copy").value == "lorem ipsum"
    assert Copybar.find_by_key("sample_copy2").value == "copybaz"
    assert Copybar.find_by_key("hello").value == "Hello world"
  end

  xit "exports YAML" do
    assert Copybar.find_by_key("sample_copy").value == "copyfoo"
    assert Copybar.find_by_key("sample_copy2").value == "copybaz"

    yaml = Copybara.export_yaml
    assert yaml =~ /en:/
    assert yaml =~ /sample_copy: "copyfoo"/
    assert yaml =~ /sample_copy2: "copybaz"/
  end

end




