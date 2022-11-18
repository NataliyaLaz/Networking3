//
//  DataProvider.swift
//  Networking3
//
//  Created by Nataliya Lazouskaya on 18.11.22.
//

import UIKit

class DataProvider: NSObject {
    
    private var downloadTask: URLSessionDownloadTask!
    var fileLocation: ((URL) -> ())?
    var onProgress: ((Double) -> ())?
    
    private lazy var bgSession: URLSession = {
        //все настройки параметров объекта конфигурации до инициализации сессии, затем любые изменения будут игнорироваться
        let config = URLSessionConfiguration.background(withIdentifier: "com.iosnichek.Networking3")
 //       config.isDiscretionary = true//запуск задачи в оптимальное время (для больших объемов данных Apple рекомендует true) (по умолчанию false)
 //       config.timeoutIntervalForResource = 300//время ожидания сети в секундах
   //     config.waitsForConnectivity = true //ожидает подключения к сети( в background по умолчанию true), если сеть изначально(!) отсутствует
        config.sessionSendsLaunchEvents = true// по завершению загрузки запустится в фоновом режиме AppDelegate/HandleEventsForBackgroundURLSession
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    func startDownload() {
        if let url = URL(string: "https://speed.hetzner.de/100MB.bin") {
            downloadTask = bgSession.downloadTask(with: url)
            downloadTask.earliestBeginDate = Date().addingTimeInterval(3)
            downloadTask.countOfBytesClientExpectsToSend = 512
            downloadTask.countOfBytesClientExpectsToReceive = 100 * 1024 * 1024
            downloadTask.resume()
        }
    }
    
    func stopDownload() {
        downloadTask.cancel()
    }
}

extension DataProvider: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {// тк completionHadler UIKit
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let completionHandler = appDelegate.bgSessionCompletionHandler else { return }
            appDelegate.bgSessionCompletionHandler = nil
            completionHandler()// уведомляем систему, что загрузка была завершена
        }
    }
}

extension DataProvider: URLSessionDownloadDelegate { // чтобы получить ссылку на загруженный файл и отобразить ход загрузки данных
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //location - ссылка на временную директорию, куда сохраняется файл
        print("Did finish downloading: \(location.absoluteString)")
        // сохраняем ссылку на временную директорию
        DispatchQueue.main.async {
            self.fileLocation?(location)
        }
    }
    
    //ход загрузки
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        print("Download progress: \(progress)")
        
        DispatchQueue.main.async {
            self.onProgress?(progress)
        }
    }
}

extension DataProvider: URLSessionTaskDelegate {
    //если соединение восстановлено
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        //ожидание соединения, обновление интерфейса и прочее
    }
}
