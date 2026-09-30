module StylistsHelper
  SWATCH_CLASSES = {
    "lavender" => "bg-lavender-soft border-lavender",
    "sage" => "bg-sage-soft border-sage",
    "clay" => "bg-clay-soft border-clay",
    "sky" => "bg-sky-soft border-sky",
    "sand" => "bg-sand-soft border-sand"
  }.freeze

  SWATCH_DOT_CLASSES = {
    "lavender" => "bg-lavender",
    "sage" => "bg-sage",
    "clay" => "bg-clay",
    "sky" => "bg-sky",
    "sand" => "bg-sand"
  }.freeze

  def swatch_classes(stylist)
    SWATCH_CLASSES.fetch(stylist.swatch)
  end

  def swatch_dot_classes(stylist)
    SWATCH_DOT_CLASSES.fetch(stylist.swatch)
  end
end
