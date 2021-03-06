module TextHelper

  # Returns HTML from input text using GitHub-flavored Markdown.
  def markdown_to_html(text)
    Kramdown::Document.new(text, {header_offset: 5}).to_html
  end
end
