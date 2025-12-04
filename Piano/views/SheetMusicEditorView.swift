import SwiftUI

/// 简谱编辑器视图
struct SheetMusicEditorView: View {
    @StateObject private var gameState = GameStateManager.shared
    @ObservedObject private var localization = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var songName = "" {
        didSet { saveDraftToFile() }
    }
    @State private var bpm = 120 {
        didSet { saveDraftToFile() }
    }
    @State private var sheetMusicText = "" {
        didSet { saveDraftToFile() }
    }
    @State private var showValidationError = false
    @State private var validationMessage = ""
    @State private var showPreview = false
    @State private var previewSong: Song?
    
    // 临时文件路径
    private var draftFilePath: URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("sheet_music_draft.json")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                LinearGradient(
                    colors: [.black, .purple.opacity(0.2), .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 说明卡片
                        instructionCard
                        
                        // 歌曲信息
                        songInfoSection
                        
                        // 简谱编辑器
                        editorSection
                        
                        // 示例按钮
                        exampleButton
                        
                        // 操作按钮
                        actionButtons
                        
                        // 已保存的自定义歌曲列表
                        savedSongsSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle(localization.localized("game.menu.editor"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localization.localized("editor.close")) {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .alert(localization.localized("editor.validation.error.title"), isPresented: $showValidationError) {
                Button(localization.localized("confirm"), role: .cancel) {}
            } message: {
                Text(validationMessage)
            }
            .sheet(isPresented: $showPreview) {
                SheetMusicPreviewView(draftFilePath: draftFilePath)
            }
        }
    }
    
    // MARK: - 说明卡片
    private var instructionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.cyan)
                Text(localization.localized("editor.info.title"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                instructionRow("1-7", localization.localized("editor.instruction.1"))
                instructionRow("1. 2.", localization.localized("editor.instruction.2"))
                instructionRow(",1 ,2", localization.localized("editor.instruction.3"))
                instructionRow("1_ 1__", localization.localized("editor.instruction.4"))
                instructionRow("0", localization.localized("editor.instruction.5"))
            }
            .font(.system(size: 14, design: .rounded))
            .foregroundStyle(.white.opacity(0.8))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.cyan.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    @ViewBuilder
    private func instructionRow(_ pattern: String, _ description: String) -> some View {
        HStack(spacing: 8) {
            Text("•")
                .foregroundStyle(.cyan)
            Text(pattern)
                .fontWeight(.bold)
                .foregroundStyle(.cyan)
            Text("-")
                .foregroundStyle(.white.opacity(0.5))
            Text(description)
        }
    }
    
    // MARK: - 歌曲信息区
    private var songInfoSection: some View {
        VStack(spacing: 16) {
            // 歌曲名称
            VStack(alignment: .leading, spacing: 8) {
                Text(localization.localized("editor.song.name.label"))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                
                TextField(localization.localized("editor.song.name.placeholder"), text: $songName)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.1))
                    )
                    .foregroundStyle(.white)
            }
            
            // BPM设置
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(localization.localized("editor.bpm.label"))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    Text("\(bpm)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.cyan)
                }
                
                Slider(value: Binding(
                    get: { Double(bpm) },
                    set: { bpm = Int($0) }
                ), in: 60...200, step: 10)
                .tint(.cyan)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - 编辑器区
    private var editorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(localization.localized("editor.content.label"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text(String(format: localization.localized("editor.character.count"), sheetMusicText.count))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
            
            TextEditor(text: $sheetMusicText)
                .frame(minHeight: 200)
                .scrollContentBackground(.hidden)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.black.opacity(0.3))
                )
                .foregroundStyle(.white)
                .font(.system(size: 16, design: .monospaced))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - 示例按钮
    private var exampleButton: some View {
        Button(action: loadExample) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text(localization.localized("editor.load.example.button"))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.yellow)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.yellow.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.yellow, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 操作按钮
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: validateAndPreview) {
                HStack {
                    Image(systemName: "eye.fill")
                    Text(localization.localized("editor.preview.button"))
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.blue.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.blue, lineWidth: 2)
                        )
                )
            }
            .buttonStyle(.plain)
            
            Button(action: saveCustomSong) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text(localization.localized("editor.save.button"))
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.green.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.green, lineWidth: 2)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - 已保存歌曲列表
    private var savedSongsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localization.localized("editor.my.songs.title"))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            if gameState.customSongs.isEmpty {
                Text(localization.localized("editor.no.saved.songs"))
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                ForEach(gameState.customSongs) { song in
                    customSongRow(song)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    @ViewBuilder
    private func customSongRow(_ customSong: CustomSong) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(customSong.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("BPM: \(customSong.bpm)")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.cyan)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: { loadCustomSong(customSong) }) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.blue)
                }
                
                Button(action: { deleteCustomSong(customSong) }) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(0.05))
        )
    }
    
    // MARK: - 操作方法
    
    private func loadExample() {
        songName = "song.twinkle_star_example".localized
        bpm = 120
        sheetMusicText = SheetMusicParser.generateExample()
    }
    
    private func validateAndPreview() {
        // 确保最新数据已保存到文件
        saveDraftToFile()
        
        // 验证格式
        let validation = SheetMusicParser.validate(sheetMusic: sheetMusicText)
        
        if !validation.isValid {
            validationMessage = validation.error ?? "未知错误"
            showValidationError = true
            return
        }
        
        // 简单验证能否解析（不实际使用）
        guard SheetMusicParser.parse(
            sheetMusic: sheetMusicText,
            name: songName.isEmpty ? localization.localized("editor.song.name.placeholder") : songName,
            bpm: bpm
        ) != nil else {
            validationMessage = localization.localized("editor.validation.error.parse")
            showValidationError = true
            return
        }
        
        // 直接显示预览，让预览视图自己从文件加载
        showPreview = true
    }
    
    /// 保存草稿到临时文件
    private func saveDraftToFile() {
        let draft: [String: Any] = [
            "songName": songName,
            "bpm": bpm,
            "sheetMusicText": sheetMusicText
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: draft, options: .prettyPrinted) else {
            return
        }
        
        try? data.write(to: draftFilePath, options: .atomic)
    }
    
    /// 从临时文件加载草稿
    private func loadDraftFromFile() {
        guard let data = try? Data(contentsOf: draftFilePath),
              let draft = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
        }
        
        if let name = draft["songName"] as? String {
            songName = name
        }
        if let tempo = draft["bpm"] as? Int {
            bpm = tempo
        }
        if let text = draft["sheetMusicText"] as? String {
            sheetMusicText = text
        }
    }
    
    private func saveCustomSong() {
        guard !songName.isEmpty else {
            validationMessage = localization.localized("editor.validation.error.name")
            showValidationError = true
            return
        }
        
        // 验证格式
        let validation = SheetMusicParser.validate(sheetMusic: sheetMusicText)
        if !validation.isValid {
            validationMessage = validation.error ?? localization.localized("error")
            showValidationError = true
            return
        }
        
        // 创建自定义歌曲
        let customSong = CustomSong(
            name: songName,
            sheetMusic: sheetMusicText,
            bpm: bpm
        )
        
        gameState.addCustomSong(customSong)
        
        // 清空表单
        songName = ""
        sheetMusicText = ""
        bpm = 120
        
        // 触觉反馈
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
    }
    
    private func loadCustomSong(_ song: CustomSong) {
        songName = song.name
        bpm = song.bpm
        sheetMusicText = song.sheetMusic
    }
    
    private func deleteCustomSong(_ song: CustomSong) {
        gameState.deleteCustomSong(song)
    }
}

