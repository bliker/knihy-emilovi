Sequel.migration do
    up do
        create_table(:books) do
            primary_key :id
            String :title, :null => true
            Ineteger :author_id, :null => true
            String :url, :unique => true
            TrueClass :epub, :default => false
            TrueClass :html, :default => false
        end
    end

    down do
        drop_table(:books)
    end
end