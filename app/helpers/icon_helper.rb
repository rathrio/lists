module IconHelper
  def icon(id, size: nil, tip: nil, tip_pos: nil)
    size_css = size ? "is-#{size}" : ''
    content_tag :span, class: "icon #{size_css}", data: { balloon: tip } do
      fa_icon(id)
    end
  end
end
