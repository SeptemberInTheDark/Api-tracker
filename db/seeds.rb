Tag::REQUIRED_NAMES.each do |name|
  Tag.find_or_create_by!(name: name) do |tag|
    tag.locked = true
  end
end