/// 简谱预览视图
struct SheetMusicPreviewView: View {
    let draftFilePath: URL
    @ObservedObject private var localization = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var song: Song?
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let song = song {
                    ScrollView {
                        VStack(spacing: 16) {
                            Text(String(format: localization.localized("editor.note.count"), song.notes.count))
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 8), spacing: 8) {
                                ForEach(Array(song.notes.enumerated()), id: \.offset) { index, noteIndex in
                                    VStack(spacing: 4) {
                                        Text("♪")
                                            .font(.system(size: 20))
                                            .foregroundStyle(Note.allNotes[noteIndex].color)
                                        
                                        Text(Note.allNotes[noteIndex].name)
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundStyle(.white)
                                    }
                                    .frame(width: 40, height: 60)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.white.opacity(0.1))
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.red)
                        Text(errorMessage)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    ProgressView()
                        .tint(.white)
                }
            }
            .navigationTitle(song?.name ?? localization.localized("editor.preview.loading"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.localized("editor.preview.done")) {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .onAppear {
                loadSongFromDraft()
            }
        }
    }
    
    /// 从临时文件加载并解析歌曲
    private func loadSongFromDraft() {
        guard let data = try? Data(contentsOf: draftFilePath),
              let draft = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let songName = draft["songName"] as? String,
              let bpm = draft["bpm"] as? Int,
              let sheetMusicText = draft["sheetMusicText"] as? String else {
            errorMessage = localization.localized("editor.preview.error.load")
            return
        }
        
        // 解析简谱
        guard let parsedSong = SheetMusicParser.parse(
            sheetMusic: sheetMusicText,
            name: songName.isEmpty ? localization.localized("editor.song.name.placeholder") : songName,
            bpm: bpm
        ) else {
            errorMessage = localization.localized("editor.preview.error.parse")
            return
        }
        
        self.song = parsedSong
    }
}