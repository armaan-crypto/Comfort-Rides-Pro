//
//  BookedRides.swift
//  Comfort Rides Pro
//

import SwiftUI

struct BookedRides: View {

    @StateObject private var ridesManager = RidesManager()
    @State private var error: Error?

    var body: some View {
        ZStack {
            K.backgroundGradient
                .ignoresSafeArea()

            Group {
                if ridesManager.loaded {
                    if ridesManager.bookedRides.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "car.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.15))
                            Text("No upcoming rides")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(K.textDim)
                        }
                    } else {
                        List {
                            ForEach(ridesManager.bookedRides) { ride in
                                BookedRidesRow(ride: ride) {
                                    Task { await ridesManager.cancelRide(ride) }
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        Task { await ridesManager.cancelRide(ride) }
                                    } label: {
                                        Label("Cancel", systemImage: "xmark")
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                } else {
                    ProgressView()
                        .tint(K.gold)
                }
            }
        }
        .navigationTitle("Upcoming Rides")
        .overlay(alignment: .top) {
            if let e = error {
                ErrorView(error: $error, errorMessage: .constant(e.localizedDescription))
            }
        }
        .task {
            do {
                try await ridesManager.retrieve()
            } catch {
                self.error = error
                ridesManager.loaded = true
            }
        }
    }
}

struct BookedRidesRow: View {
    let ride: Ride
    var onCancel: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ride.carType?.rawValue ?? "")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    Text(ride.formattedDate)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(K.gold)
                }
                Spacer()
                if let carType = ride.carType {
                    Image(carType.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 46)
                        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                Menu {
                    Button(role: .destructive) {
                        onCancel?()
                    } label: {
                        Label("Cancel Ride", systemImage: "xmark.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(K.gold)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            Rectangle()
                .fill(K.hairline)
                .frame(height: 1)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .strokeBorder(K.gold, lineWidth: 1.5)
                        .frame(width: 9, height: 9)
                        .padding(.top, 4)
                    Text(ride.pickUpLocation ?? "")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.75))
                }
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(K.gold)
                        .frame(width: 9, height: 9)
                        .padding(.top, 4)
                    Text(ride.dropOffLocation ?? "")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.75))
                }
            }
        }
        .padding(16)
        .luxCard()
    }
}

@MainActor
class RidesManager: ObservableObject {
    @Published var bookedRides: [Ride] = []
    @Published var loaded = false

    func retrieve() async throws {
        let rows = try await BookingService().fetchUpcomingReservations()
        bookedRides = rows.map { row in
            Ride(
                id: row.id,
                reservationId: row.id,
                time: row.pickupAt,
                pickUpLocation: row.pickupLocation,
                dropOffLocation: row.dropoffLocation,
                carType: CarType(supabaseId: row.carTypeId),
                layover: row.standbyHours,
                note: row.note
            )
        }
        loaded = true
    }

    func cancelRide(_ ride: Ride) async {
        guard let reservationId = ride.reservationId else { return }
        do {
            try await BookingService().cancelReservation(id: reservationId)
            bookedRides.removeAll { $0.id == ride.id }
        } catch {
            print("Cancel failed: \(error)")
        }
    }
}

struct ErrorView: View {
    @Binding var error: Error?
    @Binding var errorMessage: String?

    var body: some View {
        if let msg = errorMessage {
            VStack(spacing: 14) {
                Text(msg)
                    .font(.system(size: 14, weight: .semibold))
                    .multilineTextAlignment(.center)
                Button("Dismiss") {
                    error = nil
                    errorMessage = nil
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(K.gold)
            }
            .padding(18)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(red: 0.45, green: 0.12, blue: 0.14))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }
}

struct BookedRides_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { BookedRides() }
    }
}
