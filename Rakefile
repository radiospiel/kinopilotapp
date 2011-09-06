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

task :clean do
  system "./xcodebuild -configuration Debug -target M3Tests clean"
end

task :doc do
  system "appledoc -o doc --create-html --no-create-docset -p Underscore.m -c radiospiel.org underscore/underscore.h*"
end
