Sequel.migration do
  change do
    alter_table(:photos) do
      add_column :title, String, :null => false, :default => 'Unknown'
    end
  end
end
