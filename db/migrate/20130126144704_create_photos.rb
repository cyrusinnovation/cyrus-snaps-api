Sequel.migration do
  change do
    create_table(:photos) do
      String :uuid, :primary_key => true
      String :content_type, :null => false
      Integer :file_size, :null => false
      String :filename, :null => false
      Float :latitude, :null => false, :default => 0.0
      Float :longitude, :null => false, :default => 0.0
      Time :created_at, :null => false
      Time :updated_at, :null => false
      String :url, :null => false
    end
  end
end
