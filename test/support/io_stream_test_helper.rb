module IoStreamTestHelper
  def type_when_prompted(*list, &block)
    $stdin.stub(:gets, proc { list.shift }, &block)
  end
end
