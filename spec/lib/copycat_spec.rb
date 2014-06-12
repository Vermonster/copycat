require 'spec_helper'

describe Copycat do

  let(:Base) do
    Class.new.tap do |b|
      b.class_eval do
        module SimpleImplementation
          def lookup(*args)
            "translation missing"
          end
        end
        include SimpleImplementation
      end
    end
  end

  let(:base) do
    Base().new
  end

  before do
    Base().class_eval do
      include Copycat::Implementation
    end
  end

  describe ".lookup" do
    it "returns simple lookup if copycat_translation missing" do
      expect(base.lookup(nil, '')).to eq("translation missing")
    end
    it "returns copycat_translation if present" do
      cct = create(:copycat_translation)
      expect(base.lookup(cct.locale, cct.key)).to eq(cct.value)
    end
    it "creates copycat_translation if one is missing" do
      expect(CopycatTranslation.where(locale: 'en', key: 'foo')).to be_empty
      base.lookup('en', 'foo')
      expect(CopycatTranslation.where(locale: 'en', key: 'foo')).not_to be_empty
    end
  end

end
