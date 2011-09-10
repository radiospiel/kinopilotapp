SUBREPOSITORIES=%w(JSONKit NSLogger MAZeroingWeakRef)
task :default => :autotest

task :subrepositories do
  next if SUBREPOSITORIES.all? { |repo| File.exists? "vendor/#{repo}" }

	system "git submodule init"
	system "git submodule update"
end

task :autotest => :subrepositories do
	system "./xcodetest M3Tests"
end

# task :iautotest => :subrepositories do
#   system "./xcodetest iM3Tests"
# end

task :clean do
  require "ftools"
  FileUtils.rm_rf "#{File.dirname(__FILE__)}/build"
end

task :doc do
  system "appledoc -o doc --create-html --no-create-docset -p Underscore.m -c radiospiel.org underscore/underscore.h*"
end
