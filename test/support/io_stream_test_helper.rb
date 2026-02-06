module IoStreamTestHelper
  def type_when_prompted(*list, &block)
    Reline.stub(:readline, proc { list.shift }, &block)
  end
end
