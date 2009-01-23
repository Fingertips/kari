class ApplicationController < Rucola::RCController
  ITEM_IDENTIFIER = 'Identifier'
  ITEM_NAME = "Name"
  
  def setup_scopeBar!
    puts 'hier!'
    scopeBar.delegate = self
    
    items = [
      { ITEM_IDENTIFIER => "Foo", ITEM_NAME => "Bar" }
    ]
  end
end