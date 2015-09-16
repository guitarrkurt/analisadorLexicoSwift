//
//  ViewController.swift
//  Analisador Lexico
//
//  Created by guitarrkurt on 15/09/15.
//  Copyright (c) 2015 guitarrkurt. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var alfabetoArray: NSArray = NSArray()
    var estadosArray : NSMutableArray = NSMutableArray()
    var ttDic: NSMutableDictionary = NSMutableDictionary()
    var edoIni: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Read Automata
        var textFromFile = readFileFromBundle("File", typeFile: "txt")
        //Load Alfabeto, estados, tabla transicion
        if textFromFile != ""{
            loadPropertys(textFromFile)
        } else {
            println("error al leer textFromFile")
        }
        //Read source code file
        var textFromSourceAlgo = readFileFromBundle("SourceCode", typeFile: "algo")
        //Test source code file
        if textFromSourceAlgo != "" {
            test(textFromSourceAlgo)
        } else {
            println("error al leer textFromSourceAlgo")
        }

    }
    func readFileFromBundle(var nameFile:String, var typeFile: String) -> String{
        //Read File
        println("...Read File")
        
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource(nameFile, ofType: typeFile)
        var error: NSError? = NSError()
        var textFromFile = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: &error)
        if textFromFile != nil{
            return textFromFile!
        } else {
            println("\(error)")
            return ""
        }
    }
    func loadPropertys(textFromFile: String) -> Void{
        //Init Tabla Transicion - Propertys
        println("...Load")
        println("Text from file:\n\(textFromFile)")
        
        //Get text from archivo
        var archivo: NSArray = textFromFile.componentsSeparatedByString("\n")
        println("\narchivo: \(archivo)")
        var aux: NSArray = NSArray()
        
        //Load Alfabeto
        alfabetoArray = archivo.objectAtIndex(0).componentsSeparatedByString("\t")
        println("\nalfabetoArray: \(alfabetoArray)")
        
        //Load Matrix - get estadosArray
        var noColums = alfabetoArray.count
        println("\nnoColums: \(noColums)")
        var noRows = archivo.count
        println("noRows: \(noRows)")
        for var i = 1; i < noRows; ++i{
            aux = archivo.objectAtIndex(i).componentsSeparatedByString("\t")
            estadosArray.addObject(aux.objectAtIndex(0))
        }
        println("\nestadosArray: \(estadosArray)")
        
        //Load Matrix - build Dictionary
        var key = ""
        for var i = 1; i < noRows; ++i{
            aux = archivo.objectAtIndex(i).componentsSeparatedByString("\t")
            
            for var j = 1; j < noColums; ++j{
                key = "\(estadosArray.objectAtIndex(i-1)),\(alfabetoArray.objectAtIndex(j))"
                ttDic.setObject(aux.objectAtIndex(j), forKey: key)
                println("key: [ \(key) ] corresponde: \"\(aux.objectAtIndex(j))\"")
            }
            println()
        }
        println("ttDic: \(ttDic)")
        
    }
    func test(textFromSourceAlgo: String) -> Void {
        println("Text source:")
        println("\(textFromSourceAlgo)")
        var key = ""
        var char: Character = " "
        
        if textFromSourceAlgo.isEmpty {
            println("Por favor introdusca algo en: \"textFromSourceAlgo\"")
        } else {
            //Crea la llave con el "primer caracter del string"
            key = "\(edoIni),\(Array(textFromSourceAlgo)[0])"
            println("Init key: \(key)\n")
            var i = 0
            var tipo = ""
            while i < Array(textFromSourceAlgo).count{
                
                char = Character("\(Array(textFromSourceAlgo)[i])")
                println("char: \(char)")
                tipo = queEs(char)
                
                
                if tipo == "EnterOrSpace"{
                    println("has algo EnterOrSpace\n")
                }
                else if tipo == "Letra"{
                    println("has algo Letra\n")
                }
                else if tipo == "Digito"{
                    println("has algo con Digito\n")
                }
                else if tipo == "ExisteAlfabetoOtro"{
                    println("has algo con ExisteAlfabetoOtro\n")
                }
                else if tipo == "NoExisteAlfabeto"{
                    println("has algo con NoExisteAlfabeto\n")
                }
                else {
                    println("default no debe ocurrit\n")
                }
                
                
                
                
                ++i
            }
        }
    }
    func queEs(char: Character) -> String{
        var value = Array("\(char)".unicodeScalars)[0].value
        var tipo = ""
        var band = false
        println("value: \(value)")
        if (value >= 65 && value <= 90) || (value >= 97 && value <= 122) {
            println("Letra")
            tipo = "Letra"
        }
        else if (value >= 48 && value <= 57){
            println("Digito\n")
            tipo = "Digito"
        }
        else
        {
            println("entra, char vale: \(char), value: \(value)")
            //Comprueba si char esta en el alfabeto
            
            if value == 10 || value == 32
            {
                println("EnterOrSpace\n")
                tipo = "EnterOrSpace"
            } else
            {
                
                for var i = 0; i < alfabetoArray.count; ++i
                {
                    if "\(char)" == (alfabetoArray.objectAtIndex(i) as! String)
                    {
                        band = true
                        tipo = "ExisteAlfabetoOtro"
                        println("ExisteAlfabetoOtro")
                        break;
                    }
                }
                if band == false{
                    tipo = "NoExisteAlfabeto"
                    println("No existe en el alfabeto\n")
                }

            }

        }
        
        return tipo
    }
    
    
    
    
    
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}
