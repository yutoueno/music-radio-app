import Foundation

protocol UploadRepositoryProtocol {
    func uploadProgramAudio(programId: String, audioData: Data, fileName: String, onProgress: ((Double) -> Void)?) async throws -> UploadResponse
    func uploadAvatar(imageData: Data) async throws -> UploadResponse
}

final class UploadRepository: UploadRepositoryProtocol {
    private let apiClient = APIClient.shared

    func uploadProgramAudio(
        programId: String,
        audioData: Data,
        fileName: String,
        onProgress: ((Double) -> Void)? = nil
    ) async throws -> UploadResponse {
        let response = try await apiClient.upload(
            endpoint: .uploadProgramAudio(programId: programId),
            fileData: audioData,
            fileName: fileName,
            mimeType: mimeType(for: fileName),
            fieldName: "audio",
            responseType: APIResponse<UploadResponse>.self,
            onProgress: onProgress
        )
        return response.data
    }

    func uploadAvatar(imageData: Data) async throws -> UploadResponse {
        let response = try await apiClient.upload(
            endpoint: .uploadAvatar(),
            fileData: imageData,
            fileName: "avatar.jpg",
            mimeType: "image/jpeg",
            fieldName: "avatar",
            responseType: APIResponse<UploadResponse>.self
        )
        return response.data
    }

    private func mimeType(for fileName: String) -> String {
        let ext = (fileName as NSString).pathExtension.lowercased()
        switch ext {
        case "mp3":
            return "audio/mpeg"
        case "m4a", "aac":
            return "audio/mp4"
        case "wav":
            return "audio/wav"
        case "flac":
            return "audio/flac"
        case "ogg":
            return "audio/ogg"
        default:
            return "application/octet-stream"
        }
    }
}
