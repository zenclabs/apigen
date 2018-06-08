require 'apigen/model'

RSpec.describe Apigen::ModelRegistry do
  it "allows declaring simple models" do
    registry = Apigen::ModelRegistry.new
    registry.model :name do
      type :string
    end
    expect(registry.models.keys).to eq [:name]
    expect(registry.models[:name].type).to be :string
  end

  it "allows declaring complex models" do
    registry = Apigen::ModelRegistry.new
    registry.model :user do
      type :object do
        name :string
      end
    end
    expect(registry.models.keys).to eq [:user]
    expect(registry.models[:user].type).to be_a Apigen::Object
  end

  it "fails when creating a model without a block" do
    registry = Apigen::ModelRegistry.new
    expect {
      registry.model :user
    }.to raise_error "You must pass a block when calling `model`."
  end

  it "validates primary types (valid)" do
    registry = Apigen::ModelRegistry.new
    registry.model :name do
      type :string
    end
    registry.model :date do
      type :int32
    end
    registry.model :truth do
      type :bool
    end
    registry.model :nothing do
      type :void
    end
    registry.validate
  end

  it "validates primary types (invalid)" do
    registry = Apigen::ModelRegistry.new
    registry.model :name do
      type :missing
    end
    expect {
      registry.validate
    }.to raise_error "Unknown type :missing."
  end

  it "validates object models (valid)" do
    registry = Apigen::ModelRegistry.new
    registry.model :user do
      type :object do
        name :name
      end
    end
    registry.model :name do
      type :string
    end
    registry.validate
  end

  it "validates object models (invalid)" do
    registry = Apigen::ModelRegistry.new
    registry.model :user do
      type :object do
        name :missing
      end
    end
    expect {
      registry.validate
    }.to raise_error "Unknown type :missing."
  end

  it "validates array models (valid)" do
    registry = Apigen::ModelRegistry.new
    registry.model :name_list do
      type :array do
        type :name
      end
    end
    registry.model :name do
      type :string
    end
    registry.validate
  end

  it "validates array models (invalid)" do
    registry = Apigen::ModelRegistry.new
    registry.model :name_list do
      type :array do
        type :missing
      end
    end
    expect {
      registry.validate
    }.to raise_error "Unknown type :missing."
  end

  it "validates optional models (valid, short syntax)" do
    registry = Apigen::ModelRegistry.new
    registry.model :maybe_name do
      type :name?
    end
    registry.model :name do
      type :string
    end
    registry.validate
  end

  it "validates optional models (invalid, short syntax)" do
    registry = Apigen::ModelRegistry.new
    registry.model :maybe_name do
      type :missing?
    end
    expect {
      registry.validate
    }.to raise_error "Unknown type :missing."
  end

  it "validates optional models (valid, long syntax)" do
    registry = Apigen::ModelRegistry.new
    registry.model :maybe_name do
      type :optional do
        type :name
      end
    end
    registry.model :name do
      type :string
    end
    registry.validate
  end

  it "validates optional models (invalid, long syntax)" do
    registry = Apigen::ModelRegistry.new
    registry.model :maybe_name do
      type :optional do
        type :missing
      end
    end
    expect {
      registry.validate
    }.to raise_error "Unknown type :missing."
  end
end
