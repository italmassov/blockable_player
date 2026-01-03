import Cocoa
import CLibVLC

final class LibVlcEngine: VideoEngine {
    private let instance: OpaquePointer
    private let mediaPlayer: OpaquePointer
    private let videoView = NSView()

    init?() {
        let bundlePluginPath = Bundle.main.resourceURL?
            .appendingPathComponent("vlc")
            .appendingPathComponent("plugins")
            .path
        let fallbackPluginPath = "/Applications/VLC.app/Contents/MacOS/plugins"
        let pluginPath: String?
        if let bundlePluginPath, FileManager.default.fileExists(atPath: bundlePluginPath) {
            pluginPath = bundlePluginPath
        } else if FileManager.default.fileExists(atPath: fallbackPluginPath) {
            pluginPath = fallbackPluginPath
        } else {
            pluginPath = nil
        }
        if let pluginPath {
            setenv("VLC_PLUGIN_PATH", pluginPath, 1)
        }
        let rawArgs = [
            "--no-video-title-show"
        ]
        let cArgs = rawArgs.map { strdup($0) }
        defer {
            for pointer in cArgs {
                free(pointer)
            }
        }
        var args = cArgs.map { UnsafePointer<CChar>($0) }
        guard let instance = libvlc_new(Int32(args.count), &args) else {
            return nil
        }
        guard let mediaPlayer = libvlc_media_player_new(instance) else {
            libvlc_release(instance)
            return nil
        }
        self.instance = instance
        self.mediaPlayer = mediaPlayer
        libvlc_media_player_set_nsobject(mediaPlayer, Unmanaged.passUnretained(videoView).toOpaque())
    }

    deinit {
        libvlc_media_player_stop(mediaPlayer)
        libvlc_media_player_release(mediaPlayer)
        libvlc_release(instance)
    }

    var view: NSView {
        videoView
    }

    func open(url: URL) {
        let media: OpaquePointer?
        if url.isFileURL {
            media = libvlc_media_new_path(instance, url.path)
        } else {
            media = libvlc_media_new_location(instance, url.absoluteString)
        }
        guard let media else { return }
        libvlc_media_player_set_media(mediaPlayer, media)
        libvlc_media_release(media)
        libvlc_media_player_play(mediaPlayer)
    }

    func play() {
        libvlc_media_player_play(mediaPlayer)
    }

    func togglePlayPause() {
        if libvlc_media_player_is_playing(mediaPlayer) == 1 {
            libvlc_media_player_pause(mediaPlayer)
        } else {
            libvlc_media_player_play(mediaPlayer)
        }
    }

    func isPlaying() -> Bool {
        libvlc_media_player_is_playing(mediaPlayer) == 1
    }

    func setVolume(_ value: Float) {
        libvlc_audio_set_volume(mediaPlayer, Int32(value * 100))
    }

    func currentPosition() -> Float? {
        let position = libvlc_media_player_get_position(mediaPlayer)
        if position.isNaN || position < 0 {
            return nil
        }
        return position
    }

    func seek(to position: Float) {
        let clamped = max(0, min(position, 1))
        libvlc_media_player_set_position(mediaPlayer, clamped)
    }

    func seek(by seconds: Double) {
        let current = libvlc_media_player_get_time(mediaPlayer)
        let length = libvlc_media_player_get_length(mediaPlayer)
        guard current >= 0, length > 0 else { return }
        let delta = Int64(seconds * 1000)
        let target = max(0, min(current + delta, length))
        libvlc_media_player_set_time(mediaPlayer, target)
    }

    func currentTimeSeconds() -> Double? {
        let current = libvlc_media_player_get_time(mediaPlayer)
        guard current >= 0 else { return nil }
        return Double(current) / 1000.0
    }

    func durationSeconds() -> Double? {
        let length = libvlc_media_player_get_length(mediaPlayer)
        guard length > 0 else { return nil }
        return Double(length) / 1000.0
    }
}
