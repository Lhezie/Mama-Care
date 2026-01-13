//
//  MoodTrendChartView.swift
//  Mama-Care
//
//  Created by Elizabeth Enechaziam on 24/11/2025.
//

import SwiftUI
import Charts

struct MoodTrendChartView: View {
    let moodCheckIns: [MoodCheckIn]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mood Trends")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            if moodCheckIns.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No mood data available yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            } else {
                Chart {
                    ForEach(moodCheckIns.sorted(by: { $0.date < $1.date })) { checkIn in
                        LineMark(
                            x: .value("Date", checkIn.date),
                            y: .value("Mood", checkIn.moodType.chartValue)
                        )
                        .foregroundStyle(Color.mamaCarePrimary)
                        .symbol {
                            Circle()
                                .fill(checkIn.moodType.color)
                                .frame(width: 8, height: 8)
                        }
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Date", checkIn.date),
                            y: .value("Mood", checkIn.moodType.chartValue)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.mamaCarePrimary.opacity(0.3), Color.mamaCarePrimary.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartYScale(domain: 0...4)
                .chartYAxis {
                    AxisMarks(position: .leading, values: [1, 2, 3]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                switch intValue {
                                case 3: Text("Good").font(.caption)
                                case 2: Text("Okay").font(.caption)
                                case 1: Text("Not Good").font(.caption)
                                default: EmptyView()
                                }
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
                .frame(height: 200)
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    MoodTrendChartView(moodCheckIns: [
        MoodCheckIn(date: Date().addingTimeInterval(-86400 * 4), moodType: .good),
        MoodCheckIn(date: Date().addingTimeInterval(-86400 * 3), moodType: .okay),
        MoodCheckIn(date: Date().addingTimeInterval(-86400 * 2), moodType: .notGood),
        MoodCheckIn(date: Date().addingTimeInterval(-86400 * 1), moodType: .good),
        MoodCheckIn(date: Date(), moodType: .good)
    ])
}
