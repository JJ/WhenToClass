require "roda"
require "json"
require_relative "../lib/FSDator.rb"
require_relative "../lib/gestorgrados.rb"
require_relative "../lib/parse.rb"
require_relative "middleware"
require_relative "../lib/MONGODator.rb"

class App < Roda
    ####################
    #Plugins
    plugin :all_verbs #por defecto solo trae GET y POST, queremos más.
    plugin :response_request #nos permite personalizar más las respuestas
    use Rack::CustomLogger

    ####################
    #Rutas
    route do |r|
            @dator = MONGODator.new(ENV['MONGODB_URI'])
        ####################
        #Variables
        @gestor = GestorGrados.new(@dator)
        @parse = Parse.new
        #Directorio Raíz
        r.root do
            response.status = 200
            response['Content-Type'] = 'application/json'
            body = 
                {
                    "status"=>"OK"
                }
            response.write(body.to_json)
        end
        r.on "status" do
            response.status = 200
            response['Content-Type'] = 'application/json'
            body = 
                {
                    "status"=>"OK"
                }
            response.write(body.to_json)
        end

        # /grados
        r.on "grados" do
            # GET /grados
            # curl --request GET http://localhost:9292/grados
            r.get do
                #obtenemos todos los grados
                grados = Array.new
                grados = @gestor.todosGrados()
                gradosjson = Array.new
                #los pasamos a JSON
                for i in 0..grados.length()-1
                    gradosjson.push(@parse.gradoToJSON(grados[i]))
                end

                #preparamos la respuesta
                response.status = 200
                response['Content-Type'] = 'application/json'
                response.write(gradosjson.to_json)
            end
        end

        # /grado
        r.on "grado" do
            # /grado/$ID
            r.on String do |id|
                
                # Rama /grado/$ID/asignatura/$ID2
                r.on "asignatura" do
                    r.on String do |id2|
                        # /asignatura/$ID/horario
                        r.get "horario" do
                            begin
                                if r.params['grupo'] == nil
                                    response.status = 404
                                    response['Content-Type'] = 'application/json'
                                    res = {
                                        "error"=>"es necesario pasar la variable grupo"
                                    }
                                    response.write(res.to_json)   
                                else
                                    grupo = r.params['grupo']
                                    horario = @gestor.horarioAsignatura(id, id2, grupo)
                                    arrayHorario = Array.new
                                    for i in 0..horario.length()-1
                                        arrayHorario.push(@parse.horarioToJSON(horario[i]))
                                    end
                                    res = {
                                        "horario"=>arrayHorario
                                    }
                                    response.status = 200
                                    response['Content-Type'] = 'application/json'
                                    response.write(res.to_json)
                                end
                            rescue 
                                response.status = 404
                                    response['Content-Type'] = 'application/json'
                                    res = {
                                        "error"=>"No se ha encontrado el grado o asignatura"
                                    }
                                response.write(res.to_json)  
                            end
                        end

                        # grado/$ID1/asignatura/$ID2/enlace
                        r.get "enlace" do
                            begin
                                if r.params['grupo'] == nil
                                    response.status = 404
                                    response['Content-Type'] = 'application/json'
                                    res = {
                                        "error"=>"es necesario pasar la variable grupo"
                                    }
                                    response.write(res.to_json)   
                                else
                                    grupo = r.params['grupo']
                                    enlaces = @gestor.enlacesAsignatura(id, id2, grupo)

                                    res = {
                                        "enlace"=>enlaces
                                    }
                                    response.status = 200
                                    response['Content-Type'] = 'application/json'
                                    response.write(res.to_json)
                                end
                            rescue
                                response.status = 404
                                response['Content-Type'] = 'application/json'
                                res = {
                                    "error"=>"No se ha encontrado el grado o asignatura"
                                }
                                response.write(res.to_json)  
                            end
                        end

                        # grado/$ID1/asignatura/$ID/turnos
                        r.get "turno" do
                            begin
                                if r.params['turno'] == nil or r.params['mes'] == nil
                                    response.status = 404
                                    response['Content-Type'] = 'application/json'
                                    res = {
                                        "error"=>"es necesario pasar la variable turno y mes"
                                    }
                                    response.write(res.to_json)   
                                else
                                    turno = r.params['turno']
                                    mes = r.params['mes']
                                    turnos = @gestor.turnosAsignatura(id, id2, turno,mes)

                                    res = {
                                        "turnos"=>turnos
                                    }
                                    response.status = 200
                                    response['Content-Type'] = 'application/json'
                                    response.write(res.to_json)
                                end
                            rescue
                                response.status = 404
                                response['Content-Type'] = 'application/json'
                                res = {
                                    "error"=>"No se ha encontrado el grado o asignatura"
                                }
                                response.write(res.to_json)  
                            end
                        end
                            
                        # grado/$ID1/asignatura/$ID
                        # curl --request GET http://localhost:9292/grado/0e78a27a1e605334c0ba/asignatura/50bbd29ff87ba567f7bd
                        r.get do
                            begin
                                asignatura = @gestor.obtenerAsignatura(id, id2)
                                asigjson = @parse.asignaturaToJSON(asignatura)

                                #Preparamos la respuesta
                                response.status = 200
                                response['Content-Type'] = 'application/json'
                                response.write(asigjson.to_json)
                            rescue
                                response.status = 404
                                response['Content-Type'] = 'application/json'
                                res = {
                                    "error"=>"No existe el grado o la asignatura"
                                }
                                response.write(res.to_json)    
                            end
                            
                        end

                        r.delete do
                            begin
                                @gestor.eliminaAsignatura(id, id2)
                                res = {
                                    "eliminado"=>id2
                                }
                                response.status = 200
                                response['Content-Type'] = 'application/json'
                                response.write(res.to_json)
                            rescue
                                response.status = 404
                                response['Content-Type'] = 'application/json'
                                res = {
                                    "error"=>"No existe el grado o la asignatura"
                                }
                                response.write(res.to_json)
                            end
                        end

                        # put /grado/$ID/asignatura/$ID2
                        # curl --header "Content-Type:application/json" --request PUT --data '{"id":"50bbd29ff87ba567f7bd","siglas":"IV","nombre":"Infraestructura Virtual","horario_teoria":{"dia":"2-Martes","hora_inicio":"11:30","hora_fin":"13:30","grupo":"T"},"horario_practicas":[{"dia":"2-Martes","hora_inicio":"9:30","hora_fin":"11:30","grupo":"P1"},{"dia":"5-Viernes","hora_inicio":"9:30","hora_fin":"11:30","grupo":"P2"}],"turno_presencialidad":[["28sep - 2oct","12oct - 16oct","26oct - 30oct","9nov - 13nov","23nov - 27nov","7dec - 11dec","21dec - 22dec"],["5oct - 9oct","19oct - 23oct","2nov - 6nov","16nov - 20nov","30nov - 4dec","14dec - 18dec","8jan y 11jan - 14jan"]],"grupo":"A","enlaces_clase_online":["https://meet.jit.si/IV-ETSIIT-UGR-2020","https://meet.jit.si/IV-ETSIIT-UGR-2020","https://meet.jit.si/IV-ETSIIT-UGR-2020"],"curso":"4"}' http://localhost:9292/grado/0e78a27a1e605334c0ba/asignatura/50bbd29ff87ba567f7bd
                        r.put do
                            begin
                                asignatura = JSON.parse(r.body.read)
                
                                parsed = @parse.jsonToAsignatura(asignatura)
        
                                @gestor.añadeAsignatura(id ,parsed)
        
                                #Preparamos la respuesta
                                response.status = 200
                                response['Content-Type'] = 'application/json'
                                response['Location'] = '/grado/' + id + '/asignatura/' + parsed.id

                                res = {
                                    "añadido"=>parsed.id
                                }
                                response.write(res.to_json) 
                            rescue
                                response.status = 404
                                response['Content-Type'] = 'application/json'
                                res = {
                                    "error"=>"No existe el grado o la asignatura"
                                }
                                response.write(res.to_json)
                            end
                        end
                    end
                end

                # /grado/$ID/asignaturas
                r.on "asignaturas" do
                    r.get do
                        begin
                            asignaturas = @gestor.todasAsignaturas(id)
                            asignaturasjson = Array.new
                            for i in 0..asignaturas.length()-1
                                asignaturasjson.push(@parse.asignaturaToJSON(asignaturas[i]))
                            end

                            #Preparamos la respuesta
                            response.status = 200
                            response['Content-Type'] = 'application/json'
                            response.write(asignaturasjson.to_json) 
                        rescue
                            response.status = 404
                            response['Content-Type'] = 'application/json'
                            res = {
                                "error"=>"No existe el grado o no contiene ninguna asignatura"
                            }
                            response.write(res.to_json)
                        end
                        
                    end
                end
                # get /grado/$ID
                r.get do
                    begin
                        grado = @gestor.obtenerGrado(id)
                        jsongrado = @parse.gradoToJSON(grado)
                        response.status = 200
                        response['Content-Type'] = 'application/json'
                        response.write(jsongrado.to_json) 
                    rescue
                        response.status = 404
                        response['Content-Type'] = 'application/json'
                        res = {
                            "error"=>"No existe el grado"
                        }
                        response.write(res.to_json)
                    end
                    
                end

                # delelete /grado/$ID
                r.delete do
                    begin
                        @gestor.eliminarGrado(id)
                        res = {
                            "eliminado"=>id
                        }
                        response.status = 200
                        response['Content-Type'] = 'application/json'
                        response.write(res.to_json) 
                    rescue
                        response.status = 404
                        response['Content-Type'] = 'application/json'
                        res = {
                            "error"=>"No existe el grado"
                        }
                        response.write(res.to_json)
                    end
                end

                # put /grado
                # curl --header "Content-Type:application/json" --request PUT --data '{"id":"123","asignaturas":[],"nombre_grado":"informatica", "enlace_grado":"hola"}' http://localhost:9777/grado/123
                r.put do
                    begin
                        grado = JSON.parse(r.body.read)
                        parsed = @parse.jsonToGrado(grado)
                        id2 = @gestor.AnadirGrado(parsed)
                        res = {
                            "añadido"=>id2
                        }
                        response.status = 200
                        response['Content-Type'] = 'application/json'
                        response['Location'] = '/grado/' + id2
                        response.write(res.to_json)      
                    rescue
                        response.status = 404
                        response['Content-Type'] = 'application/json'
                        res = {
                            "error"=>"Error al añadir el grado"
                        }
                        response.write(res.to_json)
                    end

                end

            end
        end
    end
end