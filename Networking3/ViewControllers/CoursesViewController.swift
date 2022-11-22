//
//  CoursesViewController.swift
//  Networking3
//
//  Created by Nataliya Lazouskaya on 17.11.22.
//

import UIKit

class CoursesViewController: UITableViewController {
    
    private var courses = [Course]()
    private var coursesPost = [CoursePost]()
    private var courseName: String?
    private var courseURL: String?
    
    private let url = "https://swiftbook.ru//wp-content/uploads/api/api_courses"
    private let postRequestUrl = "https://jsonplaceholder.typicode.com/posts"
    private let putRequestUrl = "https://jsonplaceholder.typicode.com/posts/1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func fetchData() {
        NetworkManager.fetchData(url: url) { courses in
            self.courses = courses
            print("Thread: ",Thread.current)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchDataWithAlamofire() {
        AlamofireNetworkRequest.sendRequest(url: url) { courses in
            self.courses = courses
            print("Thread: ",Thread.current)
            //    DispatchQueue.main.async {
            self.tableView.reloadData()
            //   }
        }
    }
    
    func postRequest() {
        AlamofireNetworkRequest.postRequest(url: postRequestUrl) { courses in
            self.coursesPost = courses
            print(self.coursesPost)
            print("Thread: ",Thread.current)//main
            //  DispatchQueue.main.async {
            self.tableView.reloadData()
            //  }
        }
    }
    
    func putRequest() {
        AlamofireNetworkRequest.putRequest(url: putRequestUrl) { courses in
            self.coursesPost = courses
            print("Thread: ",Thread.current)//main
            //  DispatchQueue.main.async {
            self.tableView.reloadData()
            //  }
        }
    }
    
    private func configureCell(cell: TableViewCell, for indexPath: IndexPath) {
        
        if courses.count != 0 {
            let course = courses[indexPath.row]
            cell.courseNameLabel.text = course.name
            
            if let numberOfLessons = course.numberOfLessons{
                cell.numberOfLessons.text = "Number of lessons: \(numberOfLessons)"
            }
            
            if let numberOfTests = course.numberOfTests {
                cell.numberOfTests.text = "Number of tests: \(numberOfTests)"
            }
            
            DispatchQueue.global().async {
                guard let imageUrl = URL(string: course.imageUrl!) else { return }
                guard let imageData = try? Data(contentsOf: imageUrl) else { return }
                
                DispatchQueue.main.async {
                    cell.courseImage.image = UIImage(data: imageData)
                }
            }
        } else {
            let course = coursesPost[indexPath.row]
            cell.courseNameLabel.text = course.name
            
            if let numberOfLessons = course.numberOfLessons{
                cell.numberOfLessons.text = "Number of lessons: \(numberOfLessons)"
            }
            
            if let numberOfTests = course.numberOfTests {
                cell.numberOfTests.text = "Number of tests: \(numberOfTests)"
            }
            
            DispatchQueue.global().async {
                guard let imageUrl = URL(string: course.imageUrl!) else { return }
                guard let imageData = try? Data(contentsOf: imageUrl) else { return }
                
                DispatchQueue.main.async {
                    cell.courseImage.image = UIImage(data: imageData)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let webViewController = segue.destination as! WebViewController
        webViewController.selectedCourse = courseName
        
        if let url = courseURL {
            webViewController.courseURL = url
        }
    }
}

//MARK: - TebleView
extension CoursesViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if courses.count == 0 {
            return coursesPost.count
        } else {
            return courses.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TableViewCell
        configureCell(cell: cell, for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let course = courses[indexPath.row]
        courseName = course.name
        courseURL = course.link
        
        performSegue(withIdentifier: "Description", sender: self)
    }
}
