//
//  Sets.swift
//  LeetcodeTracker
//
//  Created by Sathvik Konuganti on 10/14/22.
//

import SwiftUI
import Charts
import AxisContribution

struct StatsView: View {
    @StateObject var data = DataModel()
    @AppStorage("login") private var login: Bool = false
    @AppStorage("username") private var username: String = ""
    @State var lineWidth: CGFloat
    @State var fontSize: CGFloat
    let dateFormatter = DateFormatter()
    var dates = [Date()]
    var body: some View {
        if data.isAPIDown{
            Text("API is currently down, please check back later!")
            
        }else{
            NavigationView{
                VStack{
                    Spacer()
                    TotalCircleView(solved: data.stats?.totalSolved ?? 0, total: data.stats?.totalQuestions ?? 1, minWidth: 150, idealWidth: 180, maxWidth: 200, minHeight: 150, idealHeight: 180, maxHeight: 200, title: "Total")
                    .padding()
                    HStack{
                        ZStack{
                            Circle()
                                .stroke(lineWidth: lineWidth)
                                .opacity(0.2)
                                .overlay(
                                    VStack{
                                        Text("\(data.stats?.easySolved ?? 0)")
                                            .font(.system(size: fontSize) .bold())
                                        Text("Easy")
                                            .font(.system(size: fontSize) .bold())
                                    })
                                .foregroundColor(Color.gray)
                             
                            Circle()
                                .trim(from: 0.0, to: CGFloat(Float(data.stats?.easySolved ?? 0)/Float(data.stats?.totalEasy ?? 1)))
                                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                                .foregroundColor(Color.green)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeOut, value: (Float(data.stats?.easySolved ?? 0)/Float(data.stats?.totalEasy ?? 1)))
                        }
                        .padding()
                        
                        //Medium Circle
                        ZStack{
                            Circle()
                                .stroke(lineWidth: lineWidth)
                                .opacity(0.2)
                                .overlay(
                                    VStack{
                                        Text("\(data.stats?.mediumSolved ?? 0)")
                                            .font(.system(size: fontSize) .bold())
                                        Text("Medium")
                                            .font(.system(size: fontSize) .bold())
                                    })
                                .foregroundColor(Color.gray)
                                
                            Circle()
                                .trim(from: 0.0, to: CGFloat(Float(data.stats?.mediumSolved ?? 0)/Float(data.stats?.totalMedium ?? 1)))
                                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                                .foregroundColor(Color.orange)
                                
                                .rotationEffect(.degrees(-90))
                                .animation(.easeOut, value: (Float(data.stats?.mediumSolved ?? 0)/Float(data.stats?.totalMedium ?? 1)))
                        }
                        .padding()
                        //Hard circle
                        ZStack{
                            Circle()
                                .stroke(lineWidth: lineWidth)
                                .opacity(0.2)
                                .overlay(
                                    VStack{
                                        Text("\(data.stats?.hardSolved ?? 0)")
                                            .font(.system(size: fontSize) .bold())
                                        Text("Hard")
                                            .font(.system(size: fontSize) .bold())
                                    })
                                .foregroundColor(Color.gray)
                                
                            Circle()
                                .trim(from: 0.0, to: CGFloat(Float(data.stats?.hardSolved ?? 0)/Float(data.stats?.totalHard ?? 1)))
                                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                                .foregroundColor(Color.red)
                                
                                .rotationEffect(.degrees(-90))
                                .animation(.easeOut, value: (Float(data.stats?.hardSolved ?? 0)/Float(data.stats?.totalHard ?? 1)))
                        }
                        .padding()
                        
                    }
                    Spacer()
                    ProgressView("Acceptance Rate: \(Int(data.stats?.acceptanceRate ?? 0)) %", value: data.stats?.acceptanceRate ?? 0.0, total: 100)
                        .progressViewStyle(ProgressBarView(color: data.accentColor, height: 20, labelFontStyle: .body.weight(.bold)))
                        .padding([.leading,.trailing])

                    
                    
                    
                    if data.calendarLoaded{
                        HStack{
                            Text("\(data.calenderData.count)")
                                .bold()
                                
                            Text("submissions in the past one year")
                                .foregroundStyle(Color.gray)
                                .bold()
                            Spacer()
                        }
                        .padding([.leading, .trailing])
                        
                        AxisContribution(constant: .init(), source: data.calenderData)
                        { indexSet, data in
                            Image(systemName: "square.fill")
                                .foregroundColor(.gray.opacity(0.5))
                              .font(.system(size: 20))
                              .frame(width: 20, height: 20)
                        } foreground: { indexSet, data in
                            Image(systemName: "square.fill")
                                .foregroundColor(.green)
                              .font(.system(size: 20))
                              .frame(width: 20, height: 20)
                        }

                    }else{
                        GroupBox{
                            Text("No recent submissions")
                                .frame(width: 300)
                        }
                        
                        
                        
                    }

                }
                
                .onAppear{
                    Task{
                        if(!data.calenderData.isEmpty){
                           
                            data.calenderData.removeAll()
                            await data.loadStats(name: username)
                        }else{
                            await data.loadStats(name: username)
                        }
                        
                    }
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        self.lineWidth = 10
                        self.fontSize = 20
                    }else{
                        self.lineWidth = 10
                        self.fontSize = 15
                    }

                }
                .onDisappear {
                    AppDelegate.orientationLock = .all // Unlocking the rotation when leaving the view
                }
                
                .navigationBarTitle(username+"'s Stats")
                .navigationBarTitleDisplayMode(.inline)
                
                //Log user out
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing){
                        Button(action: {
                            login = false
                            data.calenderData.removeAll()
                            
                        }, label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        })
                    }
                    
                    //Refresh user stats
                    ToolbarItem(placement: .navigationBarLeading){
                        Button(action: {
                            Task{
                                if(!data.calenderData.isEmpty){
                                    data.calenderData.removeAll()
                                    await data.loadStats(name: username)
                                }else{
                                    await data.loadStats(name: username)
                                }
                                
                            }
                            
                        }, label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        })
                    }
                    
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    
}
struct StatsView_Previews: PreviewProvider {
    @StateObject var data = DataModel()
    static var previews: some View {
        StatsView(lineWidth: 5, fontSize: 15)
            .environmentObject(NotificationManager())
    }
}




