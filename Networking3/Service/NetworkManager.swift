//
//  NetworkManager.swift
//  Networking3
//
//  Created by Nataliya Lazouskaya on 17.11.22.
//

import UIKit

class NetworkManager {
    
    static func getRequest(url: String) {
        guard let url = URL(string: url) else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { data, response, error in
            guard let response = response, let data = data else { return }
            print(response)
            print(data)
            
            do {
                //пробуем преобразовать данные в json
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print(error)
            }
        }.resume()
    }
    
    static func postRequest(url: String) {
        guard let url = URL(string: url) else { return }
        
        let userData = ["Course": "Networking",
                        "Lesson": "GET and POST Requests"]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        //преобразовываем данные в json
        guard let httpBody = try? JSONSerialization.data(withJSONObject: userData, options: []) else { return }
        
        request.httpBody = httpBody
        //значения параметров из консоли в Headers. Без след. строки весь наш словарь приходит ключом с пустым полем значения
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            guard let response = response, let data = data else { return }
            print(response)
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch {
                print(error)
            }
        }.resume()
    }
    
    static func downloadImage(url: String, completion: @escaping(_ image: UIImage) -> ()) {
        guard let url = URL(string: url) else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }.resume()
    }
    
    static func fetchData(url: String, completion: @escaping (_ courses: [Course]) -> ()) {
        guard let url = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let courses = try decoder.decode([Course].self, from: data)
                completion(courses)
            } catch let error{
                print("Error serializationjson", error.localizedDescription)
            }
        }.resume()
    }
    
    static func uploadImage(url: String) {
        let image = UIImage(named: "Notification")!
        
        let httpHeaders = ["Authorization": "Client-ID 3b85b74ccc6f0fe"]
        let clientSecret = "d7266cfc33c9d50c1a486bb3817edff2ec59d916"
        // key from API
        guard let imageProperties = ImageProperties(withImage: image, forKey: "image") else { return }
        
        guard let url = URL(string: url) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = httpHeaders
        request.httpBody = imageProperties.data
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
}
