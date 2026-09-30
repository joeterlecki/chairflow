module ApplicationHelper
  # A custom chevron for native <select> elements styled with appearance-none,
  # so they never sit next to styled inputs looking like browser defaults.
  def select_chevron
    tag.svg class: "pointer-events-none absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted",
            fill: "none", viewBox: "0 0 24 24", stroke: "currentColor" do
      tag.path "stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M19 9l-7 7-7-7"
    end
  end
end
