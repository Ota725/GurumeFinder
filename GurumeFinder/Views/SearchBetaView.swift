//
//  SwiftUIView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/06.
//

import SwiftUI
import CoreLocation

struct SearchBetaView: View {
    @State private var viewModel = SearchBetaViewModel()
    @State private var navigateToResults = false

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    locationSection
                    searchRadiusSection
                    genreSection
                    budgetSection
                    searchButton
                }

                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .navigationDestination(isPresented: $navigateToResults) {
                ResultsView(restaurants: viewModel.searchResults)
            }
            .alert(isPresented: .constant(viewModel.errorMessage.isEmpty == false), content: {
                Alert(
                    title: Text("エラー"),
                    message: Text(viewModel.errorMessage),
                    dismissButton: .default(Text("OK")) {
                        viewModel.errorMessage = ""
                    }
                )
            })
        }
        .onAppear {
            viewModel.requestLocationPermission()
        }
    }

    // 現在地
    private var locationSection: some View {
        Section(header: Text("現在地")) {
            if viewModel.locationManager.location != nil {
                Text("現在地")
            } else {
                Button("位置情報を取得") {
                    viewModel.requestLocationPermission()
                    viewModel.locationManager.startUpdatingLocation()
                }
            }
        }
    }

    // 半径
    private var searchRadiusSection: some View {
        Section(header: Text("検索半径")) {
            Picker("半径", selection: $viewModel.radius) {
                ForEach(viewModel.radiusOptions.keys.sorted(), id: \.self) { key in
                    Text(viewModel.radiusOptions[key]!).tag(key)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }

    // ジャンル
    private var genreSection: some View {
        Section(header: Text("ジャンル")) {
            Picker("ジャンル", selection: $viewModel.selectedGenre) {
                ForEach(viewModel.genreOptions, id: \.self) { genre in
                    Text(genre).tag(genre)
                }
            }
            .pickerStyle(DefaultPickerStyle())
        }
    }

    // 予算
    private var budgetSection: some View {
        Section(header: Text("予算")) {
            Picker("予算", selection: $viewModel.selectedBudget) {
                ForEach(viewModel.budgetOptions, id: \.self) { budget in
                    Text(budget).tag(budget)
                }
            }
            .pickerStyle(DefaultPickerStyle())
        }
    }

    // 検索ボタン
    private var searchButton: some View {
        Button {
            Task {
                await viewModel.searchRestaurants()
                navigateToResults = true
            }
        } label: {
            Text("検索")
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
        }
        .disabled(viewModel.locationManager.location == nil || viewModel.isLoading)
    }
}

#Preview {
    SearchBetaView()
}
