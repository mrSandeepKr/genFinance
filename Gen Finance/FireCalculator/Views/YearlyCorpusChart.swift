//
//  YearlyCorpusChart.swift
//  Gen Finance
//
//  Created by Sandeep Kumar on 10/08/25.
//

import Foundation
import SwiftUI
import Charts


// MARK: - Main Chart View
struct YearlyCorpusChart: View {
    let yearlyData: [YearlyCorpusPoint]
    @Binding var showCards: Bool
    let requiredCorpus: Double
    @StateObject private var animationManager = AnimationManager()
    
    var body: some View {
        BarChartContent(
            yearlyData: yearlyData,
            animatedBars: animationManager.animatedBars,
            requiredCorpus: requiredCorpus,
            showCards: showCards
        )
        .frame(height: 250)
        .padding(.all, 8)
        .onChange(of: showCards) { _, newValue in
            if newValue {
                animationManager.animateBars(yearlyData: yearlyData)
            } else {
                animationManager.resetAnimation()
            }
        }
        .opacity(showCards ? 1 : 0)
        .offset(y: showCards ? 0 : 40)
        .scaleEffect(showCards ? 1 : 0.95)
        .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.3), value: showCards)
    }
}

struct BarChartContent: View {
    @Environment(\.appTheme) private var theme
    let yearlyData: [YearlyCorpusPoint]
    let animatedBars: [Int]
    let requiredCorpus: Double
    let showCards: Bool
    
    var body: some View {
        let years = yearlyData.map { $0.year }
        
        Chart {
            ChartUtils.createBarMarks(yearlyData: yearlyData, animatedBars: animatedBars)
            ChartUtils.createRuleMark(requiredCorpus: requiredCorpus)
        }
        .opacity(showCards ? 1 : 0)
        .animation(.easeInOut(duration: 0.8).delay(1.0), value: showCards)
        .chartXAxis {
            ChartUtils.configureXAxis(yearlyData: yearlyData)
        }
        .chartXScale(domain: years.first!...years.last!)
        .chartYAxis {
            ChartUtils.configureYAxis()
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: theme.primary080, radius: 8, x: 0, y: 4)
                .padding(.top, -20)
                .padding(.bottom, -12)
                .padding(.trailing, -12)
                .padding(.leading, -4)
        )
    }
}

class AnimationManager: ObservableObject {
    @Published var animatedBars: [Int] = []
    
    func animateBars(yearlyData: [YearlyCorpusPoint]) {
        animatedBars.removeAll()
        for (index, point) in yearlyData.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 + Double(index) * 0.03) {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.5)) {
                    if !self.animatedBars.contains(point.year) {
                        self.animatedBars.append(point.year)
                    }
                }
            }
        }
    }
    
    func resetAnimation() {
        animatedBars.removeAll()
    }
}

fileprivate struct ChartUtils {
    static func formatLargeNumber(_ value: Double) -> String {
        switch value {
        case 10_000_000...:
            return String(format: "%.1f Cr", value / 10_000_000)
        case 100_000...:
            return String(format: "%.1f L", value / 100_000)
        case 1_000...:
            return String(format: "%.1f K", value / 1_000)
        default:
            return String(format: "%.0f", value)
        }
    }
    
    static func getXAxisValues(from yearlyData: [YearlyCorpusPoint]) -> [Int] {
        let years = yearlyData.map { $0.year }
        var axisValues: [Int] = []
        
        if years.count > 10 {
            axisValues.append(years.first!)
            for i in stride(from: 2, to: years.count - 1, by: 2) {
                axisValues.append(years[i])
            }
            if !axisValues.contains(years.last!) {
                axisValues.append(years.last!)
            }
        } else {
            axisValues = years
        }
        
        return axisValues
    }
    
    static func createBarMarks(yearlyData: [YearlyCorpusPoint], animatedBars: [Int]) -> some ChartContent {
        ForEach(Array(yearlyData.enumerated()), id: \.element.year) { index, point in
            BarMark(
                x: .value("Year", point.year),
                y: .value("Corpus", animatedBars.contains(point.year) ? point.totalCorpus : 0)
            )
            .foregroundStyle(
                LinearGradient(
                    gradient: Gradient(colors: [Color.indigo, Color.green.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(6)
            .annotation(position: .top, alignment: .center, spacing: 0) {
                if point.year == yearlyData.last?.year && animatedBars.contains(point.year) {
                    Text(formatLargeNumber(point.totalCorpus))
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.indigo)
                        )
                }
            }
        }
    }
    
    static func createRuleMark(requiredCorpus: Double) -> some ChartContent {
        RuleMark(
            y: .value("Required FIRE Corpus", requiredCorpus)
        )
        .foregroundStyle(.indigo)
        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
        .annotation(position: .leading) {
            Text("\(formatLargeNumber(requiredCorpus))")
                .font(.caption2.bold())
                .foregroundColor(.indigo)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.indigo.opacity(0.1))
                )
        }
    }
    
    static func configureXAxis(yearlyData: [YearlyCorpusPoint]) -> some AxisContent {
        AxisMarks(values: getXAxisValues(from: yearlyData)) { value in
            AxisValueLabel {
                if let intVal = value.as(Int.self) {
                    Text("\(intVal)")
                        .font(.caption2)
                        .fixedSize()
                        .minimumScaleFactor(0.8)
                }
            }
        }
    }
    
    static func configureYAxis() -> some AxisContent {
        AxisMarks(position: .leading) { value in
            AxisValueLabel {
                if let doubleVal = value.as(Double.self) {
                    Text(formatLargeNumber(doubleVal))
                        .font(.caption2)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FireResultView(
            fireCalculationResult: FireCalculatorFactory.calculate(monthlyExpense: 500000,
                                                                   expectedWithdrawalRateFromCorpus: 4,
                                                                   currentAge: 28,
                                                                   retirementAge: 50,
                                                                   investments: [
                                                                       Investment(name: "Mutual Funds", lumpsumAmount: 20000000, monthlyContribution: 400000, expectedReturn: 12, expectedIncrease: 5),
                                                                       Investment(name: "Fixed Deposits", lumpsumAmount: 5000000, monthlyContribution: 100000, expectedReturn: 8, expectedIncrease: 3)
                                                                   ],
                                                                   inflationPercent: 6)
        )
    }
}
