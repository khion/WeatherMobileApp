//
//  WeatherManager.swift
//  WeatherMobileApp
//
//  Created by Rodnick Gayem on 2022-10-15.
//
import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManger: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}


struct WeatherManager {
    
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=47e9b1e090839ff857a20a67697fa567&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetch(cityName: String) {
        let urlString = "\(weatherUrl)&q=\(cityName)"
        performRequest(urlString)
    }
    
    func fetchWeather(latitute: CLLocationDegrees, longtitude: CLLocationDegrees) {
        let urlString = "\(weatherUrl)&lat=\(latitute)&lon=\(longtitude)"
        performRequest(urlString)
    }
    
    func performRequest(_ urlString: String) {
        //        Create URL
        if let url = URL(string: urlString) {
            //        Create a URLSession
            let session = URLSession(configuration: .default)
            
            //        Give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            //        Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
    
}


