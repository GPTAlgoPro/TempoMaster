import Foundation
import SwiftUI

/// 音乐音符
struct Note: Identifiable, Hashable {
    let id: Int
    let index: Int
    let name: String
    let frequency: Double
    let notation: String
    let color: Color
    let icon: String
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Note {
    /// 所有可用音符 (C4 到 C6, 16个音符)
    /// 第一排：普通音阶 C4-C5 (Do Re Mi Fa Sol La Si Do)
    /// 第二排：高音音阶 C5-C6 (Do Re Mi Fa Sol La Si Do)
    static let allNotes: [Note] = [
        // 第一排：普通音阶 (C4 - C5)
        Note(id: 0, index: 0, name: "C4", frequency: 261.63, notation: "1", color: .red, icon: "music.quarternote.3"),
        Note(id: 1, index: 1, name: "D4", frequency: 293.66, notation: "2", color: .orange, icon: "music.quarternote.3"),
        Note(id: 2, index: 2, name: "E4", frequency: 329.63, notation: "3", color: .yellow, icon: "music.quarternote.3"),
        Note(id: 3, index: 3, name: "F4", frequency: 349.23, notation: "4", color: .green, icon: "music.quarternote.3"),
        Note(id: 4, index: 4, name: "G4", frequency: 392.00, notation: "5", color: .blue, icon: "music.quarternote.3"),
        Note(id: 5, index: 5, name: "A4", frequency: 440.00, notation: "6", color: .purple, icon: "music.quarternote.3"),
        Note(id: 6, index: 6, name: "B4", frequency: 493.88, notation: "7", color: .pink, icon: "music.quarternote.3"),
        Note(id: 7, index: 7, name: "C5", frequency: 523.25, notation: "1̇", color: .red.opacity(0.8), icon: "music.quarternote.3"),
        
        // 第二排：高音音阶 (C5 - C6)
        Note(id: 8, index: 8, name: "C5", frequency: 523.25, notation: "1̇", color: .red, icon: "music.note.list"),
        Note(id: 9, index: 9, name: "D5", frequency: 587.33, notation: "2̇", color: .orange, icon: "music.note.list"),
        Note(id: 10, index: 10, name: "E5", frequency: 659.25, notation: "3̇", color: .yellow, icon: "music.note.list"),
        Note(id: 11, index: 11, name: "F5", frequency: 698.46, notation: "4̇", color: .green, icon: "music.note.list"),
        Note(id: 12, index: 12, name: "G5", frequency: 783.99, notation: "5̇", color: .blue, icon: "music.note.list"),
        Note(id: 13, index: 13, name: "A5", frequency: 880.00, notation: "6̇", color: .purple, icon: "music.note.list"),
        Note(id: 14, index: 14, name: "B5", frequency: 987.77, notation: "7̇", color: .pink, icon: "music.note.list"),
        Note(id: 15, index: 15, name: "C6", frequency: 1046.50, notation: "1̈", color: .red.opacity(0.9), icon: "music.note.list")
    ]
}