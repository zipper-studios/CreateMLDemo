//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectHTTP
import PerfectHTTPServer
import CreateML
import Foundation

// An example request handler.
// This 'handler' function can be referenced directly in the configuration below.
func handler(request: HTTPRequest, response: HTTPResponse) {
	// Respond with a simple message.
	response.setHeader(.contentType, value: "text/html")
	response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
	// Ensure that response.completed() is called when your processing is done.
	response.completed()
}

func createModelHandler(request: HTTPRequest, response: HTTPResponse) {
    if #available(OSX 10.14, *) {
        do {
            // Create the model
            let classifier = try MLImageClassifier(trainingData: .labeledDirectories(at: URL(fileURLWithPath: "/Users/ralucamarusca/Documents/Licenta/Training-Data", isDirectory: true)), parameters: MLImageClassifier.ModelParameters(maxIterations: 20))
            
            //Evaluate the model
            print("------Evaluation-------")
            let evaluation = classifier.evaluation(on: .labeledDirectories(at: URL(fileURLWithPath: "/Users/ralucamarusca/Documents/Licenta/Validation-Data", isDirectory: true)))
            print(evaluation)
            
            // Save the model
            try classifier.write(to: URL(fileURLWithPath: "/Users/ralucamarusca/Documents/Licenta/MLModel/UsersModel.mlmodel"), metadata: MLModelMetadata(author: "Raluca Marusca", shortDescription: "This is my first model", license: nil, version: "1.0", additional: nil))
            
            print("Model saved successfully")
            response.setHeader(.contentType, value: "application/json")
                .setBody(string: "{\"status\":\"The model was created and saved to the disk\"}")
                .completed()
        } catch {
            response.setHeader(.contentType, value: "application/json")
                .setBody(string: "{\"status\":\"\(error)\"}")
                .completed()
        }
    } else {
        // Fallback on earlier versions
        response.setHeader(.contentType, value: "application/json")
            .setBody(string: "{\"status\":\"The OS version needs to be 10.14 or newer\"}")
            .completed()
    }
    
    
}


// Configure one server which:
//	* Serves the hello world message at <host>:<port>/
//	* Serves static files out of the "./webroot"
//		directory (which must be located in the current working directory).
//	* Performs content compression on outgoing data when appropriate.
var routes = Routes()
routes.add(method: .get, uri: "/", handler: handler)
routes.add(method: .get, uri: "/**",
		   handler: StaticFileHandler(documentRoot: "./webroot", allowResponseFilters: true).handleRequest)
routes.add(method: .get, uri: "/trainModel", handler: createModelHandler)
try HTTPServer.launch(name: "localhost",
					  port: 8181,
					  routes: routes,
					  responseFilters: [
						(PerfectHTTPServer.HTTPFilter.contentCompression(data: [:]), HTTPFilterPriority.high)])


