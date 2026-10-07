import Foundation

enum DevicePatchService {
    static func apply(project: PatchProject) throws -> PatchTransactionReceipt {
        let bundleIDs = orderedBundleIdentifiers(in: project)
        log("patch: ===== BẮT ĐẦU APPLY =====")
        log("patch: project name = \(project.name)")
        log("patch: bundle IDs = \(bundleIDs)")
        log("patch: rules = \(project.rules.count), directories = \(project.directories.count)")
        
        // KIỂM TRA EXPLOIT TRƯỚC
        let v = ProcessInfo.processInfo.operatingSystemVersion
        let requiresEscape = KernelExploit.requiresSandboxEscape
        let hasAccess = KernelExploit.hasSandboxAccess()
        log("patch: iOS \(v.majorVersion).\(v.minorVersion).\(v.patchVersion)")
        log("patch: requiresSandboxEscape = \(requiresEscape)")
        log("patch: hasSandboxAccess = \(hasAccess)")
        
        if requiresEscape && !hasAccess {
            log("patch: ❌ EXPLOIT CHƯA CHẠY — app không có quyền truy cập container")
            log("patch: chạy exploit ở tab Home trước rồi thử lại")
            throw PatchPackageError.applyFailed
        }
        
        return try withResolvedContainers(bundleIDs: bundleIDs) { roots in
            log("patch: ✅ resolve được \(roots.count)/\(bundleIDs.count) containers")
            for (id, url) in roots {
                log("patch:   \(id) -> \(url.path)")
            }
            return try PatchTransaction.apply(
                project: project,
                backupRoot: try PatchProjectLibrary.backupRootURL(),
                containerResolver: { bundleID in
                    guard let root = roots[bundleID] else {
                        throw PatchPackageError.targetAppUnavailable(bundleID)
                    }
                    return root
                }
            )
        }
    }

    static func restore(receipt: PatchTransactionReceipt) throws {
        let bundleIDs = try PatchTransaction.requiredBundleIdentifiers(for: receipt)
        try withResolvedContainers(bundleIDs: bundleIDs) { roots in
            try PatchTransaction.restore(
                receipt: receipt,
                containerResolver: { bundleID in
                    guard let root = roots[bundleID] else {
                        throw PatchPackageError.targetAppUnavailable(bundleID)
                    }
                    return root
                }
            )
        }
    }

    static func latestReceipt(projectID: UUID) -> PatchTransactionReceipt? {
        guard let backupRoot = try? PatchProjectLibrary.backupRootURL() else { return nil }
        return PatchTransaction.latestReceipt(projectID: projectID, backupRoot: backupRoot)
    }

    private static func orderedBundleIdentifiers(in project: PatchProject) -> [String] {
        project.allBundleIdentifiers
    }

    private static func withResolvedContainers<T>(
        bundleIDs: [String],
        operation: ([String: URL]) throws -> T
    ) throws -> T {
        var roots: [String: URL] = [:]

        for bundleID in bundleIDs {
            log("patch: resolving container for \(bundleID)…")
            
            guard let path = ContainerStore.resolveAppContainerPath(bundleID: bundleID) else {
                log("patch: ❌ KHÔNG tìm thấy container cho \(bundleID)")
                log("patch: → kiểm tra app \(bundleID) đã cài trên máy chưa")
                throw PatchPackageError.targetAppUnavailable(bundleID)
            }
            log("patch: container path = \(path)")
            
            guard ContainerStore.isApplicationContainerPath(path) else {
                log("patch: ❌ path không phải app container hợp lệ")
                throw PatchPackageError.targetAppUnavailable(bundleID)
            }
            
            roots[bundleID] = PatchPathValidator.canonicalFileURL(
                URL(fileURLWithPath: path, isDirectory: true)
            )
            log("patch: ✅ resolved \(bundleID)")
        }
        return try operation(roots)
    }
}