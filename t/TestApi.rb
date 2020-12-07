require "minitest/autorun"
require "minitest/mock"
require "rack/test"

require_relative "../lib/asignatura.rb"
require_relative "../lib/horarioasignatura.rb"
require_relative "../lib/asignaturaerror.rb"
require_relative "../lib/gestorgrados.rb"
require_relative "../lib/grado.rb"
require_relative "../lib/FSDator.rb"
require_relative "../lib/app.rb"

class TestApi < Minitest::Test
    include Rack::Test::Methods
    def app
        App
    end
    
    def test_raiz_ok
        get '/'    
            res = '{"status":200}'
            assert_equal(last_response.content_type, 'application/json')
            assert_equal(last_response.body, res)
    end

    #####################################################################################
	#Tests que comprueba que funciona correctamente el método para añadir grado
	#
	#método: añadir grado en el microservicio
	#HU10
	#####################################################################################
    def test_anadir_grado_ok
        a_anadir = {"id"=>"0e78a27a1e605334c0ba","asignaturas"=>[{"id"=>"50bbd28fa87ba567f7bd","siglas"=>"IV","nombre"=>"Infraestructura Virtual","horario_teoria"=>{"dia"=>"2-Martes","hora_inicio"=>"11:30","hora_fin"=>"13:30","grupo"=>"T"},"horario_practicas"=>[{"dia"=>"2-Martes","hora_inicio"=>"9:30","hora_fin"=>"11:30","grupo"=>"P1"},{"dia"=>"5-Viernes","hora_inicio"=>"9:30","hora_fin"=>"11:30","grupo"=>"P2"}],"turno_presencialidad"=>[["28sep - 2oct","12oct - 16oct","26oct - 30oct","9nov - 13nov","23nov - 27nov","7dec - 11dec","21dec - 22dec"],["5oct - 9oct","19oct - 23oct","2nov - 6nov","16nov - 20nov","30nov - 4dec","14dec - 18dec","8jan y 11jan - 14jan"]],"grupo"=>"A","enlaces_clase_online"=>["https://meet.jit.si/IV-ETSIIT-UGR-2020","https://meet.jit.si/IV-ETSIIT-UGR-2020","https://meet.jit.si/IV-ETSIIT-UGR-2020"],"curso"=>"4"}],"nombre_grado"=>"Ingeniería Informática","enlace_grado"=>"https://grados.ugr.es/informatica/"}
        post '/grado', a_anadir.to_json    
            res = {"añadido"=>"0e78a27a1e605334c0ba"}
            res = res.to_json
            assert_equal(last_response.content_type, 'application/json')
            assert_equal(last_response.body, res)
        delete '/grado/0e78a27a1e605334c0ba' #borramos para no tener conflictos en sucesivos tests
    end

end