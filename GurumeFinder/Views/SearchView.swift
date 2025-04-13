//
//  SearchView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/10.
//

import SwiftUI

struct SearchView: View {
    @State private var inputText = ""
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(.systemGray2))
            TextField("お店を探す", text: $inputText)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
        .padding(.horizontal)
        Spacer()
    }
}

#Preview {
    SearchView()
}
