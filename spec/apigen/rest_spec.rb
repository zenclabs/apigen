require 'apigen/rest'

RSpec.describe Apigen::Rest do
  it "records endpoints" do
    api = Apigen::Rest::api do
      endpoint :get_user do
        method :get
        path "/users/{id}" do
          id :string
        end
        output :success do
          status 200
          type :string
        end
      end
    end
    expect(api.endpoints.size).to be 1
    expect(api.endpoints[0].name).to be :get_user
  end

  it "requires input for POST endpoints" do
    expect {
      Apigen::Rest::api do
        endpoint :create_user do
          method :post
          path "/users"
          output :success do
            status 200
            type :string
          end
        end
      end
    }.to raise_error "Use `input :typename` to assign an input type to :create_user."
  end

  it "requires input for PUT endpoints" do
    expect {
      Apigen::Rest::api do
        endpoint :update_user do
          method :put
          path "/users/{id}" do
            id :string
          end
          output :success do
            status 200
            type :string
          end
        end
      end
    }.to raise_error "Use `input :typename` to assign an input type to :update_user."
  end

  it "rejects input for GET endpoints" do
    expect {
      Apigen::Rest::api do
        endpoint :get_user do
          method :get
          path "/users/{id}" do
            id :string
          end
          input :string
          output :success do
            status 200
            type :string
          end
        end
      end
    }.to raise_error "Endpoint :get_user with method GET cannot accept an input payload."
  end

  it "rejects input for DELETE endpoints" do
    expect {
      Apigen::Rest::api do
        endpoint :delete_user do
          method :delete
          path "/users/{id}" do
            id :string
          end
          input :string
          output :success do
            status 200
            type :string
          end
        end
      end
    }.to raise_error "Endpoint :delete_user with method DELETE cannot accept an input payload."
  end

  it "validates model registry" do
    expect {
      Apigen::Rest::api do
        endpoint :create_user do
          method :post
          path "/users"
          input :user
          output :success do
            status 200
            type :string
          end
        end

        model :user do
          type :object do
            name :missing
          end
        end
      end
    }.to raise_error "Unknown type :missing."
  end

  it "validates methods" do
    expect {
      Apigen::Rest::api do
        endpoint :wrong_method do
          method :abc
          path "/users"
          input :user
          output :success do
            status 200
            type :string
          end
        end
      end
    }.to raise_error "Unknown HTTP method :abc."
  end

  it "validates inputs" do
    expect {
      Apigen::Rest::api do
        endpoint :create_user do
          method :post
          path "/users"
          input :missing
          output :success do
            status 200
            type :string
          end
        end
      end
    }.to raise_error "Unknown type :missing."
  end

  it "validates outputs" do
    expect {
      Apigen::Rest::api do
        endpoint :create_user do
          method :post
          path "/users"
          input :void
          output :success do
            status 200
            type :missing
          end
        end
      end
    }.to raise_error "Unknown type :missing."
  end

  it "requires all path parameters to be typed" do
    expect {
      Apigen::Rest::api do
        endpoint :get_user do
          method :get
          path "/users/{id}"
          output :success do
            status 200
            type :string
          end
        end
      end
    }.to raise_error "Path parameter :id in path /users/{id} is not defined."
  end

  it "rejects unmatched path parameter types" do
    expect {
      Apigen::Rest::api do
        endpoint :get_user do
          method :get
          path "/users/{id}" do
            id :string
            unused :string
          end
          output :success do
            status 200
            type :string
          end
        end
      end
    }.to raise_error "Parameter :unused does not appear in path /users/{id}."
  end

  it "validates path parameter types" do
    expect {
      Apigen::Rest::api do
        endpoint :get_user do
          method :get
          path "/users/{id}" do
            id :missing
          end
          output :success do
            status 200
            type :string
          end
        end
      end
    }.to raise_error "Unknown type :missing."
  end
end