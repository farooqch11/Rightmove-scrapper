ActiveAdmin.register Property do
  action_item :start_job, only: :index do
    link_to "Start Job", start_job_admin_properties_path
  end

  collection_action :start_job, title: "Start Scraping"  do
    # Nothing here. We just want to render the form.

  end

  collection_action :start_worker, title: "worker", method: :post do
    CrawlWorker.perform_async(params[:data][:url], params[:data][:total_pages])
    redirect_to admin_dashboard_path
  end
end
