class TagSerializer
  def initialize(tag)
    @tag = tag
  end

  def as_json(*)
    {
      id: @tag.id,
      name: @tag.name,
      locked: @tag.locked
    }
  end
end
