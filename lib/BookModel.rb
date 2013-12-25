class Book < Sequel::Model
    def validate
        super
        errors.add(:url, "can't be empty") if url.empty?
    end
end
Book.plugin :json_serializer
