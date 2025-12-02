import Foundation

/// 简谱解析器 - 将文本简谱转换为可播放的Song对象
struct SheetMusicParser {
    
    /// 解析简谱文本
    /// 支持格式：
    /// - 数字1-7表示Do到Si
    /// - 数字后加点(.)表示高音，如1. 2.
    /// - 数字前加逗号(,)表示低音，如,1 ,2
    /// - 0表示休止符
    /// - 数字后加下划线(_)表示延长，如1_ 表示1拍，1__ 表示2拍
    /// - 用空格或换行分隔音符
    static func parse(sheetMusic: String, name: String, bpm: Int) -> Song? {
        var notes: [Int] = []
        var durations: [Double] = []
        
        // 基础时长（四分音符）= 60/BPM
        let baseDuration = 60.0 / Double(bpm)
        
        // 预处理：移除多余的空白字符，保留单个空格和换行
        let cleaned = sheetMusic
            .replacingOccurrences(of: "\t", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 按空格和换行分割
        let tokens = cleaned.components(separatedBy: CharacterSet(charactersIn: " \n"))
            .filter { !$0.isEmpty }
        
        for token in tokens {
            guard let (noteIndex, duration) = parseToken(token, baseDuration: baseDuration) else {
                print("⚠️ 无法解析音符: \(token)")
                continue
            }
            
            notes.append(noteIndex)
            durations.append(duration)
        }
        
        // 验证解析结果
        guard !notes.isEmpty, notes.count == durations.count else {
            print("❌ 简谱解析失败：音符数量不匹配")
            return nil
        }
        
        return Song(name: name, notes: notes, durations: durations, bpm: bpm)
    }
    
    /// 解析单个音符标记
    private static func parseToken(_ token: String, baseDuration: Double) -> (noteIndex: Int, duration: Double)? {
        var chars = Array(token)
        guard !chars.isEmpty else { return nil }
        
        var isHighOctave = false
        var isLowOctave = false
        var noteValue: Int?
        var durationMultiplier = 1.0
        
        // 处理八度标记
        if chars.first == "," {
            isLowOctave = true
            chars.removeFirst()
        }
        
        // 获取音符数字
        if let first = chars.first, first.isNumber {
            noteValue = Int(String(first))
            chars.removeFirst()
        } else {
            return nil
        }
        
        // 处理高音点
        if chars.first == "." {
            isHighOctave = true
            chars.removeFirst()
        }
        
        // 处理延长符号
        var underscoreCount = 0
        while chars.first == "_" {
            underscoreCount += 1
            chars.removeFirst()
        }
        
        // 处理附点（可选扩展）
        if chars.first == "-" {
            durationMultiplier = 1.5
            chars.removeFirst()
        }
        
        // 计算持续时间
        if underscoreCount > 0 {
            durationMultiplier = Double(underscoreCount + 1)
        }
        
        guard let note = noteValue else { return nil }
        
        // 映射到音符索引
        // 0-7: 中音区（第一排琴键）
        // 8-15: 低音区（第二排琴键）
        let noteIndex: Int
        
        if note == 0 {
            // 休止符：使用一个不发声的索引（这里用-1标记，实际播放时跳过）
            return nil // 暂时跳过休止符
        } else if isHighOctave {
            // 高音：1. 2. 3. ... -> 索引 0-7
            noteIndex = (note - 1) % 8
        } else if isLowOctave {
            // 低音：,1 ,2 ,3 ... -> 索引 8-15
            noteIndex = ((note - 1) % 8) + 8
        } else {
            // 中音（默认）：1 2 3 ... -> 索引 0-7
            noteIndex = (note - 1) % 8
        }
        
        let duration = baseDuration * durationMultiplier
        return (noteIndex, duration)
    }
    
    /// 验证简谱格式
    static func validate(sheetMusic: String) -> (isValid: Bool, error: String?) {
        let cleaned = sheetMusic.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleaned.isEmpty {
            return (false, "简谱不能为空")
        }
        
        // 基本格式验证
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.,_ -\n\t ")
        let invalidCharacters = cleaned.unicodeScalars.filter { !allowedCharacters.contains($0) }
        
        if !invalidCharacters.isEmpty {
            let invalidChars = String(String.UnicodeScalarView(invalidCharacters))
            return (false, "包含无效字符: \(invalidChars)")
        }
        
        return (true, nil)
    }
    
    /// 生成示例简谱
    static func generateExample() -> String {
        """
        1 1 5 5 6 6 5
        4 4 3 3 2 2 1
        5 5 4 4 3 3 2
        5 5 4 4 3 3 2
        1 1 5 5 6 6 5
        4 4 3 3 2 2 1
        """
    }
    
    /// 将Song对象转换回简谱文本（用于显示和编辑）
    static func toSheetMusic(song: Song) -> String {
        var result: [String] = []
        
        for (index, noteIndex) in song.notes.enumerated() {
            let duration = song.durations[index]
            let baseDuration = 60.0 / Double(song.bpm)
            
            // 确定音符
            let isLowOctave = noteIndex >= 8
            let actualNote = (noteIndex % 8) + 1
            
            // 构建音符字符串
            var noteStr = ""
            if isLowOctave {
                noteStr += ","
            }
            noteStr += "\(actualNote)"
            
            // 添加延长符号
            let durationRatio = duration / baseDuration
            if durationRatio > 1.0 {
                let underscores = Int(durationRatio) - 1
                noteStr += String(repeating: "_", count: underscores)
            }
            
            result.append(noteStr)
            
            // 每8个音符换行（可选）
            if (index + 1) % 8 == 0 {
                result.append("\n")
            }
        }
        
        return result.joined(separator: " ")
    }
}