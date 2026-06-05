// OpenAIService.swift
// DriveMusic AI
//
// Client for the OpenAI Whisper audio transcription API.
// Uploads a local .m4a file as multipart/form-data and returns the transcript.

import Foundation

// MARK: - Errors

/// Errors that can be thrown by OpenAIService.
enum OpenAIServiceError: LocalizedError {
    case missingAPIKey
    case fileNotFound(url: URL)
    case networkError(underlying: Error)
    case httpError(statusCode: Int, body: String)
    case decodingError
    case emptyTranscript

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API key is missing. Add it to Config.plist."
        case .fileNotFound(let url):
            return "Audio file not found at: \(url.lastPathComponent)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .httpError(let code, let body):
            switch code {
            case 401: return "OpenAI API key is invalid (401 Unauthorized)."
            case 429: return "OpenAI rate limit reached. Please wait a moment (429)."
            case 500...599: return "OpenAI server error (\(code)). Please try again."
            default: return "Unexpected HTTP \(code): \(body.prefix(200))"
            }
        case .decodingError:
            return "Could not parse the transcription response."
        case .emptyTranscript:
            return "No speech was detected in the recording."
        }
    }
}

// MARK: - Response Model

private struct WhisperResponse: Decodable {
    let text: String
}

// MARK: - Service

/// Sends audio files to OpenAI's Whisper endpoint and returns the transcript.
///
/// Inject this via the ViewModel constructor so it can be mocked in tests.
struct OpenAIService {

    // MARK: - Configuration

    private let apiKey: String
    private let endpoint = URL(string: "https://api.openai.com/v1/audio/transcriptions")!
    private let model = "whisper-1"
    private let session: URLSession

    // MARK: - Init

    /// - Parameter apiKey: Your OpenAI API key. Must not be empty.
    /// - Parameter session: Defaults to `URLSession.shared`; inject a custom session for testing.
    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    // MARK: - Public API

    /// Uploads `audioURL` to Whisper and returns the transcribed text.
    ///
    /// - Parameter audioURL: Local URL of the `.m4a` file to transcribe.
    /// - Returns: The transcript string.
    /// - Throws: `OpenAIServiceError` describing what went wrong.
    func transcribe(audioURL: URL) async throws -> String {
        guard !apiKey.isEmpty else { throw OpenAIServiceError.missingAPIKey }
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            throw OpenAIServiceError.fileNotFound(url: audioURL)
        }

        let request = try buildRequest(for: audioURL)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw OpenAIServiceError.networkError(underlying: error)
        }

        // Validate HTTP status.
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw OpenAIServiceError.httpError(statusCode: http.statusCode, body: body)
        }

        // Decode JSON response.
        guard let whisper = try? JSONDecoder().decode(WhisperResponse.self, from: data) else {
            throw OpenAIServiceError.decodingError
        }

        let transcript = whisper.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !transcript.isEmpty else { throw OpenAIServiceError.emptyTranscript }

        return transcript
    }

    // MARK: - Private

    private func buildRequest(for audioURL: URL) throws -> URLRequest {
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = try buildMultipartBody(audioURL: audioURL, boundary: boundary)
        return request
    }

    private func buildMultipartBody(audioURL: URL, boundary: String) throws -> Data {
        var body = Data()
        let crlf = "\r\n"

        // --- model field ---
        body.append("--\(boundary)\(crlf)")
        body.append("Content-Disposition: form-data; name=\"model\"\(crlf)\(crlf)")
        body.append("\(model)\(crlf)")

        // --- response_format field ---
        body.append("--\(boundary)\(crlf)")
        body.append("Content-Disposition: form-data; name=\"response_format\"\(crlf)\(crlf)")
        body.append("json\(crlf)")

        // --- file field ---
        let fileData = try Data(contentsOf: audioURL)
        let filename = audioURL.lastPathComponent
        body.append("--\(boundary)\(crlf)")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\(crlf)")
        body.append("Content-Type: audio/m4a\(crlf)\(crlf)")
        body.append(fileData)
        body.append(crlf)

        // --- closing boundary ---
        body.append("--\(boundary)--\(crlf)")

        return body
    }
}

// MARK: - Data Helper

private extension Data {
    /// Appends a UTF-8 encoded string to the data buffer.
    mutating func append(_ string: String) {
        if let encoded = string.data(using: .utf8) {
            append(encoded)
        }
    }
}
