//
//  AlamofireNetworkRequest.swift
//  Networking3
//
//  Created by Nataliya Lazouskaya on 21.11.22.
//

import UIKit
import Alamofire

class AlamofireNetworkRequest {
    
    static var onProgress: ((Double) -> ())?
    static var completed: ((String) -> ())?
    
    // без validate результат всегда будет success за искл ошибки из-за отсутствия интернета
    static func sendRequest(url: String, completion: @escaping (_ courses: [Course]) -> ()) {
        guard let url = URL(string: url) else { return }
        AF.request(url, method: .get)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    var courses = Course.getArray(from: value)!
                    completion(courses)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    static func downloadImage(url: String, completion: @escaping (_ image: UIImage) -> ()) {
        guard let url = URL(string: url) else { return }
        
        AF.request(url).responseData { responseData in
            switch responseData.result {
            case .success(let data):
                guard let image = UIImage(data: data) else { return }
                completion(image)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    //для получения JSON
    static func responseData(url: String) {
        AF.request(url).responseData { responseData in
            switch responseData.result {
            case .success(let data):
                guard let string = String(data: data, encoding: .utf8) else { return }
                print(string)// JSON строка
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    //ответ приходит в виде JSON строки
    static func responseString(url: String) {
        AF.request(url).responseString { responseString in
            switch responseString.result {
            case .success(let string):
                print(string)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    //не обрабатывает данные полученные от сервера, а выдает их в том виде, в каком они были получены
    static func response(url: String) {
        AF.request(url).response { response in
            guard let data = response.data, let string = String(data: data, encoding: .utf8) else { return }
            print(string)
        }
    }
    
    static func downloadImageWithProgress(url: String, completion: @escaping (_ image: UIImage) -> ()) {
        guard let url = URL(string: url) else { return }
        
        AF.request(url)
            .validate()
            .downloadProgress { (progress) in
                //                print("totalUnitCount: \(progress.totalUnitCount)\n")
                //                print("completedUnitCount:\(progress.completedUnitCount)\n")
                //                print("fractionCompleted:\(progress.fractionCompleted)\n")
                //                print("loclizedDescription:\(progress.localizedDescription!)\n")
                //                print("---------------------------------------------------------")
                
                self.onProgress?(progress.fractionCompleted)
                self.completed?(progress.localizedDescription)
                
            }.response { response in
                guard let data = response.data, let image = UIImage(data: data) else { return }
                print(Thread.current)//main
                //  DispatchQueue.main.async {
                completion(image)
                //  }
            }
    }
    
    static func postRequest(url: String, completion: @escaping (_ courses: [CoursePost]) -> ()) {
        guard let url = URL(string: url) else { return }
        let userData: [String: Any] = ["name": "Network request",
                                       "link": "https://swiftbook.ru/contents/our-first-applications/",
                                       "imageUrl": "https://swiftbook.ru/wp-content/uploads/sites/2/2018/08/notifications-course-with-background.png",
                                       "numberOfLessons": "18",
                                       "numberOfTests": "10"]//тип словаря, с которым работает Alamofire
        AF.request(url, method: .post, parameters: userData).responseDecodable(of: CoursePost.self){ response in
            guard let statusCode = response.response?.statusCode else { return }
            print("status Code ", statusCode)
            
            switch response.result {
            case .success(let course):
                var courses = [CoursePost]()
                courses.append(course)
                completion(courses)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //after depreciation see postRequest example
    static func putRequest(url: String, completion: @escaping (_ courses: [CoursePost]) -> ()) {
        guard let url = URL(string: url) else { return }
        let userData: [String: Any] = ["name": "Network request with Alamofire",
                                       "link": "https://swiftbook.ru/contents/our-first-applications/",
                                       "imageUrl": "https://swiftbook.ru/wp-content/uploads/sites/2/2018/08/notifications-course-with-background.png",
                                       "numberOfLessons": "19",
                                       "numberOfTests": "11"]//тип словаря, с которым работает Alamofire
        AF.request(url, method: .put, parameters: userData).responseJSON{ response in
            guard let statusCode = response.response?.statusCode else { return }
            print("status Code ", statusCode)
            
            switch response.result {
            case .success(let value):
                print(value)
                guard let jsonObject = value as? [String: Any], let course = CoursePost(json: jsonObject) else { return }
                print(course)
                var courses = [CoursePost]()
                courses.append(course)
                completion(courses)
            case .failure(let error):
                print(error)
            }
        }
    }

    static func uploadImage(url: String) {
        
        guard let url = URL(string: url) else { return }
        
        let image = UIImage(named: "Notification")!
        let data = image.pngData()!
        
        let httpHeaders: Alamofire.HTTPHeaders = ["Authorization": "Client-ID 1bd22b9ce396a4c"]
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data, withName: "image")    //кодируем для передачи на сервер, не подходит для больших объемов данных (нужно выполять потоковую передачу данных с диска: сначала подготовить данные, записать на диск, затем передать в данный блок в виде ссылки на готовый файл
            //https://api.imgur.com/endpoints/image#image-upload
        }, to: url, headers: httpHeaders) 
        .validate()
        .uploadProgress(closure: { progress in
            print(progress)
        })
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                print(value)
            case .failure(let error):
                print(error)
            }
        }
    }
}
