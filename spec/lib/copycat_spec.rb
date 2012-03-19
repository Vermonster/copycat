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
      include CopycatImplementation
    end
  end

  describe ".lookup" do
    it "returns simple lookup if copycat_translation missing" do
      base.lookup(nil, '').should == "translation missing"
    end
    it "returns copycat_translation if present" do
      cct = FactoryGirl.create(:copycat_translation)
      base.lookup(nil, cct.key).should == cct.value
    end
    it "creates copycat_translation if one is missing" do
      CopycatTranslation.find_by_key('foo').should be_nil
      base.lookup(nil, 'foo')
      CopycatTranslation.find_by_key('foo').should_not be_nil
    end
  end

end
