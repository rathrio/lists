class DummyClient
  def search(query)
    [
      { name: "charles", age: "20" },
      { name: "nils", age: "37" },
      { name: "peter", age: "24" }
    ].select { |item| item[:age].to_i > query.to_i }
  end
end
