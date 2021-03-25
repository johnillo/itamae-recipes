require 'rake'
require 'rspec/core/rake_task'

hosts = %w(
  myapp-local
)

task :spec  => 'spec:all'

namespace :spec do
  task :all => hosts.map {|h| 'spec:' + h }
  hosts.each do |host|
    desc "Run serverspec to #{host}"
    RSpec::Core::RakeTask.new(host) do |t|
      ENV['TARGET_HOST'] = host
      t.pattern = "spec/#{host}/*_spec.rb"
    end
  end
end

