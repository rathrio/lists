desc "Generate Yard documentation of project source."
task :docs do
  system 'yardoc --no-private --protected app/**/*.rb'
  system 'bundle exec erd'
  puts "Generated docs `docs/` and UML diagram 'erd.pdf'."
end
