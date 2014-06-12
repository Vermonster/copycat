#encoding: utf-8
require 'spec_helper'

describe CopycatTranslation do

  it { should validate_presence_of(:locale) }
  it { should validate_presence_of(:key) }

  it "validates uniqueness of key & locale" do
    create(:copycat_translation, :key => "foo", :locale => "en", :value => "bar")

    expect do
      create(:copycat_translation, :key => "foo", :locale => "en", :value => "bar")
    end.to raise_error ActiveRecord::RecordNotUnique

    expect do
      create(:copycat_translation, :key => "foo", :locale => "es", :value => "bar")
    end.not_to raise_error
  end

  it 'imports YAML string, updating existing keys, ignoring keys with blank values' do
    create(:copycat_translation, :key => 'foo', :value => 'bar')
    create(:copycat_translation, :key => 'controller.view.copy', :value => 'derp')
    create(:copycat_translation, :key => 'controller.view.partial.copy', :value => 'foo')

    yaml = <<-YAML.strip_heredoc
      en:
        hello: "Hello world"
        foo: "lorem ipsum"
        controller:
          view:
            partial:
              copy: 'bar'
              blank:
    YAML

    CopycatTranslation.import_yaml(yaml)

    expect(I18n.t('foo')).to eq 'lorem ipsum'
    expect(I18n.t('hello')).to eq 'Hello world'
    expect(I18n.t('controller.view.copy')).to eq 'derp'
    expect(I18n.t('controller.view.partial.copy')).to eq 'bar'
    expect(I18n.t('controller.view.blank')).to eq 'translation missing: en.controller.view.blank'
  end

  it 'exports YAML that can be consumed by I18n' do
    # Assert that the translation doesn't already exist to avoid false postives
    expect(I18n.t('apple')).not_to eq('Apple')
    expect(I18n.t('apple', :locale => :es)).not_to eq('Manzana')
    expect(I18n.t('site.title')).not_to eq('My Blog')

    # The previous calls to I18n populate the database
    CopycatTranslation.delete_all
    create(:copycat_translation, :locale => 'en', :key => 'site.title', :value => 'My Blog')
    create(:copycat_translation, :locale => 'en', :key => 'site.blogs.index.markup', :value =>%|<p>Lorem ipsum</p><p class="highlight">∆'≈:</p>|)
    create(:copycat_translation, :locale => 'en', :key => 'apple', :value => 'Apple')
    create(:copycat_translation, :locale => 'es', :key => 'apple', :value => 'Manzana')

    yaml = CopycatTranslation.export_yaml

    filepath = Pathname.new(File.expand_path(File.join(__FILE__, '..', '..', 'support', 'export.yml')))
    File.open(filepath, 'w') { |f| f.write yaml }

    I18n.backend.load_translations(filepath)

    expect(I18n.t('apple')).to eq 'Apple'
    expect(I18n.t('apple', :locale => :es)).to eq 'Manzana'
    expect(I18n.t('site.title')).to eq 'My Blog'
    expect(I18n.t('site.blogs.index.markup')).to eq %|<p>Lorem ipsum</p><p class="highlight">∆'≈:</p>|
  end
end
