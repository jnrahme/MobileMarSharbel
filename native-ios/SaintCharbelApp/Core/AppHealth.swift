import Foundation
import Observation

enum AppHealthState: String, CaseIterable {
    case checking
    case healthy
    case degraded
    case unavailable
}

struct AppHealthService: Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
    let url: URL
}

struct AppHealthCheckResult: Identifiable, Hashable {
    let service: AppHealthService
    let state: AppHealthState
    let summary: String
    let checkedAt: Date

    var id: String {
        service.id
    }
}

enum AppHealthCatalog {
    static let services: [AppHealthService] = [
        AppHealthService(
            id: "website",
            title: "Website",
            detail: "Main marsharbel.com experience",
            url: URL(string: "https://marsharbel.com")!
        ),
        AppHealthService(
            id: "storybook-art",
            title: "Storybook artwork",
            detail: "Illustrated Saint Charbel pages",
            url: StoryCatalog.saintCharbel.pages.first!.imageURL
        ),
        AppHealthService(
            id: "storybook-audio",
            title: "Story narration",
            detail: "Page-by-page spoken audio",
            url: StoryCatalog.saintCharbel.pages.first!.audioTrack!.url
        ),
        AppHealthService(
            id: "rosary-audio",
            title: "Rosary audio",
            detail: "Guided mystery meditation tracks",
            url: SaintCharbelLibrary.mysteries(for: .joyful).first!.stageTracks.first!.url
        )
    ]

    static func checkAll() async -> [AppHealthCheckResult] {
        await withTaskGroup(of: AppHealthCheckResult.self) { group in
            for service in services {
                group.addTask {
                    await check(service)
                }
            }

            var results: [AppHealthCheckResult] = []
            for await result in group {
                results.append(result)
            }

            let order = Dictionary(uniqueKeysWithValues: services.enumerated().map { ($0.element.id, $0.offset) })
            return results.sorted { order[$0.id, default: .max] < order[$1.id, default: .max] }
        }
    }

    private static func check(_ service: AppHealthService) async -> AppHealthCheckResult {
        let checkedAt = Date()
        let started = Date()

        do {
            let response = try await performRequest(url: service.url)
            let latency = Date().timeIntervalSince(started)
            let roundedLatency = String(format: "%.1fs", latency)

            switch response.statusCode {
            case 200 ..< 300 where latency < 2.5:
                return AppHealthCheckResult(service: service, state: .healthy, summary: "Reachable in \(roundedLatency)", checkedAt: checkedAt)
            case 200 ..< 400:
                return AppHealthCheckResult(service: service, state: .degraded, summary: "Slow but available (\(roundedLatency))", checkedAt: checkedAt)
            default:
                return AppHealthCheckResult(service: service, state: .unavailable, summary: "HTTP \(response.statusCode)", checkedAt: checkedAt)
            }
        } catch {
            return AppHealthCheckResult(service: service, state: .unavailable, summary: "Unavailable right now", checkedAt: checkedAt)
        }
    }

    private static func performRequest(url: URL) async throws -> HTTPURLResponse {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 12
        request.cachePolicy = .reloadIgnoringLocalCacheData

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            if httpResponse.statusCode == 405 {
                return try await performFallbackGET(url: url)
            }

            return httpResponse
        } catch {
            return try await performFallbackGET(url: url)
        }
    }

    private static func performFallbackGET(url: URL) async throws -> HTTPURLResponse {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 12
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("bytes=0-0", forHTTPHeaderField: "Range")

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        return httpResponse
    }
}

@MainActor
@Observable
final class AppHealthModel {
    private(set) var results: [AppHealthCheckResult]
    private(set) var isRefreshing = false
    private(set) var lastChecked: Date?

    init() {
        self.results = AppHealthCatalog.services.map {
            AppHealthCheckResult(service: $0, state: .checking, summary: "Waiting for first check", checkedAt: .now)
        }
    }

    var overallState: AppHealthState {
        if results.contains(where: { $0.state == .unavailable }) {
            return .unavailable
        }

        if results.contains(where: { $0.state == .degraded || $0.state == .checking }) {
            return .degraded
        }

        return .healthy
    }

    func refreshIfNeeded() async {
        guard lastChecked == nil, !isRefreshing else { return }
        await refresh()
    }

    func refresh() async {
        guard !isRefreshing else { return }

        isRefreshing = true
        results = results.map {
            AppHealthCheckResult(service: $0.service, state: .checking, summary: "Checking now", checkedAt: .now)
        }

        let freshResults = await AppHealthCatalog.checkAll()
        results = freshResults
        lastChecked = .now
        isRefreshing = false
    }
}
