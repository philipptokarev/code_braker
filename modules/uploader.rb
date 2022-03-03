module Modules
  module Uploader
    PATH = './data/database.yml'

    def save
      users = store || []
      users << self
      File.open(PATH, 'w') { |file| file.write(users.to_yaml) }
    end

    def store
      return [] unless File.exist?(PATH)

      YAML.safe_load(File.read(PATH), [Entities::User], [], [], true)
    end
  end
end
