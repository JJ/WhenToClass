require "rake/testtask"

task default: %w[install]
task test: %w[testunitariosasignaturas testunitariosgrado testunitariosgestorgrados]

desc "Instala todas las dependencias"
task :install do
	exec "bundle install"
end

Rake::TestTask.new do |t|
	t.name = "testunitariosasignaturas"
	t.test_files = FileList['t/TestAsignaturas.rb']
end

Rake::TestTask.new do |t|
	t.name = "testunitariosgrado"
	t.test_files = FileList['t/TestGrado.rb']
end

Rake::TestTask.new do |t|
	t.name = "testunitariosgestorgrados"
	t.test_files = FileList['t/TestGestorGrados.rb']
end
