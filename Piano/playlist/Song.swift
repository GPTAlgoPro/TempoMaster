import Foundation
import SwiftUI

/// 曲目模型
struct Song: Identifiable {
    let id = UUID()
    let name: String
    let notes: [Int]  // 音符索引序列
    let durations: [Double]  // 每个音符的持续时间（秒）
    let bpm: Int  // 节拍速度
    
    /// 乐谱符号（简谱）
    var sheetMusic: [SheetNote] {
        notes.map { index in
            SheetNote(noteIndex: index)
        }
    }
}

/// 简谱音符
struct SheetNote {
    let noteIndex: Int
    
    /// 获取简谱符号
    var notation: String {
        let notations = ["1", "2", "3", "4", "5", "6", "7", "1̇",  // 高音
                        "₁", "₂", "₃", "₄", "₅", "₆", "₇", "1"]  // 低音
        return notations[noteIndex]
    }
    
    /// 获取音符名称
    var name: String {
        let names = ["Do", "Re", "Mi", "Fa", "Sol", "La", "Si", "Do²",
                    "Do", "Re", "Mi", "Fa", "Sol", "La", "Si", "Do"]
        return names[noteIndex]
    }
    
    /// 获取音符颜色（用于UI显示）
    var color: Color {
        // 高音区（0-7）和低音区（8-15）使用相同的颜色方案
        let colors: [Color] = [
            .red,      // Do
            .orange,   // Re
            .yellow,   // Mi
            .green,    // Fa
            .cyan,     // Sol
            .blue,     // La
            .purple,   // Si
            .pink      // Do²
        ]
        let colorIndex = noteIndex % 8
        return noteIndex < 8 ? colors[colorIndex] : colors[colorIndex].opacity(0.7)
    }
}

// MARK: - 示例曲目
extension Song {
    /// 小星星 (Twinkle Twinkle Little Star)
    /// 使用新的音阶布局：第一排 C4-C5 (索引0-7)，第二排 C5-C6 (索引8-15)
    static var twinkleTwinkleLittleStar: Song {
        Song(
            name: "song.twinkle_star".localized,
            notes: [
            // 一闪一闪亮晶晶 (Do Do Sol Sol La La Sol)
            0, 0, 4, 4, 5, 5, 4,
            // 满天都是小星星 (Fa Fa Mi Mi Re Re Do)
            3, 3, 2, 2, 1, 1, 0,
            // 挂在天上放光明 (Sol Sol Fa Fa Mi Mi Re)
            4, 4, 3, 3, 2, 2, 1,
            // 好像许多小眼睛 (Sol Sol Fa Fa Mi Mi Re)
            4, 4, 3, 3, 2, 2, 1,
            // 一闪一闪亮晶晶 (Do Do Sol Sol La La Sol)
            0, 0, 4, 4, 5, 5, 4,
            // 满天都是小星星 (Fa Fa Mi Mi Re Re Do)
            3, 3, 2, 2, 1, 1, 0
        ],
        durations: [
            0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.8,
            0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.8,
            0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.8,
            0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.8,
            0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.8,
            0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.8
            ],
            bpm: 120
        )
    }
    
    /// 欢乐颂 (Ode to Joy)
    /// 使用新的音阶布局
    static var odeToJoy: Song {
        Song(
            name: "song.ode_to_joy".localized,
            notes: [
            // 第一句：Mi Mi Fa Sol Sol Fa Mi Re Do Do Re Mi Mi Re Re
            2, 2, 3, 4, 4, 3, 2, 1, 0, 0, 1, 2, 2, 1, 1,
            // 第二句：Mi Mi Fa Sol Sol Fa Mi Re Do Do Re Mi Re Do Do
            2, 2, 3, 4, 4, 3, 2, 1, 0, 0, 1, 2, 1, 0, 0
        ],
        durations: [
            0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.6, 0.2, 0.8,
            0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.6, 0.2, 0.8
            ],
            bpm: 120
        )
    }
    
    /// 两只老虎 (Two Tigers)
    /// 使用新的音阶布局
    static var twoTigers: Song {
        Song(
            name: "song.two_tigers".localized,
            notes: [
            // 两只老虎 两只老虎 (Do Re Mi Do, Do Re Mi Do)
            0, 1, 2, 0, 0, 1, 2, 0,
            // 跑得快 跑得快 (Mi Fa Sol, Mi Fa Sol)
            2, 3, 4, 2, 3, 4,
            // 一只没有耳朵 (Sol La Sol Fa Mi Do)
            4, 5, 4, 3, 2, 0,
            // 一只没有尾巴 (Sol La Sol Fa Mi Do)
            4, 5, 4, 3, 2, 0,
            // 真奇怪 真奇怪 (Do Sol Do, Do Sol Do)
            0, 4, 0, 0, 4, 0
        ],
        durations: [
            0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4,
            0.4, 0.4, 0.8, 0.4, 0.4, 0.8,
            0.3, 0.2, 0.2, 0.2, 0.4, 0.4, 0.3, 0.2, 0.2, 0.2, 0.4, 0.4,
            0.4, 0.4, 0.8, 0.4, 0.4, 0.8
            ],
            bpm: 120
        )
    }
    
    /// 所有示例曲
    static var allSongs: [Song] {
        [
            twinkleTwinkleLittleStar,
            twoTigers,
            odeToJoy
        ]
    }
}
