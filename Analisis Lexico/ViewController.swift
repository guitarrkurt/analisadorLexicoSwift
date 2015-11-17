//
//  ViewController.swift
//  Analisador Lexico
//
//  Created by guitarrkurt on 15/09/15.
//  Copyright (c) 2015 guitarrkurt. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var estadosFinalesArray: [String] = []
    var aux: [String] = []
    var fila: [String] = []
    var alfabetoArray: [String] = []
    var estadosArray : NSMutableArray = NSMutableArray()
    var ttDic: NSMutableDictionary = NSMutableDictionary()
    var ttPrueba: Dictionary<String, String> = [:]
    var estado: String! = String()
    var estadoEsNil: String? = String()
    var finalesArray: NSMutableArray = NSMutableArray()
    var key = String()
    var buffer = String()
    var bufferID = String()
    var caracter: Character = " "
    var token = String()
    var noEnters = Int()
    var palabrasReservadasArray: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Read Automata
        print("Leyendo... File.txt")
        let textFromFile = readFileFromBundle("File", typeFile: "txt")
        //Load Alfabeto, estados, tabla transicion
        if textFromFile != ""{
            loadPropertys(textFromFile)
        } else {
            print("error al leer textFromFile")
        }
        //Leer palabras reservadas
        print("Leyendo... Palabras.reservadas")
        let textFromPalabrasReservadas = readFileFromBundle("Palabras", typeFile: "reservadas")
        if textFromPalabrasReservadas != ""{
            palabrasReservadasArray = cargarPalabrasReservadas(textFromPalabrasReservadas)
        }else{
            print("Error al leer Palabras.reservadas")
        }
        //Read source code file
        print("Leyendo... SourceCode.algo")
        var textFromSourceCode = readFileFromBundle("SourceCode", typeFile: "algo")
        //Test source code file
        if textFromSourceCode != "" {
            textFromSourceCode = preprosesamiento(textFromSourceCode)
            obtenerTokens(textFromSourceCode)
        } else {
            print("Error al leer SourceCode.algo")
        }

    }
    func cargarPalabrasReservadas(textFromPalabrasReservadas: String) -> [String]{
        return textFromPalabrasReservadas.componentsSeparatedByString("\n")
    }
    func preprosesamiento(textFromSourceCode: String) -> String{
        var i = 0
        let lenghtSourceCodeAlgo = Array(textFromSourceCode.characters).count
        var tipo = ""
        var textoLimpio = ""
        while(i < lenghtSourceCodeAlgo){
            caracter = Character("\(Array(textFromSourceCode.characters)[i])")
            print("caracter: \(caracter)")
            
            /*Si el caracter es letra, digito, o esta en el alfabeto, es VALIDO*/
            /*De lo contrario eliminar espacios, enters y comentarios*/
            
            tipo = queTipoEs(caracter)
            
            if tipo == "Enter"{
                noEnters++
            }
            else if tipo == "Espacio"{
                //No hagas nada
            }
            else if tipo == "NoExisteAlfabeto"{
                print("Error en la linea \(noEnters+1):")
                print("\"\(caracter)\" No pertence al Alfabeto")
                exit(1)
                
            }else{
                //Concatena para quitar enters y espacios
                textoLimpio = "\(textoLimpio)\(caracter)"
                print("textoLimpio: \(textoLimpio)")
            }
            
            ++i
        }
        return textoLimpio
    }
    func readFileFromBundle(nameFile:String, typeFile: String) -> String{
        //Read File
        print("...Read File")
        
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource(nameFile, ofType: typeFile)
        //var error: NSError? = NSError()
        var textFromFile: String?
        do {
            textFromFile = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        } catch {
            //error = error1
            textFromFile = nil
        }
        if textFromFile != nil{
            return textFromFile!
        } else {
            //print("\(error)")
            return ""
        }
    }
    func loadPropertys(textFromFile: String) -> Void{
        //Init Tabla Transicion - Propertys
        print("...Load")
        print("Text from file:\n\(textFromFile)")
        
        //Get text from archivo
        let archivo: Array = textFromFile.componentsSeparatedByString("\n")
        print("\narchivo: \(archivo)")
        //*var aux: NSArray = NSArray()
        
        //Cargamos el Alfabeto, excluyendo la columna "final"
        alfabetoArray = archivo[0].componentsSeparatedByString("\t")
        print("alfabetoArray: \(alfabetoArray)")
        
        /*for i = 0; i < alfabetoArray.count; ++i{
        
        if (alfabetoArray[i] == "final"){
        alfabetoArray.removeAtIndex(i)
        }
        }*/
        print("\nalfabetoArray: \(alfabetoArray)")
        
        //Load Matrix - get estadosArray
        let noColums = alfabetoArray.count
        print("\nnoColums: \(noColums)")
        let noRows = archivo.count
        print("noRows: \(noRows)")
        for var i = 1; i < noRows; ++i{
            aux = archivo[i].componentsSeparatedByString("\t")
            estadosArray.addObject(aux[0])
        }
        print("\nestadosArray: \(estadosArray)")
        
        //Load Matrix - build Dictionary
        //Empezamos de 1 exluyendo la columna de los Estados(n) y la fila de Alfabeto(m)
        for var i = 1; i < noRows; ++i{
            fila = archivo[i].componentsSeparatedByString("\t")
            
            for var j = 1; j < noColums; ++j{
                
                key = "\(estadosArray[i-1]),\(alfabetoArray[j])"
                ttDic.setValue(fila[j], forKey: key)
                print("key: [ \(key) ] corresponde: \"\(fila[j])\"")
            }
            print("")
        }
        print("ttDic: \(ttDic)")
        
        
        //Load EstadosFinalesArray
        for var i = 0; i < estadosArray.count; ++i{
            key = "\(i),final"
            if (ttDic.objectForKey(key) as! String) == "si"{
                estadosFinalesArray.append(estadosArray[i] as! String)
            }
        }
        print("estadosFinalesArray: \(estadosFinalesArray)")
        
        
    }
    func obtenerTokens(textFromSourceCode: String) -> Void {
        print("Texto leido:")
        print("\(textFromSourceCode)")
        
        if textFromSourceCode.isEmpty {
            print("Por favor introdusca algo en el archivo: \"textFromSource.algo\"")
        } else {
            
            let lenghtSourceCodeAlgo = Array(textFromSourceCode.characters).count
            var i = 0
            
            estadoEsNil = obtenerEstadoIni()
            print("estadoInicial: \(estadoEsNil)")
            estado = estadoEsNil
            key = ""
                
            while i < lenghtSourceCodeAlgo{
//                print("estado: \(estado)")
                
                caracter = Character("\(Array(textFromSourceCode.characters)[i])")
                print("caracter: \(caracter)")
                
                //Puede ser letra
                if queTipoEs(caracter) == "Letra"
                {
                    //Es Letra
//                    print("Es letra...")
                    //Key
                    key = "\(estado),letra"
//                    print("Key: \(key)")
                }
                //Puede ser digito
                else if queTipoEs(caracter) == "Digito"
                {   //Es Digito
//                    print("Es digito...")
                    //Key
                    key = "\(estado),digito"
//                    print("Key: \(key)")
                }
                //Puede ser un simbolo porque ya eliminamos los enter y espacios
                else{
                    key = "\(estado!),\(caracter)"
//                    print("Key: \(key)")
                }

                
                estadoEsNil = ttDic.objectForKey(key) as? String
//                print("estadoEsNil: \(estadoEsNil)")
                
                if estadoEsNil != nil && estadoEsNil != "_"
                {       //Si consigue un estado inicial valido
                    
                    estado = estadoEsNil
//                    print("estadoFromDictionary: \(estado)")
                    
                    if esEstadoFinal(estado!)
                    {
                        //Imprime el token con el nombre de token que le corresponde seguido del buffer
//                        print("El edo \(estado!) es final")
                        //Obtenemos el token
                        key = "\(estado!),token"
//                        print("key: \(key)")
                        token = ttDic.objectForKey(key) as! String
                        if token == "ID" && esPalabraReservada(buffer){
                            print("*\(buffer) Palabra Reservada")
                        }else{
                            if buffer == ""{
                                print("**\(caracter) \(token)")
                            }else{
                                if i == retrocesos(estado, index: i){
                                    //Si no retrocede concatena
                                    buffer = "\(buffer)\(caracter)"
                                    print("*\(buffer) \(token)")
                                }else{
                                    //Si retrocede no concatenes
                                    print("*\(buffer) \(token)")
                                }
                            }
                        }

                        //RETROCEDER
                        i = retrocesos(estado, index: i)

                        //Limpiamos
                        estado = obtenerEstadoIni()
//                        print("estado: \(estado!)")
                        buffer = ""
//                        print("buffer: \(buffer)")
                        key = ""
//                        print("key: \(key)")
                        caracter = " "

                    }else
                    {
                        buffer = "\(buffer)\(caracter)"
                        print("buffer: \(buffer)")
                    }
                }else
                {
                    print("El estado es NIL")
                    print("Verifica que la convinacion KEY exista en el Diccionario: \(ttDic)")
                    print("Se encontro un nil o un _")
                    print("Error el caracter -> \(caracter) <- no se encuentra en el alfabeto")
                    exit(1)
                }
                
                ++i
            }
            //Fin While
            print("Termino de leer el archivo")
        }
    }
    func esPalabraReservada(buffer: String) -> Bool{
        for var i = 0; i < palabrasReservadasArray.count; ++i{
            if buffer == palabrasReservadasArray[i]{
                return true
            }
        }
        return false
    }
    
    func retrocesos(estado: String, index: Int) -> Int{
        key = "\(estado),retroceso"
        estadoEsNil = ttDic.objectForKey(key) as? String
        
        if estadoEsNil != nil{
            return index-Int(estadoEsNil!)!
            
        }else{
            print("Error estado: \(estado) no valido")
            exit(1)
        }
    }
    func obtenerEstadoIni() -> String?{
        if estadosArray.count > 0{
            return estadosArray[0] as? String
        }else{
            print("El array estadosArray esta vacio, no se encontro un estado inicial: \(estadosArray)")
            return nil
        }
    }
    func esEstadoFinal(estado: String) -> Bool{
        for var i = 0; i < estadosFinalesArray.count; ++i{
            if estado == estadosFinalesArray[i]{
                return true
            }
        }
        return false
    }
    func caracterEstaAlfabeto(caracter: Character) -> Bool{
        for var i = 0; i < alfabetoArray.count; ++i{
            if "\(caracter)" == alfabetoArray[i]{
                return true
            }
        }
        return false
    }
    func queTipoEs(char: Character) -> String{
        let value = Array("\(char)".unicodeScalars)[0].value
        var tipo = ""
        var band = false
//        print("value: \(value)")
        if (value >= 65 && value <= 90) || (value >= 97 && value <= 122) {
//            print("Letra")
            tipo = "Letra"
        }
        else if (value >= 48 && value <= 57){
//            print("Digito\n")
            tipo = "Digito"
        }
        else
        {
//            print("char: \(char), value: \(value)")
            //Comprueba si char esta en el alfabeto
            if value == 10
            {
//                print("Enter\n")
                tipo = "Enter"
            }else if value == 32{
//                print("Espacio\n")
                tipo = "Espacio"
            }else
            {
                for var i = 0; i < alfabetoArray.count; ++i
                {
                    if "\(char)" == (alfabetoArray[i])
                    {
                        band = true
                        tipo = "ExisteAlfabeto"
//                        print("ExisteAlfabeto")
                        break;
                    }
                }
                if band == false{
                    tipo = "NoExisteAlfabeto"
//                    print("No existe en el alfabeto\n")
                }
                
            }
            
        }
        return tipo
    }
    
}
