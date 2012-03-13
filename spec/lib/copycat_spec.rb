require 'spec_helper'

describe Copycat do

  describe "#hash_flatten" do
    xit "something" do
      before = {"a" => {"b" => "c", "d" => "e"}, "f" => {"g" => {"h" => "i", "j" => "k"}, "l" => "m"}}
      after = Copycat.hash_flatten(before)
      assert after == {"a.b" => "c", "a.d" => "e", "f.g.h" => "i", "f.g.j" => "k", "f.l" => "m"}
    end
  end
end
