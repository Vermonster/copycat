require 'spec_helper'

describe Copycat do

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
