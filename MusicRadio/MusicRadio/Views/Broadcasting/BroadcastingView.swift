import SwiftUI

struct BroadcastingView: View {
    @StateObject private var viewModel = ProgramEditViewModel()
    @State private var showCreateProgram = false
    @State private var showRecording = false

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 32) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)

                    VStack(spacing: 8) {
                        Text("Start Broadcasting")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Create your own radio program and share it with the world")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    Button {
                        showCreateProgram = true
                    } label: {
                        Label("Create New Program", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 32)

                    Button {
                        showRecording = true
                    } label: {
                        Label("Record Audio", systemImage: "record.circle")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 32)

                    NavigationLink(destination: MyProgramsView()) {
                        Label("My Programs", systemImage: "list.bullet")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 32)

                    NavigationLink(destination: BroadcasterAnalyticsView()) {
                        Label("Analytics", systemImage: "chart.bar.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 32)
                }
            }
        }
        .navigationTitle("Broadcasting")
        .sheet(isPresented: $showCreateProgram) {
            NavigationStack {
                ProgramEditView()
            }
        }
        .sheet(isPresented: $showRecording) {
            NavigationStack {
                RecordingView()
            }
        }
    }
}
