import SwiftUI

/// 简谱编辑器视图
struct SheetMusicEditorView: View {
    @StateObject private var gameState = GameStateManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var songName = ""
    @State private var bpm = 120
    @State private var sheetMusicText = ""
    @State private var showValidationError = false
    @State private var validationMessage = ""
    @State private var showPreview = false
    @State private var previewSong: Song?
    
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
            .navigationTitle("简谱编辑器")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .alert("格式错误", isPresented: $showValidationError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(validationMessage)
            }
            .sheet(isPresented: $showPreview) {
                if let song = previewSong {
                    SheetMusicPreviewView(song: song)
                }
            }
        }
    }
    
    // MARK: - 说明卡片
    private var instructionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.cyan)
                Text("简谱输入说明")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                instructionRow("1-7", "表示 Do Re Mi Fa Sol La Si")
                instructionRow("1. 2.", "数字后加点表示高音")
                instructionRow(",1 ,2", "数字前加逗号表示低音")
                instructionRow("1_ 1__", "下划线表示延长（一个_延长1拍）")
                instructionRow("0", "表示休止符")
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
                Text("歌曲名称")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                
                TextField("请输入歌曲名称", text: $songName)
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
                    Text("节拍速度 (BPM)")
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
                Text("简谱内容")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text("\(sheetMusicText.count) 字符")
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
                Text("加载示例（小星星）")
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
                    Text("预览")
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
                    Text("保存")
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
            Text("我的歌曲")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            if gameState.customSongs.isEmpty {
                Text("还没有保存的歌曲")
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
        songName = "小星星（示例）"
        bpm = 120
        sheetMusicText = SheetMusicParser.generateExample()
    }
    
    private func validateAndPreview() {
        // 验证格式
        let validation = SheetMusicParser.validate(sheetMusic: sheetMusicText)
        
        if !validation.isValid {
            validationMessage = validation.error ?? "未知错误"
            showValidationError = true
            return
        }
        
        // 解析简谱
        guard let song = SheetMusicParser.parse(
            sheetMusic: sheetMusicText,
            name: songName.isEmpty ? "未命名" : songName,
            bpm: bpm
        ) else {
            validationMessage = "简谱解析失败，请检查格式"
            showValidationError = true
            return
        }
        
        previewSong = song
        showPreview = true
    }
    
    private func saveCustomSong() {
        guard !songName.isEmpty else {
            validationMessage = "请输入歌曲名称"
            showValidationError = true
            return
        }
        
        // 验证格式
        let validation = SheetMusicParser.validate(sheetMusic: sheetMusicText)
        if !validation.isValid {
            validationMessage = validation.error ?? "未知错误"
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
    let song: Song
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        Text("共 \(song.notes.count) 个音符")
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
            }
            .navigationTitle(song.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
    }
}