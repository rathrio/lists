module IconHelper
  def icon(id, size: nil, tip: nil, tip_pos: nil, spin: false)
    span_class = 'icon '
    span_class << "is-#{size}" if size

    icon_class = ''
    icon_class << (size.to_s.to_sym == :medium ? 'fa-2x' : 'fa-lg')
    icon_class << 'fa-spinner fa-pulse' if spin

    content_tag :span, class: span_class, data: { balloon: tip, 'balloon-pos' => tip_pos } do
      fa_icon(id, class: icon_class)
    end
  end

  def spinner
    icon(:spinner, size: :medium, spin: true)
  end
end
