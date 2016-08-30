require "sinatra/base"
require "json"

require "newrelic_rpm"
NewRelic::Agent.manual_start

class Web < Sinatra::Base
  helpers do
    def stop
      ->() {
        pid = Process.pid
        signal = "INT"
        puts "Killing process #{pid} with signal #{signal}"
        Process.kill(signal, pid)
      }
    end
  end

  get "/" do
    raise "I am a bug, fix me" unless ENV.has_key?("FIXED")

    instance = ENV.fetch("CF_INSTANCE_INDEX", 0)
    addr = ENV.fetch("CF_INSTANCE_ADDR", "127.0.0.1")

    %{
      <h1>Hi, I'm app instance #{instance}</h1>
      <h2>I am running at #{addr}</h2>
      <ul>
        <li><a href="/crash">Stop process</a></li>
        <li><a href="/fill-memory">Exhaust memory</a></li>
        <li><a href="/fill-disk">Exhaust disk</a></li>
      </ul>
    }
  end

  get "/env.json" do
    content_type "application/json"
    JSON.pretty_generate(ENV.to_h)
  end

  get "/crash" do
    stop.()
    %{
      <h2>Oh no! I've crashed!</h2>
      <h3><a href="/">Check if an app instance is available</a></h3>
    }
  end

  get "/fill-memory" do
    (1..Float::INFINITY).map { OpenStruct.new(ENV.to_h) }
  end

  get "/fill-disk" do
    (1..256).each do |number|
      # Write a 1MiB file
      File.open("file-#{number}", "w") do |f|
        f.write(rand(65..91).chr * 1024 * 1024)
      end

      # Invoke garbage collection so we don't out-of-memory
      if number % 16 == 0
        GC.start
      end
    end
  end
end

run Web.new
