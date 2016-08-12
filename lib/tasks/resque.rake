require 'resque/tasks'

task 'resque:setup' => :environment do
  ENV['QUEUE'] ||= '*'
  ENV['INTERVAL'] ||= '1'
end

namespace :resque do
  desc 'Quit running workers'
  task :stop => :environment do
    pids = Array.new
    Resque.workers.each do |worker|
      pids.concat(worker.worker_pids)
    end
    if pids.empty?
      puts 'No workers to kill'
    else
      syscmd = "kill -s QUIT #{pids.join(' ')}"
      puts "Running syscmd: #{syscmd}"
      system(syscmd)
    end
  end

  desc 'Start a specific number of workers'
  task :start, [:count] => :environment do |_, args|
    ops = {:pgroup => true, :err => [(Rails.root + 'log/workers_error.log').to_s, 'a'],
           :out => [(Rails.root + 'log/workers.log').to_s, 'a']}
    count = (args[:count] || 5).to_i
    count.times do
      pid = spawn('rake resque:work', ops)
      Process.detach(pid)
    end
  end
end