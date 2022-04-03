//
//  ContentView.swift
//  GitReads
//
//  Created by Zhou Jiahao on 10/3/22.
//

import SwiftUI
import CoreData
import Cache

struct ContentView: View {
    @State var repo: Repo?
    @StateObject var appDependencies = AppDependencies()

    var body: some View {
        ZStack {
            HomeView(repoService: appDependencies.repoService)
                .environmentObject(appDependencies)
        }

    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
