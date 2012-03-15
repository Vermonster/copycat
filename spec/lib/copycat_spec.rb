require 'spec_helper'

describe Copycat do

  let(:Base) do
    Class.new.tap do |b|
      b.class_eval do
        module SimpleImplementation
          def lookup(*args)
            42
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
      base.lookup(nil, nil).should == 42
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

  describe "#hash_flatten" do
    it "flattens hashes" do
      before = {"a" => {"b" => "c", "d" => "e"}, "f" => {"g" => {"h" => "i", "j" => "k"}, "l" => "m"}}
      after = Copycat.hash_flatten(before)
      assert after == {"a.b" => "c", "a.d" => "e", "f.g.h" => "i", "f.g.j" => "k", "f.l" => "m"}
    end
  end

  describe "#hash_fatten" do
    it "fattens hashes" do
      before = {"a" => {"b" => "c", "d" => "e"}, "f" => {"g" => {"h" => "i"}, "l" => "m"}}
      keys = "f.g.j".split(".")
      value = "k"
      after = Copycat.hash_fatten(before, keys, value)
      assert after == {"a" => {"b" => "c", "d" => "e"}, "f" => {"g" => {"h" => "i", "j" => "k"}, "l" => "m"}}
    end
  end

end
