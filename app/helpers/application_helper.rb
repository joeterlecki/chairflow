module ApplicationHelper
  def application_page_title
    section = {
      "calendar" => "Calendar",
      "stylists" => "Team schedule",
      "scheduled_shifts" => "Team schedule",
      "time_offs" => "Time off",
      "services" => "Services",
      "clients" => "Clients"
    }.fetch(controller_name, "Salon planner")
    "#{section} · Chairflow"
  end
end
