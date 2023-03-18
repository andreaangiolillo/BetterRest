//
//  ContentView.swift
//  BetterRest
//
//  Created by Andrea on 11/03/2023.
//
import CoreML
import SwiftUI


struct ContentView: View {
    @State private var wakeUp = defaultWakeUpTime
    @State private var sleepAmount = 8.0
    @State private var coffeAmount = 1
    
    var sleepingTimeMessage : String {
        return calculateBedtime()
    }
    
    
    static var defaultWakeUpTime: Date{
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView{
            Form {
                VStack(alignment: .leading, spacing: 0){
                    Text("When do you want to wake up?").font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute).labelsHidden()
                    
                }
                
                VStack(alignment: .leading, spacing: 0){
                    Text("Desidered amount of sleep").font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
               
                VStack(alignment: .leading, spacing: 0){
                    Text("Daily coffee intake").font(.headline)
                    Stepper(coffeAmount == 1 ? "1 cup" : "\(coffeAmount) cups", value: $coffeAmount, in: 1...20)
                }
                
                Section{
                    Text(sleepingTimeMessage).font(.title)
                } header: {
                    Text("BedTime")
                }
            }
            .navigationTitle("Better Rest")
        }
        
    }
    
    func calculateBedtime() -> String{
        
        do {
            let config = MLModelConfiguration()
            let model = try BetterRestModel(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeAmount ))
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch{
            return "Sorry, there was a problem calculating your bedtime"
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
