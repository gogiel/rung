require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "cucumber/rake/task"

RSpec::Core::RakeTask.new(:spec)
Cucumber::Rake::Task.new(:cucumber)
Cucumber::Rake::Task.new(:cucumber_json, "Generate Cucumber JSON in tmp/") do |t|
  t.cucumber_opts = %w{-f json -o tmp/cucumber.json}
end

task :default => [:spec, :cucumber]

desc "Generate Cukedoctor docs in generated_doc/ using docker"
task docker_generate_docs: [:cucumber_json] do
  sh 'docker run -v "$PWD:/output" -w /output rmpestano/cukedoctor -o generated_doc/index -f html5 -p tmp/cucumber.json -hideSummarySection -t "Rung Documentation" -hideStepTime -hideScenarioKeyword -hideFeaturesSection'
end
