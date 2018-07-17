ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do

    # Here is an example of a simple dashboard with columns and panels.

    columns do
      column do
        panel "Recent properties" do
          ul do
            Property.last(20).map do |p|
              li link_to(p.title, admin_property_path(p))
            end
          end
        end
      end

  end # content
  end
end

