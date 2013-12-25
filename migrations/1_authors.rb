Sequel.migration do
    up do
        create_table(:authors) do
            primary_key :id
            String :name, :unique=>true
        end
    end

    down do
        drop_table(:authors)
    end
end